import 'package:flutter/material.dart';

class CampoNutricional extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unidade;
  final ValueChanged<String>? onChanged;

  const CampoNutricional({
    super.key,
    required this.label,
    required this.controller,
    this.unidade = 'g',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unidade,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
