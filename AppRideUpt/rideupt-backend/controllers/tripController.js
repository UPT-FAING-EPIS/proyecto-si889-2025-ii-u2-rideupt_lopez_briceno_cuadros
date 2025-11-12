// controllers/tripController.js
const Trip = require('../models/Trip');
const User = require('../models/User'); // Asegúrate de tener el modelo User importado
const { sendPushNotification } = require('../services/notificationService');
const { getIo } = require('../services/socketService');

// @desc    Crear un nuevo viaje
// @route   POST /api/trips
// @access  Private/Driver
exports.createTrip = async (req, res) => {
    const { origin, destination, departureTime, availableSeats, pricePerSeat, description } = req.body;

    try {
        // Verificar que sea conductor
        if (req.user.role !== 'driver') {
          return res.status(403).json({ message: 'Solo conductores pueden crear viajes' });
        }

        // Verificar si el conductor ya tiene un viaje activo
        const existingTrip = await Trip.findOne({
          driver: req.user._id,
          status: { $in: ['esperando', 'completo', 'en-proceso'] },
          expiresAt: { $gt: new Date() }
        });

        if (existingTrip) {
          return res.status(400).json({ 
            message: 'Ya tienes un viaje activo. Debes esperar a que expire o completar el actual antes de crear uno nuevo.' 
          });
        }

        // Calcular tiempo de expiración: 10 minutos desde ahora
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + 10);

        const trip = new Trip({
            driver: req.user._id,
            origin,
            destination,
            departureTime,
            expiresAt, // Viaje expira en 6 minutos
            availableSeats,
            pricePerSeat,
            description
        });

        const createdTrip = await trip.save();
        
        // Poblar información del conductor y pasajeros
        await createdTrip.populate('driver', 'firstName lastName profilePhoto');
        await createdTrip.populate('passengers.user', 'firstName lastName university profilePhoto');
        
        console.log(`Viaje creado y poblado: ${createdTrip._id}`);
        
        // --- LÓGICA DE NOTIFICACIÓN DE NUEVO VIAJE ---
        // Emitir evento global para actualización en tiempo real
        getIo().emit('newTripAvailable', {
            trip: createdTrip,
            message: `Nuevo viaje disponible de ${origin.name} a ${destination.name}`
        });
        
        // Notificar a todos los pasajeros activos sobre el nuevo viaje
        const passengers = await User.find({ role: 'passenger', fcmToken: { $exists: true, $ne: null } });
        
        const notificationTitle = '🚗 Nuevo Viaje Disponible';
        const notificationBody = `${req.user.firstName} ofrece viaje de ${origin.name} a ${destination.name} por S/. ${pricePerSeat.toFixed(2)}`;
        
        // Enviar notificaciones push a todos los pasajeros
        passengers.forEach(async (passenger) => {
            try {
                await sendPushNotification(
                    passenger._id.toString(),
                    notificationTitle,
                    notificationBody,
                    {
                        tripId: createdTrip._id.toString(),
                        type: 'NEW_TRIP_AVAILABLE',
                        origin: origin.name,
                        destination: destination.name,
                        price: pricePerSeat.toString(),
                        driverName: req.user.firstName
                    }
                );
            } catch (error) {
                console.error(`Error enviando notificación a ${passenger._id}:`, error);
            }
        });

        console.log(`Viaje creado: ${createdTrip._id}, expira en 10 minutos a las ${expiresAt.toLocaleTimeString()}`);
        
        // Programar auto-expiración del viaje después de 10 minutos
        setTimeout(async () => {
          try {
            const tripToExpire = await Trip.findById(createdTrip._id);
            if (tripToExpire && tripToExpire.status === 'esperando') {
              tripToExpire.status = 'expirado';
              await tripToExpire.save();
              console.log(`Viaje ${createdTrip._id} marcado como expirado`);
              
              // Notificar que el viaje expiró
              getIo().emit('tripExpired', { tripId: createdTrip._id.toString() });
            }
          } catch (error) {
            console.error(`Error al expirar viaje ${createdTrip._id}:`, error);
          }
        }, 10 * 60 * 1000); // 10 minutos en milisegundos

        res.status(201).json(createdTrip);
    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Obtener todos los viajes disponibles
// @route   GET /api/trips
// @access  Private
exports.getAvailableTrips = async (req, res) => {
    try {
        const now = new Date();
        
        // Filtrar viajes activos que no hayan expirado
        const trips = await Trip.find({ 
            status: 'esperando', 
            expiresAt: { $gt: now } // Solo viajes que aún no expiraron
        })
            .populate('driver', 'firstName lastName profilePhoto')
            .sort({ createdAt: -1 }); // Más recientes primero
        
        res.json(trips);
    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};


// @desc    Obtener un viaje por su ID
// @route   GET /api/trips/:id
// @access  Private
exports.getTripById = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id)
            .populate('driver', 'firstName lastName profilePhoto vehicle')
            .populate('passengers.user', 'firstName lastName profilePhoto');

        if (trip) {
            res.json(trip);
        } else {
            res.status(404).json({ message: 'Viaje no encontrado' });
        }
    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};


