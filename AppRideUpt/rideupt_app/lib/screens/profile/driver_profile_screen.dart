import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rideupt_app/providers/auth_provider.dart';
import 'package:rideupt_app/widgets/auth_form_field.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _seatsController = TextEditingController(text: '4'); // Por defecto 4 asientos

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vehicleData = {
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.parse(_yearController.text.trim()),
      'color': _colorController.text.trim(),
      'licensePlate': _licensePlateController.text.trim(),
      'seats': int.parse(_seatsController.text.trim()),
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateDriverProfile(vehicleData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil de conductor actualizado!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Conductor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Completa los datos de tu vehículo',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AuthFormField(controller: _makeController, labelText: 'Marca (ej. Toyota)'),
              const SizedBox(height: 16),
              AuthFormField(controller: _modelController, labelText: 'Modelo (ej. Yaris)'),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _yearController,
                labelText: 'Año',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || int.tryParse(val) == null || val.length != 4) return 'Año inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(controller: _colorController, labelText: 'Color'),
              const SizedBox(height: 16),
              AuthFormField(controller: _licensePlateController, labelText: 'Placa'),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _seatsController,
                labelText: 'Número de asientos disponibles',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Campo requerido';
                  final seats = int.tryParse(val);
                  if (seats == null || seats < 1 || seats > 20) {
                    return 'Debe ser entre 1 y 20 asientos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('GUARDAR DATOS Y CONVERTIRME EN CONDUCTOR'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}