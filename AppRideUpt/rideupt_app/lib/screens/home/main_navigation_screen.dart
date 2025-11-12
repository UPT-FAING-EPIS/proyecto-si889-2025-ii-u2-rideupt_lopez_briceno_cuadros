// lib/screens/home/main_navigation_screen.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/screens/home/home_screen.dart';
import 'package:rideupt_app/screens/home/driver_home_screen.dart';
import 'package:rideupt_app/screens/profile/profile_screen.dart';
import 'package:rideupt_app/screens/trips/my_trips_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isDriver = user?.role == 'driver';

    // Pantallas diferentes según el rol
    final List<Widget> widgetOptions = isDriver
        ? [
            const DriverHomeScreen(), // Conductores ven "Mi Viaje"
            const MyTripsScreen(),    // Historial de viajes
            const ProfileScreen(),    // Perfil
          ]
        : [
            const HomeScreen(),       // Pasajeros ven "Buscar Viaje"
            const MyTripsScreen(),    // Mis reservas
            const ProfileScreen(),    // Perfil
          ];

    // Items de navegación diferentes según el rol
    final List<BottomNavigationBarItem> navItems = isDriver
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Mi Viaje',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar Viaje',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Mis Reservas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}