// @desc    Pasajero solicita unirse (pendiente de aprobación)
// @route   POST /api/trips/:id/book
// @access  Private
exports.requestBooking = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);

        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }
        if (trip.driver.toString() === req.user._id.toString()) {
            return res.status(400).json({ message: 'No puedes reservar en tu propio viaje' });
        }
        if (!['esperando', 'completo'].includes(trip.status)) {
            return res.status(400).json({ message: 'Este viaje no está activo para reservas' });
        }

        // Verificar si ya tiene una solicitud
        const existingRequest = trip.passengers.find(p => p.user.toString() === req.user._id.toString());
        
        if (existingRequest) {
            // Si está confirmado, no puede volver a solicitar
            if (existingRequest.status === 'confirmed') {
                return res.status(400).json({ message: 'Ya estás confirmado en este viaje' });
            }
            // Si está pendiente, no puede volver a solicitar
            if (existingRequest.status === 'pending') {
                return res.status(400).json({ message: 'Ya tienes una solicitud pendiente para este viaje' });
            }
            // Si fue rechazado, permitir que vuelva a solicitar (actualizar a pending)
            if (existingRequest.status === 'rejected') {
                existingRequest.status = 'pending';
                existingRequest.bookedAt = new Date();
            }
        } else {
            // Agregar como pendiente (no descuenta cupo aún)
            trip.passengers.push({ user: req.user._id, status: 'pending' });
        }

        await trip.save();

        // Notificar al conductor
        const driverId = trip.driver.toString();
        const notificationTitle = existingRequest && existingRequest.status === 'pending' 
            ? 'Nueva Solicitud de Viaje' 
            : 'Nueva Solicitud de Viaje';
        const notificationBody = existingRequest && existingRequest.status === 'pending'
            ? `${req.user.firstName} volvió a solicitar unirse a tu viaje a ${trip.destination.name}.`
            : `${req.user.firstName} quiere unirse a tu viaje a ${trip.destination.name}.`;
        
        await sendPushNotification(driverId, notificationTitle, notificationBody, { tripId: trip._id.toString(), type: 'NEW_BOOKING_REQUEST' });
        getIo().to(driverId).emit('newBookingRequest', { 
            message: notificationBody,
            tripId: trip._id.toString(),
            passenger: { _id: req.user._id, firstName: req.user.firstName }
        });

        res.status(201).json({ message: 'Solicitud enviada. Espera aprobación del conductor.' });

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};


