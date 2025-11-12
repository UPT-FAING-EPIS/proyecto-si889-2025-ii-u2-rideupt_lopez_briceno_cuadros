import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: _getPrefixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Icon? _getPrefixIcon() {
    if (labelText.toLowerCase().contains('correo') || labelText.toLowerCase().contains('email')) {
      return const Icon(Icons.email_outlined);
    } else if (labelText.toLowerCase().contains('contraseña') || labelText.toLowerCase().contains('password')) {
      return const Icon(Icons.lock_outline);
    } else if (labelText.toLowerCase().contains('teléfono') || labelText.toLowerCase().contains('phone')) {
      return const Icon(Icons.phone_outlined);
    } else if (labelText.toLowerCase().contains('nombre')) {
      return const Icon(Icons.person_outline);
    } else if (labelText.toLowerCase().contains('universidad')) {
      return const Icon(Icons.school_outlined);
    } else if (labelText.toLowerCase().contains('id') || labelText.toLowerCase().contains('estudiante')) {
      return const Icon(Icons.badge_outlined);
    }
    return null;
  }
}