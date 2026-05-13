import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefixText,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          counterText: '',
        ),
      ),
    );
  }
}