// @desc    Conductor gestiona una solicitud (aceptar/rechazar)
// @route   PUT /api/trips/:tripId/bookings/:passengerId
// @access  Private/Driver
exports.manageBooking = async (req, res) => {
    const { status } = req.body;
    const { tripId, passengerId } = req.params;

    if (!['confirmed', 'rejected'].includes(status)) {
        return res.status(400).json({ message: "Estado inválido. Debe ser 'confirmed' o 'rejected'." });
    }

    try {
        const trip = await Trip.findById(tripId);
        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }
        if (trip.driver.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'No autorizado para gestionar este viaje' });
        }

        const passengerRequest = trip.passengers.find(p => p.user.toString() === passengerId && p.status === 'pending');
        if (!passengerRequest) {
            return res.status(404).json({ message: 'Solicitud de pasajero no encontrada o ya gestionada' });
        }

        let notificationTitle = 'Solicitud Actualizada';
        let notificationBody = '';

        if (status === 'confirmed') {
            if (trip.seatsBooked >= trip.availableSeats) {
                return res.status(400).json({ message: 'El viaje ya está lleno' });
            }
            passengerRequest.status = 'confirmed';
            trip.seatsBooked += 1;
            
            // Si el viaje se llena, cambiar a estado 'completo'
            if (trip.seatsBooked === trip.availableSeats) {
                trip.status = 'completo';
            }
            notificationBody = `¡Tu solicitud para el viaje a ${trip.destination.name} ha sido aceptada!`;
        } else { // 'rejected'
            passengerRequest.status = 'rejected';
            notificationBody = `Tu solicitud para el viaje a ${trip.destination.name} ha sido rechazada.`;
        }

        const updatedTrip = await trip.save();
        
        // --- LÓGICA DE NOTIFICACIÓN REAL PARA EL PASAJERO ---
        // 1. Enviar Notificación Push
        await sendPushNotification(passengerId, notificationTitle, notificationBody, { tripId: tripId, type: 'BOOKING_STATUS_UPDATE' });
        
        // 2. Emitir Evento por Socket para actualización en tiempo real
        getIo().to(passengerId).emit('bookingStatusChanged', {
            message: notificationBody,
            tripId: tripId,
            status: status
        });
        
        // También notificar al conductor para actualizar su UI
        getIo().to(trip.driver.toString()).emit('tripUpdated', updatedTrip);

        res.json(updatedTrip);

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};


