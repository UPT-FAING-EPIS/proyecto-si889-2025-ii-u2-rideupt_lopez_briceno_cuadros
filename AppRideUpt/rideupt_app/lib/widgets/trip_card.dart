import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rideupt_app/models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap; // Callback para la acción de tap

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determinar color del badge de expiración
    Color expirationColor = theme.colorScheme.tertiary;
    if (trip.expiresAt != null) {
      final minutesLeft = trip.minutesRemaining;
      if (minutesLeft <= 0) {
        expirationColor = theme.colorScheme.error;
      } else if (minutesLeft <= 2) {
        expirationColor = theme.colorScheme.error;
      } else if (minutesLeft <= 4) {
        expirationColor = theme.colorScheme.tertiary;
      } else {
        expirationColor = theme.colorScheme.secondary;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.attach_money,
                      size: 18,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    label: Text('S/. ${trip.pricePerSeat.toStringAsFixed(2)}'),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      Icons.event_seat,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    label: Text('${trip.seatsBooked}/${trip.availableSeats} asientos'),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  // Badge de estado del viaje
                  _buildStatusChip(context),
                  // Badge de tiempo de expiración (solo para viajes esperando)
                  if (trip.isActive && trip.expiresAt != null)
                    Chip(
                      avatar: Icon(Icons.timer, size: 18, color: expirationColor),
                      label: Text(
                        trip.timeRemainingText,
                        style: TextStyle(
                          color: expirationColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: expirationColor.withOpacity(0.1),
                    ),
                ],
              ),
              const Divider(height: 20),
              _buildLocationRow(context, Icons.trip_origin, trip.origin.name, Colors.green),
              const SizedBox(height: 8),
              _buildLocationRow(context, Icons.place, trip.destination.name, Colors.red),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trip.driver.firstName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(trip.departureTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (trip.isInProgress) {
      statusText = 'En Proceso';
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.directions_car;
    } else if (trip.isFull) {
      statusText = 'Completo';
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.event_seat;
    } else if (trip.isExpired) {
      statusText = 'Expirado';
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.timer_off;
    } else if (trip.isCancelled) {
      statusText = 'Cancelado';
      statusColor = theme.colorScheme.outline;
      statusIcon = Icons.cancel;
    } else {
      statusText = 'Esperando';
      statusColor = theme.colorScheme.secondary;
      statusIcon = Icons.hourglass_empty;
    }

    return Chip(
      avatar: Icon(statusIcon, size: 18, color: statusColor),
      label: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: statusColor.withOpacity(0.1),
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}