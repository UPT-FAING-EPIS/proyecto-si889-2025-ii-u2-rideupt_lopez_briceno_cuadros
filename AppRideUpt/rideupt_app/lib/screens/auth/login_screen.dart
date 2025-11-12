import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/screens/auth/register_screen.dart';
import 'package:rideupt_app/screens/home/main_navigation_screen.dart';
import 'package:rideupt_app/widgets/auth_form_field.dart';
import 'package:rideupt_app/widgets/google_signin_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(email, password);

    if (!success && mounted) {
      final errorMsg = authProvider.errorMessage;
      print('Login falló: $errorMsg'); // Debug
      _showErrorDialog(errorMsg, email);
    }
  }

  void _showErrorDialog(String errorMessage, String email) {
    String title = 'Error al Iniciar Sesión';
    String message = errorMessage;
    IconData icon = Icons.error;
    Color color = Colors.red;

    // Personalizar mensaje según el tipo de error
    if (errorMessage.contains('Correo o contraseña inválidos') || 
        errorMessage.contains('inválidos') ||
        errorMessage.contains('Invalid credentials')) {
      title = '❌ Credenciales Incorrectas';
      message = 'El email o la contraseña son incorrectos.\n\n'
                '📧 Email usado: $email\n\n'
                '💡 Verifica que:\n'
                '• El email esté en minúsculas\n'
                '• La contraseña sea correcta (mín. 6 caracteres)\n'
                '• No haya espacios extra';
      icon = Icons.lock;
    } else if (errorMessage.contains('No se pudo conectar') || 
               errorMessage.contains('SocketException') ||
               errorMessage.contains('Connection') ||
               errorMessage.toLowerCase().contains('network')) {
      title = '🔴 Sin Conexión al Servidor';
      message = 'No se puede conectar al servidor backend.\n\n'
                '💡 Posibles soluciones:\n\n'
                '1️⃣ Si usas servidor local:\n'
                '   • Ejecuta START_BACKEND.bat\n'
                '   • Verifica que diga "Puerto 3000"\n\n'
                '2️⃣ Verifica configuración:\n'
                '   • Abre app_config.dart\n'
                '   • Revisa _useServer y _serverIp\n\n'
                '3️⃣ Verifica tu conexión WiFi';
      icon = Icons.wifi_off;
      color = Colors.orange;
    } else if (errorMessage.contains('timeout') || 
               errorMessage.contains('Timeout')) {
      title = '⏱️ Tiempo de Espera Agotado';
      message = 'El servidor no respondió a tiempo.\n\n'
                '💡 Soluciones:\n'
                '• Verifica tu conexión a internet\n'
                '• El servidor puede estar sobrecargado\n'
                '• Intenta de nuevo en unos segundos';
      icon = Icons.timer_off;
      color = Colors.orange;
    } else if (errorMessage.isEmpty) {
      title = '⚠️ Error Desconocido';
      message = 'Ocurrió un error inesperado.\n\n'
                'Por favor, intenta de nuevo.\n\n'
                'Si el problema persiste, contacta a soporte.';
      icon = Icons.warning;
      color = Colors.orange;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, size: 48, color: color),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icono de la app
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bienvenido a Hop Hop',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // ==========================================
                    // GOOGLE SIGN-IN BUTTON
                    // ==========================================
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: GoogleSignInButton(
                          onSuccess: (userData) async {
                            // Manejo exitoso del login/registro con Google
                            print('✅ Google Sign-In exitoso: ${userData['email']}');
                            
                            try {
                              // Guardar token y datos del usuario en storage seguro
                              const storage = FlutterSecureStorage();
                              await storage.write(key: 'token', value: userData['token']);
                              await storage.write(key: 'userId', value: userData['_id']);
                              await storage.write(key: 'userRole', value: userData['role']);
                              
                              // Actualizar el AuthProvider con los datos
                              if (mounted) {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                
                                // Actualizar estado interno del provider
                                authProvider.setAuthData(
                                  userData['token'],
                                  userData['_id'],
                                  userData['role'],
                                );
                                
                                // Navegar a la pantalla principal
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                                  (route) => false,
                                );
                                
                                // Mostrar mensaje de bienvenida
                                if (userData['isNewUser'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('¡Bienvenido ${userData['firstName']}! 🎉'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              print('🔴 Error guardando datos: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al guardar datos: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          onError: (error) {
                            // Mostrar error
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                icon: const Icon(Icons.error, size: 48, color: Colors.red),
                                title: const Text('Error de Google Sign-In'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(error),
                                      const SizedBox(height: 16),
                                      const Text(
                                        '💡 Posibles soluciones:\n\n'
                                        '• Usa tu correo institucional @virtual.upt.pe\n'
                                        '• Verifica tu conexión a internet\n'
                                        '• Intenta de nuevo',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('ENTENDIDO'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider con "o"
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade400)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'o',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ==========================================
                    // FORMULARIO TRADICIONAL (Email/Password)
                    // ==========================================
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            AuthFormField(
                              controller: _emailController,
                              labelText: 'Correo Institucional',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || !value.contains('@')) return 'Ingresa un correo válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () {
                                    setState(() { _passwordVisible = !_passwordVisible; });
                                  },
                                ),
                              ),
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value == null || value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            authProvider.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : FilledButton.icon(
                                    onPressed: _submit,
                                    icon: const Icon(Icons.login),
                                    label: const Text('INICIAR SESIÓN'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('¿No tienes una cuenta? Regístrate'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}