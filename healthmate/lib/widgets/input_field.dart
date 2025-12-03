import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final bool readOnly;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