// @desc    Obtener los viajes que un usuario ha creado como conductor
// @route   GET /api/trips/my-driver-trips
// @access  Private/Driver
exports.getMyDriverTrips = async (req, res) => {
    try {
        console.log(`getMyDriverTrips: Usuario ${req.user._id}, rol: ${req.user.role}`);
        
        const trips = await Trip.find({ driver: req.user._id })
            .populate('driver', 'firstName lastName profilePhoto')
            .populate('passengers.user', 'firstName lastName university profilePhoto phone')
            .sort({ createdAt: -1 });
        
        console.log(`getMyDriverTrips: Encontrados ${trips.length} viajes`);
        
        if (trips.length > 0) {
            console.log(`Primer viaje: ${trips[0]._id}, pasajeros: ${trips[0].passengers.length}`);
            trips[0].passengers.forEach(p => {
                console.log(`  - Pasajero: ${p.user ? p.user.firstName : 'USUARIO NO POBLADO'}, status: ${p.status}`);
            });
        }
        
        res.json(trips);
    } catch (error) {
        console.error('Error en getMyDriverTrips:', error);
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Obtener las reservas que un usuario ha hecho como pasajero
// @route   GET /api/trips/my-passenger-trips
// @access  Private
exports.getMyPassengerTrips = async (req, res) => {
    try {
        const trips = await Trip.find({ 'passengers.user': req.user._id })
            .populate('driver', 'firstName lastName vehicle')
            .populate('passengers.user', 'firstName lastName university profilePhoto')
            .sort({ createdAt: -1 });
        res.json(trips);
    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Iniciar un viaje (solo si hay al menos 1 pasajero confirmado)
// @route   PUT /api/trips/:id/start
// @access  Private/Driver
exports.startTrip = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);

        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }

        // Verificar que el usuario es el conductor
        if (trip.driver.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'No autorizado. Solo el conductor puede iniciar el viaje.' });
        }

        // Verificar que el viaje esté esperando o completo
        if (!['esperando', 'completo'].includes(trip.status)) {
            return res.status(400).json({ message: 'El viaje no puede ser iniciado en su estado actual' });
        }

        // Verificar que haya al menos un pasajero confirmado
        const confirmedPassengers = trip.passengers.filter(p => p.status === 'confirmed');
        if (confirmedPassengers.length === 0) {
            return res.status(400).json({ message: 'No puedes iniciar el viaje sin pasajeros confirmados' });
        }

        // Cambiar estado a en-proceso
        trip.status = 'en-proceso';
        const updatedTrip = await trip.save();

        // Poblar datos
        await updatedTrip.populate('driver', 'firstName lastName profilePhoto vehicle');
        await updatedTrip.populate('passengers.user', 'firstName lastName university profilePhoto phone');

        // Notificar a los pasajeros confirmados
        const notificationTitle = '🚗 Viaje Iniciado';
        const notificationBody = `${req.user.firstName} ha iniciado el viaje a ${trip.destination.name}`;
        
        confirmedPassengers.forEach(async (passenger) => {
            try {
                await sendPushNotification(
                    passenger.user.toString(),
                    notificationTitle,
                    notificationBody,
                    { tripId: trip._id.toString(), type: 'TRIP_STARTED' }
                );
                getIo().to(passenger.user.toString()).emit('tripStarted', {
                    message: notificationBody,
                    tripId: trip._id.toString(),
                });
            } catch (error) {
                console.error(`Error notificando a pasajero ${passenger.user}:`, error);
            }
        });

        console.log(`Viaje ${trip._id} iniciado por conductor ${req.user._id}`);
        res.json(updatedTrip);

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Cancelar un viaje (solo si no hay pasajeros confirmados)
// @route   DELETE /api/trips/:id/cancel
// @access  Private/Driver
exports.cancelTrip = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);

        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }

        // Verificar que el usuario es el conductor
        if (trip.driver.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'No autorizado. Solo el conductor puede cancelar el viaje.' });
        }

        // Verificar que el viaje esté esperando o completo
        if (!['esperando', 'completo'].includes(trip.status)) {
            return res.status(400).json({ message: 'El viaje no puede ser cancelado en su estado actual' });
        }

        // Verificar que NO haya pasajeros confirmados
        const confirmedPassengers = trip.passengers.filter(p => p.status === 'confirmed');
        if (confirmedPassengers.length > 0) {
            return res.status(400).json({ 
                message: 'No puedes cancelar el viaje porque ya tienes pasajeros confirmados. Debes contactarlos primero.' 
            });
        }

        // Cambiar estado a cancelado
        trip.status = 'cancelado';
        const updatedTrip = await trip.save();

        // Notificar a los pasajeros pendientes
        const pendingPassengers = trip.passengers.filter(p => p.status === 'pending');
        const notificationTitle = '❌ Viaje Cancelado';
        const notificationBody = `El viaje a ${trip.destination.name} ha sido cancelado por el conductor`;
        
        pendingPassengers.forEach(async (passenger) => {
            try {
                await sendPushNotification(
                    passenger.user.toString(),
                    notificationTitle,
                    notificationBody,
                    { tripId: trip._id.toString(), type: 'TRIP_CANCELLED' }
                );
                getIo().to(passenger.user.toString()).emit('tripCancelled', {
                    message: notificationBody,
                    tripId: trip._id.toString(),
                });
            } catch (error) {
                console.error(`Error notificando a pasajero ${passenger.user}:`, error);
            }
        });

        console.log(`Viaje ${trip._id} cancelado por conductor ${req.user._id}`);
        res.json({ message: 'Viaje cancelado exitosamente', trip: updatedTrip });

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Pasajero cancela su participación en un viaje antes de que inicie
// @route   DELETE /api/trips/:id/leave
// @access  Private
exports.leaveTrip = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);

        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }

        // Verificar que el viaje no haya iniciado
        if (trip.status === 'en-proceso') {
            return res.status(400).json({ message: 'No puedes salir de un viaje que ya ha iniciado' });
        }

        if (trip.status === 'expirado' || trip.status === 'cancelado') {
            return res.status(400).json({ message: 'No puedes salir de un viaje que ya ha terminado' });
        }

        // Buscar al pasajero en la lista
        const passengerIndex = trip.passengers.findIndex(
            p => p.user.toString() === req.user._id.toString() && p.status === 'confirmed'
        );

        if (passengerIndex === -1) {
            return res.status(404).json({ message: 'No estás confirmado en este viaje' });
        }

        // Remover al pasajero de la lista
        trip.passengers.splice(passengerIndex, 1);
        
        // Disminuir el contador de asientos reservados
        if (trip.seatsBooked > 0) {
            trip.seatsBooked -= 1;
        }

        // Si el viaje estaba completo y ahora hay espacio, volver a esperando
        if (trip.status === 'completo' && trip.seatsBooked < trip.availableSeats) {
            trip.status = 'esperando';
        }

        const updatedTrip = await trip.save();

        // Notificar al conductor
        const notificationTitle = '⚠️ Pasajero Canceló';
        const notificationBody = `${req.user.firstName} ha cancelado su participación en el viaje a ${trip.destination.name}`;
        
        try {
            await sendPushNotification(
                trip.driver.toString(),
                notificationTitle,
                notificationBody,
                { tripId: trip._id.toString(), type: 'PASSENGER_LEFT' }
            );
            getIo().to(trip.driver.toString()).emit('passengerLeft', {
                message: notificationBody,
                tripId: trip._id.toString(),
                passengerId: req.user._id.toString(),
            });
        } catch (error) {
            console.error(`Error notificando al conductor:`, error);
        }

        console.log(`Pasajero ${req.user._id} canceló participación en viaje ${trip._id}`);
        res.json({ message: 'Has salido del viaje exitosamente', trip: updatedTrip });

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};

