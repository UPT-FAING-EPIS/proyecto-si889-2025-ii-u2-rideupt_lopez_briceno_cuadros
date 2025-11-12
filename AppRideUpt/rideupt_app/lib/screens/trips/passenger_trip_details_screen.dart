import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/widgets/error_dialog.dart';
import 'package:rideupt_app/screens/trips/passenger_trip_in_progress_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PassengerTripDetailsScreen extends StatefulWidget {
  final Trip trip;
  const PassengerTripDetailsScreen({super.key, required this.trip});

  @override
  State<PassengerTripDetailsScreen> createState() => _PassengerTripDetailsScreenState();
}

class _PassengerTripDetailsScreenState extends State<PassengerTripDetailsScreen> {
  Trip? _fullTrip;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double? _distanceKm;
  int? _estimatedMinutes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final t = await tripProvider.fetchTripById(widget.trip.id);
    if (!mounted) return;
    setState(() {
      _fullTrip = t ?? widget.trip;
      _setupMap();
      _calculateDistanceAndTime();
    });
  }

  void _setupMap() {
    final trip = _fullTrip ?? widget.trip;
    
    _markers = {
      Marker(
        markerId: const MarkerId('origin'),
        position: trip.origin.coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origen',
          snippet: trip.origin.name,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: trip.destination.coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: trip.destination.name,
        ),
      ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [trip.origin.coordinates, trip.destination.coordinates],
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    Future.delayed(const Duration(milliseconds: 500), () {
      _fitBounds();
    });
  }

  void _fitBounds() {
    if (_mapController == null) return;
    final trip = _fullTrip ?? widget.trip;
    
    double south = math.min(trip.origin.coordinates.latitude, trip.destination.coordinates.latitude);
    double north = math.max(trip.origin.coordinates.latitude, trip.destination.coordinates.latitude);
    double west = math.min(trip.origin.coordinates.longitude, trip.destination.coordinates.longitude);
    double east = math.max(trip.origin.coordinates.longitude, trip.destination.coordinates.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _calculateDistanceAndTime() {
    final trip = _fullTrip ?? widget.trip;
    
    // Calcular distancia con Haversine
    const double earthRadius = 6371;
    double lat1 = trip.origin.coordinates.latitude * math.pi / 180;
    double lat2 = trip.destination.coordinates.latitude * math.pi / 180;
    double deltaLat = (trip.destination.coordinates.latitude - trip.origin.coordinates.latitude) * math.pi / 180;
    double deltaLng = (trip.destination.coordinates.longitude - trip.origin.coordinates.longitude) * math.pi / 180;

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    _distanceKm = earthRadius * c;
    
    // Estimar tiempo: asumiendo velocidad promedio en ciudad de 30 km/h
    _estimatedMinutes = (_distanceKm! / 30 * 60).ceil();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final trip = _fullTrip ?? widget.trip;
    final confirmedPassengers = trip.passengers.where((p) => p.status == 'confirmed').toList();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    
    // Verificar el estado del usuario actual en este viaje
    final myPassengerStatus = trip.passengers
        .firstWhere(
          (p) => p.user.id == currentUserId,
          orElse: () => TripPassenger(
            user: authProvider.user!,
            status: 'none',
            bookedAt: DateTime.now(),
          ),
        )
        .status;

    // Si el viaje está en curso y el usuario está confirmado, redirigir a la pantalla de recorrido
    if (trip.isInProgress && myPassengerStatus == 'confirmed') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PassengerTripInProgressScreen(trip: trip),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Viaje'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          // Mapa con ruta
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: trip.origin.coordinates,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds();
              },
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),

          // Info del viaje
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Countdown
                if (trip.expiresAt != null)
                  Card(
                    color: _getCountdownColor(trip),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.timeRemainingText,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Tiempo para que expire',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Información de ruta
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Trayecto',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        _buildRouteInfo(Icons.trip_origin, 'Origen', trip.origin.name, Colors.green),
                        const SizedBox(height: 12),
                        _buildRouteInfo(Icons.place, 'Destino', trip.destination.name, Colors.red),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                Icons.straighten,
                                'Distancia',
                                _distanceKm != null ? '${_distanceKm!.toStringAsFixed(2)} km' : 'Calculando...',
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatBox(
                                Icons.access_time,
                                'Tiempo est.',
                                _estimatedMinutes != null ? '$_estimatedMinutes min' : 'Calculando...',
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Información del conductor
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conductor',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            radius: 28,
                            child: Text(
                              trip.driver.firstName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${trip.driver.firstName} ${trip.driver.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(trip.driver.university),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                Icons.attach_money,
                                'Precio',
                                'S/. ${trip.pricePerSeat.toStringAsFixed(2)}',
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatBox(
                                Icons.event_seat,
                                'Asientos',
                                '${trip.availableSeats - trip.seatsBooked} disponibles',
                                trip.seatsBooked >= trip.availableSeats ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pasajeros confirmados
                if (confirmedPassengers.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Viajarás con (${confirmedPassengers.length})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ...confirmedPassengers.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    p.user.firstName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${p.user.firstName} ${p.user.lastName}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        p.user.university,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.verified, color: Colors.green, size: 20),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón de acción según estado
                _buildActionButton(trip, myPassengerStatus),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Trip trip, String myStatus) {
    return Consumer<TripProvider>(
      builder: (ctx, tripProvider, _) {
        final seatsAvailable = trip.availableSeats - trip.seatsBooked;
        final canJoin = seatsAvailable > 0 && !trip.isExpired;
        
        // Si el pasajero está confirmado
        if (myStatus == 'confirmed') {
          // Si el viaje ya inició, no puede cancelar
          if (trip.status == 'in-progress') {
            return Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Estás en este viaje!',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'El viaje ha iniciado. ¡Disfruta el viaje!',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Si el viaje no ha iniciado, puede cancelar
          return Column(
            children: [
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Estás confirmado en este viaje!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón para ir al punto de encuentro
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dirígete al punto de encuentro',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  trip.origin.name,
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openInGoogleMaps(trip.origin.coordinates, trip.origin.name),
                          icon: const Icon(Icons.directions),
                          label: const Text('ABRIR EN GOOGLE MAPS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: tripProvider.isLoading
                    ? null
                    : () => _onLeaveTrip(trip.id),
                  icon: tripProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.exit_to_app),
                  label: Text(
                    tripProvider.isLoading
                      ? 'Cancelando...'
                      : 'CANCELAR MI PARTICIPACIÓN',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }
        
        // Si el pasajero está pendiente
        if (myStatus == 'pending') {
          return Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange.shade700, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitud Pendiente',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Espera a que el conductor revise tu solicitud',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Si el pasajero fue rechazado, permitir solicitar de nuevo
        if (myStatus == 'rejected') {
          return SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !tripProvider.isLoading
                ? () async {
                    final success = await tripProvider.bookTrip(trip.id);
                    if (!mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Solicitud enviada nuevamente!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      await _loadDetails();
                    } else {
                      showErrorDialog(context, 'Error', tripProvider.errorMessage);
                    }
                  }
                : null,
              icon: tripProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
              label: Text(
                tripProvider.isLoading
                  ? 'Enviando...'
                  : 'VOLVER A SOLICITAR',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        
        // Si no está en el viaje, mostrar botón para solicitar
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canJoin && !tripProvider.isLoading
              ? () async {
                  final success = await tripProvider.bookTrip(trip.id);
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Solicitud enviada! Espera la aprobación del conductor.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadDetails();
                  } else {
                    showErrorDialog(context, 'Error', tripProvider.errorMessage);
                  }
                }
              : null,
            icon: tripProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.hail),
            label: Text(
              tripProvider.isLoading
                ? 'Enviando...'
                : !canJoin
                  ? (seatsAvailable <= 0 ? 'SIN ASIENTOS' : 'VIAJE EXPIRADO')
                  : 'SOLICITAR UNIRME AL VIAJE',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: canJoin ? Colors.indigo : Colors.grey,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLeaveTrip(String tripId) async {
    // Confirmar antes de cancelar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Participación'),
        content: const Text('¿Estás seguro de que quieres salir de este viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SÍ, SALIR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final ok = await tripProvider.leaveTrip(tripId);
    if (!mounted) return;
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has salido del viaje exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop(); // Regresar al menú
    } else {
      showErrorDialog(context, 'Error', tripProvider.errorMessage);
    }
  }

  Color _getCountdownColor(Trip trip) {
    final minutes = trip.minutesRemaining;
    if (minutes <= 0) return Colors.red.shade700;
    if (minutes <= 3) return Colors.red.shade600;
    if (minutes <= 6) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  Future<void> _openInGoogleMaps(LatLng coordinates, String locationName) async {
    try {
      // Crear URL para Google Maps con navegación
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${coordinates.latitude},${coordinates.longitude}&travelmode=driving';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Fallback: abrir Google Maps con la ubicación
        final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=${coordinates.latitude},${coordinates.longitude}';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
        } else {
          // Mostrar mensaje de error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir Google Maps. Instala la aplicación.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir Google Maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}




