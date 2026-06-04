import 'package:flutter/material.dart';

class SecaoNutricional extends StatelessWidget {
  final String titulo;
  final List<Widget> campos;
  final Color corPrimaria;

  const SecaoNutricional({
    super.key,
    required this.titulo,
    required this.campos,
    required this.corPrimaria,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: corPrimaria,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...campos,
      ],
    );
  }
}
