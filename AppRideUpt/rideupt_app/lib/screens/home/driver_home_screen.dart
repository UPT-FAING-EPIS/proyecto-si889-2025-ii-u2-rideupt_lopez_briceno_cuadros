import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/screens/trips/create_trip_screen.dart';
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/services/socket_service.dart';
import 'package:rideupt_app/widgets/modern_loading.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupSocketListeners();
    });
    
    // Actualizar cada 2 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _setupSocketListeners() {
    final socket = SocketService().socket;
    socket?.on('newBookingRequest', (_) {
      print('Socket: Nueva solicitud!');
      _loadData();
    });
    socket?.on('tripUpdated', (_) {
      print('Socket: Viaje actualizado!');
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    await tripProvider.fetchMyTrips();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Viaje'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading && tripProvider.myTrips.isEmpty) {
            return const ModernLoading(message: 'Cargando viajes...');
          }

          // Buscar viaje activo
          Trip? activeTrip;
          for (var trip in tripProvider.activeMyTrips) {
            if ((trip.isActive || trip.isFull) && !trip.isExpired) {
              activeTrip = trip;
              break;
            }
          }

          if (activeTrip == null) {
            return _buildNoTrip();
          }

          return _buildActiveTrip(activeTrip, tripProvider);
        },
      ),
      floatingActionButton: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          // Buscar si hay viaje activo
          final hasActive = tripProvider.activeMyTrips.any(
            (t) => (t.isActive || t.isFull) && !t.isExpired
          );

          if (hasActive) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateTripScreen()),
              );
              await _loadData();
            },
            label: const Text('Crear Viaje'),
            icon: const Icon(Icons.add_rounded),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoTrip() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No tienes viajes activos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea un viaje para empezar a conectar con estudiantes',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrip(Trip trip, TripProvider tripProvider) {
    final pending = trip.passengers.where((p) => p.status == 'pending').toList();
    final confirmed = trip.passengers.where((p) => p.status == 'confirmed').toList();
    final seatsLeft = trip.availableSeats - trip.seatsBooked;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // COUNTDOWN
          Card(
            color: _getCountdownColor(trip),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.timer, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    trip.timeRemainingText,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Tiempo restante',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // INFO VIAJE
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(Icons.trip_origin, trip.origin.name, Colors.green),
                  const SizedBox(height: 12),
                  _buildRow(Icons.place, trip.destination.name, Colors.red),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChip('S/. ${trip.pricePerSeat.toStringAsFixed(2)}', Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChip('${trip.seatsBooked}/${trip.availableSeats}', Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // SOLICITUDES PENDIENTES
          Text(
            'SOLICITUDES PENDIENTES (${pending.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (pending.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Esperando solicitudes...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...pending.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange,
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                p.user.university,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _reject(p.user.id, p.user.firstName, tripProvider, trip.id),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('RECHAZAR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: seatsLeft > 0
                              ? () => _accept(p.user.id, p.user.firstName, tripProvider, trip.id)
                              : null,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('ACEPTAR'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          
          const SizedBox(height: 24),

          // PASAJEROS CONFIRMADOS
          Text(
            'PASAJEROS CONFIRMADOS (${confirmed.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (confirmed.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Aún no hay pasajeros confirmados',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            )
          else
            ...confirmed.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.green.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    p.user.firstName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  '${p.user.firstName} ${p.user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(p.user.university),
                trailing: const Icon(Icons.verified, color: Colors.green),
              ),
            )),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getCountdownColor(Trip trip) {
    final min = trip.minutesRemaining;
    if (min <= 0) return Colors.red;
    if (min <= 3) return Colors.red.shade600;
    if (min <= 6) return Colors.orange;
    return Colors.green;
  }

  Future<void> _accept(String passengerId, String name, TripProvider provider, String tripId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aceptar Pasajero'),
        content: Text('¿Confirmas que $name puede unirse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('ACEPTAR'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await provider.manageBooking(
      tripId: tripId,
      passengerId: passengerId,
      status: 'confirmed',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $name fue aceptado'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reject(String passengerId, String name, TripProvider provider, String tripId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar Solicitud'),
        content: Text('¿Seguro que quieres rechazar a $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RECHAZAR'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await provider.manageBooking(
      tripId: tripId,
      passengerId: passengerId,
      status: 'rejected',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Solicitud de $name rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
