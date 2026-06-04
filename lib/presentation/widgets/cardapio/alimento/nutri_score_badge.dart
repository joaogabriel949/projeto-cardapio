import 'package:flutter/material.dart';

class NutriScoreBadge extends StatelessWidget {
  final String? nutriScore;

  const NutriScoreBadge({super.key, this.nutriScore});

  Color _corNutriScore(String? grade) {
    switch (grade?.toUpperCase()) {
      case 'A':
        return const Color(0xFF1B7A2B);
      case 'B':
        return const Color(0xFF50A63A);
      case 'C':
        return const Color(0xFFF5C400);
      case 'D':
        return const Color(0xFFE07800);
      case 'E':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasScore = nutriScore != null && nutriScore!.isNotEmpty;

    return Row(
      children: [
        const Text('Nutri-Score:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: hasScore ? _corNutriScore(nutriScore) : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hasScore ? nutriScore! : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
        if (!hasScore) ...[
          const SizedBox(width: 8),
          Text('Não disponível',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ],
    );
  }
}
