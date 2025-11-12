import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/widgets/auth_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'phone': _phoneController.text.trim(),
      'university': _universityController.text.trim(),
      'studentId': _studentIdController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final success = await authProvider.register(userData);

      if (!success && mounted) {
        _showErrorDialog(authProvider.errorMessage);
      } else if (success && mounted) {
        // Si el registro es exitoso, el AuthWrapper nos llevará a HomeScreen,
        // pero aquí cerramos la pantalla de registro para limpiar la pila de navegación.
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    String title = 'Error al Registrarse';
    String message = errorMessage;
    IconData icon = Icons.error;
    Color color = Colors.red;

    // Personalizar mensaje según el tipo de error
    if (errorMessage.contains('ya está en uso') || 
        errorMessage.contains('already exists') ||
        errorMessage.contains('duplicate')) {
      title = '📧 Email Ya Registrado';
      message = 'Este email ya está registrado en el sistema.\n\n'
                '💡 Opciones:\n'
                '• Usa otro email\n'
                '• Si es tu cuenta, ve a "Iniciar Sesión"\n'
                '• Si olvidaste tu contraseña, contacta a soporte';
      icon = Icons.email;
    } else if (errorMessage.contains('No se pudo conectar') || 
               errorMessage.contains('SocketException') ||
               errorMessage.contains('Connection')) {
      title = '🔴 Sin Conexión al Servidor';
      message = 'No se puede conectar al servidor backend.\n\n'
                '💡 Soluciones:\n'
                '• Verifica tu conexión a internet\n'
                '• El servidor puede estar apagado\n'
                '• Intenta de nuevo más tarde';
      icon = Icons.wifi_off;
      color = Colors.orange;
    } else if (errorMessage.contains('timeout')) {
      title = '⏱️ Tiempo de Espera Agotado';
      message = 'El servidor no respondió a tiempo.\n\n'
                'Intenta de nuevo en unos segundos.';
      icon = Icons.timer_off;
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
    // ... dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header con icono
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
                      Icons.person_add,
                      size: 50,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Únete a Hop Hop',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta de estudiante',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Formulario en tarjeta (responsivo)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Información personal
                          Text(
                            'Información Personal',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AuthFormField(controller: _firstNameController, labelText: 'Nombres'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthFormField(controller: _lastNameController, labelText: 'Apellidos'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AuthFormField(
                            controller: _emailController,
                            labelText: 'Correo Institucional',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Ingresa un correo';
                              if (!value.endsWith('@upt.pe') && !value.endsWith('@virtual.upt.pe')) {
                                return 'Debe ser un correo @upt.pe o @virtual.upt.pe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthFormField(
                            controller: _phoneController,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          // Información académica
                          Text(
                            'Información Académica',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthFormField(controller: _universityController, labelText: 'Universidad'),
                          const SizedBox(height: 16),
                          AuthFormField(controller: _studentIdController, labelText: 'ID de Estudiante'),
                          const SizedBox(height: 24),
                          // Seguridad
                          Text(
                            'Seguridad',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                                onPressed: () { setState(() { _passwordVisible = !_passwordVisible; }); },
                              ),
                            ),
                            obscureText: !_passwordVisible,
                            validator: (value) {
                              if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                onPressed: () { setState(() { _confirmPasswordVisible = !_confirmPasswordVisible; }); },
                              ),
                            ),
                            obscureText: !_confirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Repite tu contraseña';
                              if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          authProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : FilledButton.icon(
                                  onPressed: _submit,
                                  icon: const Icon(Icons.app_registration),
                                  label: const Text('REGISTRARSE'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}