import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/screens/profile/driver_profile_screen.dart';
import 'package:rideupt_app/screens/profile/edit_profile_screen.dart';
import 'package:rideupt_app/widgets/profile_info_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      // Esto puede pasar brevemente durante el logout
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Avatar
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                  style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Nombre completo centrado
          Text(
            '${user.firstName} ${user.lastName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Email
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Badge del rol
          Center(
            child: Chip(
              avatar: Icon(
                user.role == 'driver' ? Icons.directions_car : Icons.person,
                size: 18,
                color: user.role == 'driver' 
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              label: Text(
                user.role == 'driver' ? 'CONDUCTOR' : 'PASAJERO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: user.role == 'driver' 
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              backgroundColor: user.role == 'driver' 
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          
          // Información personal
          ProfileInfoTile(icon: Icons.phone, title: 'Teléfono', subtitle: user.phone),
          ProfileInfoTile(icon: Icons.school, title: 'Universidad', subtitle: user.university),
          ProfileInfoTile(icon: Icons.badge, title: 'Código', subtitle: user.studentId),
          const Divider(height: 32),
          if (user.role == 'driver' && user.vehicle != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información del Vehículo', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ProfileInfoTile(icon: Icons.directions_car, title: 'Vehículo', subtitle: '${user.vehicle!.make} ${user.vehicle!.model} (${user.vehicle!.year})'),
                    ProfileInfoTile(icon: Icons.palette, title: 'Color', subtitle: user.vehicle!.color),
                    ProfileInfoTile(icon: Icons.pin, title: 'Placa', subtitle: user.vehicle!.licensePlate),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Botón de editar perfil
          OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('EDITAR PERFIL'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Convertirse en conductor
          if (user.role == 'passenger')
            FilledButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('CONVERTIRSE EN CONDUCTOR'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DriverProfileScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          // Botón de cerrar sesión
          TextButton.icon(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            label: Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
            onPressed: () async {
              // Confirmar cierre de sesión
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('CANCELAR'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('CERRAR SESIÓN'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await authProvider.logout();
                // El AuthWrapper manejará la navegación automáticamente
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}