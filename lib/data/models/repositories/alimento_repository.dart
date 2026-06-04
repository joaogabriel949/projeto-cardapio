import '../../../database/db_helper.dart';
import '../alimento_model.dart';

class AlimentoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> salvarAlimento(AlimentoModel alimento) async {
    return await _dbHelper.insertAlimento(alimento.toMap());
  }

  Future<List<AlimentoModel>> buscarAlimentosSalvos({
    String? searchTerm,
    String? categoria,
    String? tipo,
    String? nutriScore,
  }) async {
    final maps = await _dbHelper.getAlimentos(
      searchTerm: searchTerm,
      categoria: categoria,
      tipo: tipo,
      nutriScore: nutriScore,
    );
    return maps.map((map) => AlimentoModel.fromMap(map)).toList();
  }

  Future<int> excluirAlimento(int id) async {
    return await _dbHelper.deleteAlimento(id);
  }
}
