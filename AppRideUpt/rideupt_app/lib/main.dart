import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rideupt_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/providers/trip_provider.dart';
import 'package:rideupt_app/screens/auth/auth_wrapper.dart';
import 'package:rideupt_app/screens/onboarding/terms_conditions_screen.dart';
import 'package:rideupt_app/screens/onboarding/privacy_policy_screen.dart';
import 'package:rideupt_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiProvider para gestionar ambos providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // TripProvider depende de AuthProvider para obtener el token
        ChangeNotifierProxyProvider<AuthProvider, TripProvider>(
          create: (_) => TripProvider(null),
          update: (_, auth, previous) => TripProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Hop Hop - Conecta tu camino universitario',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/auth': (context) => const AuthWrapper(),
          '/terms': (context) => const TermsConditionsScreen(),
          '/privacy': (context) => const PrivacyPolicyScreen(),
        },
      ),
    );
  }
}