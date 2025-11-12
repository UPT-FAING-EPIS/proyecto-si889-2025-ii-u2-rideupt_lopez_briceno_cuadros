import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/widgets/error_dialog.dart';

class DriverTripInProgressScreen extends StatefulWidget {
  final Trip trip;
  const DriverTripInProgressScreen({super.key, required this.trip});

  @override
  State<DriverTripInProgressScreen> createState() => _DriverTripInProgressScreenState();
}

class _DriverTripInProgressScreenState extends State<DriverTripInProgressScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _timer;
  int _elapsedMinutes = 0;
  int _estimatedArrivalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _setupMap();
    _calculateEstimatedArrival();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupMap() {
    final trip = widget.trip;
    
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
    final trip = widget.trip;
    
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

  void _calculateEstimatedArrival() {
    final trip = widget.trip;
    
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

    double distanceKm = earthRadius * c;
    
    // Estimar tiempo: asumiendo velocidad promedio en ciudad de 30 km/h
    _estimatedArrivalMinutes = (distanceKm / 30 * 60).ceil();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedMinutes++;
        });
      }
    });
  }

  int get _remainingMinutes {
    return math.max(0, _estimatedArrivalMinutes - _elapsedMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final confirmedPassengers = trip.passengers.where((p) => p.status == 'confirmed').toList();

    // Verificar que el viaje esté realmente en proceso y no expirado
    if (!trip.isInProgress || trip.isExpired) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Viaje No Disponible'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                trip.isExpired ? Icons.timer_off : Icons.cancel,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                trip.isExpired ? 'Este viaje ha expirado' : 'Este viaje no está disponible',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No puedes acceder a un viaje que ya ha terminado.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje en Curso'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        automaticallyImplyLeading: false, // No permitir volver atrás
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mapa
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4, // 40% de la pantalla
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
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),

            // Información del viaje
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estado del viaje
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Viaje en Curso',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${trip.origin.name} → ${trip.destination.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tiempo transcurrido y estimado
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
                          'Tiempo Transcurrido',
                          '$_elapsedMinutes min',
                          Icons.access_time,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeCard(
                          'Tiempo Estimado',
                          '$_remainingMinutes min',
                          Icons.flag,
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pasajeros
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pasajeros (${confirmedPassengers.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (confirmedPassengers.isEmpty)
                            const Text('No hay pasajeros confirmados')
                          else
                            ...confirmedPassengers.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    child: Text(
                                      p.user.firstName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${p.user.firstName} ${p.user.lastName}'),
                                ],
                              ),
                            )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón finalizar viaje
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onCompleteTrip(trip.id),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('FINALIZAR VIAJE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
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
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMyTrips() {
    // Usar un callback para cambiar la pestaña en la pantalla principal
    // Esto se puede implementar con Provider o con un callback
    // Por ahora, simplemente mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ve a "Mis Viajes" para ver el historial'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'IR',
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            // Aquí se puede implementar la navegación a la pestaña
            // Por ahora, solo cerramos el SnackBar
          },
        ),
      ),
    );
  }

  Future<void> _onCompleteTrip(String tripId) async {
    // Confirmar antes de finalizar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Viaje'),
        content: const Text('¿Has llegado al destino indicado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('SÍ, LLEGUÉ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final ok = await tripProvider.completeTrip(tripId);
    if (!mounted) return;
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Viaje completado exitosamente!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      // Regresar al menú principal y cambiar a la pestaña "Mis Viajes"
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // Notificar a la pantalla principal para cambiar a la pestaña de "Mis Viajes"
      if (mounted) {
        // Usar un callback o notificación para cambiar la pestaña
        // Esto se puede hacer con Provider o con un callback
        _navigateToMyTrips();
      }
    } else {
      showErrorDialog(context, 'Error al finalizar viaje', tripProvider.errorMessage);
    }
  }
}
