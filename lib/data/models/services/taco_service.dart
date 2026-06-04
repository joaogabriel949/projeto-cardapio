import 'dart:convert';
import 'package:flutter/services.dart';
import '../alimento_model.dart';

class TacoService {
  String _normalizeString(String text) {
    var withDia =
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ';
    var withoutDia =
        'AAAAAAACEEEEIIIIDNOOOOOOUUUUYaaaaaaaceeeeiiiidnoooooouuuuyby';
    for (int i = 0; i < withDia.length; i++) {
      text = text.replaceAll(withDia[i], withoutDia[i]);
    }
    return text.toLowerCase().trim();
  }

  Future<Map<String, dynamic>?> buscarDadosTacoBrutos(String nome) async {
    try {
      final String jsonString =
          await rootBundle.loadString('lib/database/taco_alimentos.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> alimentosTaco = jsonData['alimentos'];

      final String searchNormalized = _normalizeString(nome);
      final alimentoEncontrado = alimentosTaco.firstWhere(
        (item) {
          final String itemNomeNormalized =
              _normalizeString(item['nome'].toString());
          return itemNomeNormalized.contains(searchNormalized);
        },
        orElse: () => null,
      );

      return alimentoEncontrado != null ? Map<String, dynamic>.from(alimentoEncontrado) : null;
    } catch (e) {
      return null;
    }
  }

  Future<AlimentoModel?> buscarAlimentoLocal(String nome) async {
    final alimentoEncontrado = await buscarDadosTacoBrutos(nome);

    if (alimentoEncontrado != null) {
      final String catTaco =
          alimentoEncontrado['categoria']?.toString().trim() ?? '';
      final String tipoMapeado = AlimentoModel.autoMapearTipo([catTaco]);

      return AlimentoModel(
        nome: alimentoEncontrado['nome'],
        categoria: catTaco,
        tipo: tipoMapeado,
        calorias: (alimentoEncontrado['energia_kcal'] as num?)?.toDouble() ?? 0,
        proteinas: (alimentoEncontrado['proteina_g'] as num?)?.toDouble() ?? 0,
        carboidratos:
            (alimentoEncontrado['carboidrato_g'] as num?)?.toDouble() ?? 0,
        gordurasTotais:
            (alimentoEncontrado['gordura_g'] as num?)?.toDouble() ?? 0,
        sodio: (alimentoEncontrado['sodio_mg'] as num?)?.toDouble() ?? 0,
        calcio: (alimentoEncontrado['calcio_mg'] as num?)?.toDouble() ?? 0,
        ferro: (alimentoEncontrado['ferro_mg'] as num?)?.toDouble() ?? 0,
      );
    }
    return null;
  }
}