// @desc    Finalizar un viaje (solo si está en curso)
// @route   PUT /api/trips/:id/complete
// @access  Private/Driver
exports.completeTrip = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);

        if (!trip) {
            return res.status(404).json({ message: 'Viaje no encontrado' });
        }

        // Verificar que el usuario es el conductor
        if (trip.driver.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: 'No autorizado. Solo el conductor puede finalizar el viaje.' });
        }

        // Verificar que el viaje esté en curso
        if (trip.status !== 'en-proceso') {
            return res.status(400).json({ message: 'Solo se pueden finalizar viajes que están en curso' });
        }

        // Cambiar estado a expirado (viaje completado)
        trip.status = 'expirado';
        const updatedTrip = await trip.save();

        // Poblar datos
        await updatedTrip.populate('driver', 'firstName lastName profilePhoto vehicle');
        await updatedTrip.populate('passengers.user', 'firstName lastName university profilePhoto phone');

        // Notificar a los pasajeros confirmados
        const confirmedPassengers = trip.passengers.filter(p => p.status === 'confirmed');
        const notificationTitle = '🎉 Viaje Completado';
        const notificationBody = `${req.user.firstName} ha completado el viaje a ${trip.destination.name}. ¡Gracias por viajar con nosotros!`;
        
        confirmedPassengers.forEach(async (passenger) => {
            try {
                await sendPushNotification(
                    passenger.user.toString(),
                    notificationTitle,
                    notificationBody,
                    { tripId: trip._id.toString(), type: 'TRIP_COMPLETED' }
                );
                getIo().to(passenger.user.toString()).emit('tripCompleted', {
                    message: notificationBody,
                    tripId: trip._id.toString(),
                });
            } catch (error) {
                console.error(`Error notificando a pasajero ${passenger.user}:`, error);
            }
        });

        console.log(`Viaje ${trip._id} completado por conductor ${req.user._id}`);
        res.json(updatedTrip);

    } catch (error) {
        res.status(500).json({ message: `Error del servidor: ${error.message}` });
    }
};