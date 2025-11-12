// lib/screens/trips/my_trips_screen.dart (NUEVO)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/screens/trips/trip_details_screen.dart';
import 'package:rideupt_app/screens/trips/passenger_trip_details_screen.dart';
import 'package:rideupt_app/screens/trips/driver_trip_in_progress_screen.dart';
import 'package:rideupt_app/screens/trips/passenger_trip_in_progress_screen.dart';
import 'package:rideupt_app/widgets/trip_card.dart';
import 'package:rideupt_app/widgets/skeleton_trip_list.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<TripProvider>(context, listen: false).fetchMyTrips()
    );
  }

  void _checkForActiveTrip() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDriver = authProvider.user?.role == 'driver';
    final currentUserId = authProvider.user?.id;

    // Buscar viaje REALMENTE en curso (solo en-proceso, NO esperando)
    for (final trip in tripProvider.activeMyTrips) {
      if (trip.isInProgress && !trip.isExpired) {
        if (isDriver) {
          // Conductor: ir a pantalla de viaje en curso
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DriverTripInProgressScreen(trip: trip),
            ),
          );
        } else {
          // Pasajero: verificar si está confirmado en el viaje
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
          
          if (myPassengerStatus == 'confirmed') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PassengerTripInProgressScreen(trip: trip),
              ),
            );
          }
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDriver = authProvider.user?.role == 'driver';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<TripProvider>(context, listen: false).fetchMyTrips(),
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const SkeletonTripList();
          }
          
          // Verificar si hay un viaje en curso después de cargar
          if (!tripProvider.isLoading && tripProvider.activeMyTrips.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkForActiveTrip();
            });
          }
          
          if (tripProvider.activeMyTrips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDriver ? Icons.directions_car_outlined : Icons.book_online_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isDriver ? 'No has creado viajes' : 'No tienes viajes reservados',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isDriver 
                        ? 'Crea tu primer viaje para comenzar a conectar con estudiantes'
                        : 'Busca y reserva un viaje disponible',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => tripProvider.fetchMyTrips(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: tripProvider.activeMyTrips.length,
              itemBuilder: (ctx, i) {
                final trip = tripProvider.activeMyTrips[i];
                return TripCard(
                  trip: trip,
                  onTap: () {
                    // Permitir navegación a viajes activos (esperando, completo, en proceso)
                    if ((trip.isActive || trip.isFull || trip.isInProgress) && !trip.isExpired) {
                      // Si es conductor, va a la pantalla de conductor
                      // Si es pasajero, va a la pantalla de pasajero
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => isDriver
                            ? TripDetailsScreen(trip: trip)
                            : PassengerTripDetailsScreen(trip: trip),
                        ),
                      ).then((_) {
                        // Actualizar la lista al volver
                        tripProvider.fetchMyTrips();
                      });
                    } else {
                      // Para viajes expirados, cancelados o completados, mostrar solo información
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            trip.isExpired 
                              ? 'Este viaje ya ha expirado'
                              : trip.isCancelled 
                                ? 'Este viaje fue cancelado'
                                : 'Este viaje ya ha terminado',
                          ),
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}