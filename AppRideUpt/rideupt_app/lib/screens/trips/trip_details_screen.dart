// lib/screens/trips/trip_details_screen.dart (NUEVO)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/widgets/error_dialog.dart';
import 'package:rideupt_app/screens/trips/driver_trip_in_progress_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  Trip? _fullTrip;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final t = await tripProvider.fetchTripById(widget.trip.id);
    if (!mounted) return;
    setState(() {
      _fullTrip = t ?? widget.trip;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTrip = _fullTrip ?? widget.trip;
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    final isDriver = currentUserId == effectiveTrip.driver.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Viaje'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 260,
            child: Card(
              margin: const EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: effectiveTrip.origin.coordinates,
                  zoom: 14,
                ),
                markers: {
                  Marker(markerId: const MarkerId('origin'), position: effectiveTrip.origin.coordinates),
                  Marker(markerId: const MarkerId('destination'), position: effectiveTrip.destination.coordinates),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow(context, 'Conductor:', effectiveTrip.driver.firstName),
                _buildDetailRow(context, 'Salida:', DateFormat('dd MMM, hh:mm a').format(effectiveTrip.departureTime)),
                _buildDetailRow(context, 'Asientos:', '${effectiveTrip.seatsBooked}/${effectiveTrip.availableSeats} ocupados'),
                _buildDetailRow(context, 'Precio:', 'S/. ${effectiveTrip.pricePerSeat.toStringAsFixed(2)} por asiento'),
                const SizedBox(height: 16),
                if (isDriver) _buildPassengersSection(context, effectiveTrip) else _buildJoinButton(context, effectiveTrip),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildPassengersSection(BuildContext context, Trip trip) {
    final pending = trip.passengers.where((p) => p.status == 'pending').toList();
    final confirmed = trip.passengers.where((p) => p.status == 'confirmed').toList();
    final canStartTrip = confirmed.isNotEmpty && (trip.isActive || trip.isFull);
    final canCancelTrip = confirmed.isEmpty && (trip.isActive || trip.isFull);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Estado del viaje
        Card(
          color: _getTripStatusColor(trip.status),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(_getTripStatusIcon(trip.status), color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTripStatusText(trip.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getTripStatusDescription(trip.status, confirmed.length),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      // Mostrar contador de 10 minutos solo si está activo
                      if (trip.isActive && trip.waitingTimeText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          trip.waitingTimeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botones de acción
        if (!trip.isInProgress && !trip.isCompleted && !trip.isCancelled) ...[
          Row(
            children: [
              if (canCancelTrip)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onCancelTrip(context, trip.id),
                    icon: const Icon(Icons.cancel),
                    label: const Text('CANCELAR VIAJE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (canCancelTrip && canStartTrip) const SizedBox(width: 8),
              if (canStartTrip)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onStartTrip(context, trip.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('INICIAR VIAJE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        Text('Solicitudes Pendientes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const Text('No hay solicitudes pendientes.'),
        ...pending.map((p) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('${p.user.firstName} ${p.user.lastName}'),
                subtitle: Text(p.user.university),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _onManage(context, trip.id, p.user.id, 'rejected'),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _onManage(context, trip.id, p.user.id, 'confirmed'),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        Text('Pasajeros Confirmados (${confirmed.length})', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (confirmed.isEmpty)
          const Text('Aún no hay pasajeros confirmados.'),
        ...confirmed.map((p) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.verified, color: Colors.white),
                ),
                title: Text('${p.user.firstName} ${p.user.lastName}'),
                subtitle: Text(p.user.university),
                trailing: p.user.phone.isNotEmpty
                  ? Text(p.user.phone, style: const TextStyle(fontSize: 12))
                  : null,
              ),
            )),
      ],
    );
  }

  String _getTripStatusText(String status) {
    switch (status) {
      case 'active':
      case 'esperando':
        return 'VIAJE ACTIVO';
      case 'full':
      case 'completo':
        return 'VIAJE LLENO';
      case 'in-progress':
      case 'en-proceso':
        return 'VIAJE EN CURSO';
      case 'completed':
      case 'expirado':
        return 'VIAJE COMPLETADO';
      case 'cancelled':
      case 'cancelado':
        return 'VIAJE CANCELADO';
      case 'expired':
        return 'VIAJE EXPIRADO';
      default:
        return 'ESTADO DESCONOCIDO';
    }
  }

  String _getTripStatusDescription(String status, int confirmedCount) {
    switch (status) {
      case 'active':
      case 'esperando':
        return confirmedCount > 0 
          ? 'Esperando más pasajeros o listo para iniciar'
          : 'Esperando pasajeros';
      case 'full':
      case 'completo':
        return 'Todos los asientos están ocupados';
      case 'in-progress':
      case 'en-proceso':
        return 'El viaje ha iniciado';
      case 'completed':
      case 'expirado':
        return 'El viaje ha finalizado';
      case 'cancelled':
      case 'cancelado':
        return 'El viaje fue cancelado';
      case 'expired':
        return 'El tiempo de espera expiró';
      default:
        return '';
    }
  }

  IconData _getTripStatusIcon(String status) {
    switch (status) {
      case 'active':
      case 'esperando':
        return Icons.access_time;
      case 'full':
      case 'completo':
        return Icons.event_seat;
      case 'in-progress':
      case 'en-proceso':
        return Icons.directions_car;
      case 'completed':
      case 'expirado':
        return Icons.check_circle;
      case 'cancelled':
      case 'cancelado':
        return Icons.cancel;
      case 'expired':
        return Icons.timer_off;
      default:
        return Icons.help;
    }
  }

  Color _getTripStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'esperando':
        return Colors.blue;
      case 'full':
      case 'completo':
        return Colors.orange;
      case 'in-progress':
      case 'en-proceso':
        return Colors.green;
      case 'completed':
      case 'expirado':
        return Colors.grey;
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      case 'expired':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  Widget _buildJoinButton(BuildContext context, Trip trip) {
    return Consumer<TripProvider>(
      builder: (ctx, tripProvider, _) => tripProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton.icon(
              icon: const Icon(Icons.hail),
              onPressed: () async {
                final success = await tripProvider.bookTrip(trip.id);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Solicitud enviada! Espera la aprobación.'), backgroundColor: Colors.green),
                  );
                  Navigator.of(context).pop();
                } else {
                  showErrorDialog(context, 'Error en la Solicitud', tripProvider.errorMessage);
                }
              },
              label: const Text('SOLICITAR UNIRME'),
            ),
    );
  }

  Future<void> _onManage(BuildContext context, String tripId, String passengerId, String status) async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final ok = await tripProvider.manageBooking(tripId: tripId, passengerId: passengerId, status: status);
    if (!mounted) return;
    if (ok) {
      await _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'confirmed' ? 'Solicitud aceptada' : 'Solicitud rechazada')),
      );
    } else {
      showErrorDialog(context, 'No se pudo actualizar', tripProvider.errorMessage);
    }
  }

  Future<void> _onStartTrip(BuildContext context, String tripId) async {
    // Confirmar antes de iniciar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Iniciar Viaje'),
        content: const Text('¿Estás seguro de que quieres iniciar el viaje? Una vez iniciado, no se pueden agregar más pasajeros.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('INICIAR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final ok = await tripProvider.startTrip(tripId);
    if (!mounted) return;
    
    if (ok) {
      await _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Viaje iniciado! Los pasajeros han sido notificados.'),
          backgroundColor: Colors.green,
        ),
      );
      // Redirigir a la pantalla de viaje en curso
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DriverTripInProgressScreen(trip: _fullTrip ?? widget.trip),
        ),
      );
    } else {
      showErrorDialog(context, 'Error al iniciar viaje', tripProvider.errorMessage);
    }
  }

  Future<void> _onCancelTrip(BuildContext context, String tripId) async {
    // Confirmar antes de cancelar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Viaje'),
        content: const Text('¿Estás seguro de que quieres cancelar el viaje? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SÍ, CANCELAR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final ok = await tripProvider.cancelTrip(tripId);
    if (!mounted) return;
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viaje cancelado exitosamente'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop(); // Regresar a la lista de viajes
    } else {
      showErrorDialog(context, 'Error al cancelar viaje', tripProvider.errorMessage);
    }
  }
}