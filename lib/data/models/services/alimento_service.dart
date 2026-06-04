import '../alimento_model.dart';
import 'taco_service.dart';
import 'open_food_facts_service.dart';

class AlimentoService {
  final TacoService _tacoService = TacoService();
  final OpenFoodFactsService _offService = OpenFoodFactsService();

  Future<Map<String, dynamic>> buscarAlimento(String nome) async {
    if (nome.trim().isEmpty) return {'alimento': null, 'origem': null};

    // 1. Tenta buscar no banco local (TACO)
    AlimentoModel? alimento = await _tacoService.buscarAlimentoLocal(nome);

    if (alimento != null) {
      // Busca os dados brutos extras (como as unidades específicas) para retornar para a UI
      final dadosBrutos = await _tacoService.buscarDadosTacoBrutos(nome);
      return {
        'alimento': alimento,
        'origem': 'TACO',
        'unidades': dadosBrutos?['unidades']
      };
    }

    // 2. Se não achar, vai na API remota
    alimento = await _offService.buscarAlimentoRemoto(nome);
    if (alimento != null) {
      return {'alimento': alimento, 'origem': 'API'};
    }

    // Não encontrado
    return {'alimento': null, 'origem': null};
  }
}
