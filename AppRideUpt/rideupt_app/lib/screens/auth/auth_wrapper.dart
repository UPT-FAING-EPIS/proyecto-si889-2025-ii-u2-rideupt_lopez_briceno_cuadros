// lib/screens/auth/auth_wrapper.dart (CORREGIDO)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/screens/auth/new_login_screen.dart';
import 'package:rideupt_app/screens/home/main_navigation_screen.dart';
import 'package:rideupt_app/screens/onboarding/onboarding_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si el onboarding no se ha completado, mostrar pantalla de bienvenida
        if (!snapshot.data!) {
          return const OnboardingScreen();
        }

        // Si el onboarding está completo, proceder con la lógica de autenticación
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Si el usuario está autenticado, muestra la pantalla principal
            if (authProvider.isAuthenticated) {
              return const MainNavigationScreen();
            }

            // Si no, verifica si hay un token guardado para auto-login
            return FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) {
                // Mientras espera, muestra un indicador de carga
                if (authResultSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                // Si el auto-login falla o no hay token, muestra la pantalla de Login
                return const NewLoginScreen();
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}