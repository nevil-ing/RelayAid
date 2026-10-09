import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
