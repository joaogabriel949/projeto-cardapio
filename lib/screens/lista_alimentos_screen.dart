import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';

class ListaAlimentosScreen extends StatefulWidget {
  const ListaAlimentosScreen({super.key});

  @override
  State<ListaAlimentosScreen> createState() => _ListaAlimentosScreenState();
}

class _ListaAlimentosScreenState extends State<ListaAlimentosScreen> {
  late Future<List<Map<String, dynamic>>> _alimentosFuture;

  @override
  void initState() {
    super.initState();
    _carregarAlimentos();
  }

  void _carregarAlimentos() {
    _alimentosFuture = DatabaseHelper().getAlimentos();
  }

  Widget _buildFoto(String? foto) {
    if (foto == null || foto.trim().isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.fastfood, color: Colors.white),
      );
    }

    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(foto),
        onBackgroundImageError: (exception, stackTrace) {
          // Em caso de erro ao carregar a imagem da web
        },
      );
    }

    // Caso o usuário tenha digitado um caminho local ou texto aleatório, 
    // a gente exibe um ícone por padrão para evitar quebrar o app
    return const CircleAvatar(
      backgroundColor: Colors.orangeAccent,
      child: Icon(Icons.fastfood, color: Colors.white),
    );
  }

  void _mostrarDetalhesNutricionais(BuildContext context, Map<String, dynamic> alimento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildFoto(alimento['foto']),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alimento['nome'] ?? 'Sem Nome',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${alimento['categoria'] ?? ''} • ${alimento['tipo'] ?? ''}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          if (alimento['unidade_medida'] != null)
                            Text(
                              'Medição: ${alimento['unidade_medida']}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Informações Nutricionais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () => _compartilharAlimento(alimento),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNutriRow('Calorias', alimento['calorias'], 'kcal'),
                        _buildNutriRow('Proteínas', alimento['proteinas'], 'g'),
                        _buildNutriRow('Carboidratos', alimento['carboidratos'], 'g'),
                        _buildNutriRow('Gorduras Totais', alimento['gorduras_totais'], 'g'),
                        _buildNutriRow('Sódio', alimento['sodio'], 'mg'),
                        _buildNutriRow('Cálcio', alimento['calcio'], 'mg'),
                        _buildNutriRow('Ferro', alimento['ferro'], 'mg'),
                        if (alimento['nutri_score'] != null && alimento['nutri_score'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Nutri-Score', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getNutriScoreColor(alimento['nutri_score']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    alimento['nutri_score'].toString().toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutriRow(String label, dynamic value, String unit) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Color _getNutriScoreColor(String? score) {
    switch (score?.toUpperCase()) {
      case 'A': return Colors.green.shade800;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.yellow.shade700;
      case 'D': return Colors.orange;
      case 'E': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _compartilharAlimento(Map<String, dynamic> alimento) {
    try {
      final nome = alimento['nome'] ?? 'Sem Nome';
      final categoria = alimento['categoria'] ?? 'Sem Categoria';
      final tipo = alimento['tipo'] ?? 'Sem Tipo';
      final calorias = alimento['calorias'] ?? '0';
      final proteinas = alimento['proteinas'] ?? '0';
      final carboidratos = alimento['carboidratos'] ?? '0';
      final gorduras = alimento['gorduras_totais'] ?? '0';

      final texto = '''🍎 Alimento: $nome

Categoria: $categoria
Tipo: $tipo

Informações nutricionais:
Calorias: $calorias kcal
Proteínas: $proteinas g
Carboidratos: $carboidratos g
Gorduras: $gorduras g''';

      Share.share(texto);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentos Cadastrados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _alimentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar os dados.'),
            );
          }

          final alimentos = snapshot.data;

          if (alimentos == null || alimentos.isEmpty) {
            return Center(
              child: Text(
                'Nenhum alimento cadastrado ainda.',
                style: textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alimentos.length,
            itemBuilder: (context, index) {
              final alimento = alimentos[index];
              final String nome = alimento['nome'] ?? 'Sem Nome';
              final String categoria = alimento['categoria'] ?? 'Sem Categoria';
              final String? foto = alimento['foto'];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => _mostrarDetalhesNutricionais(context, alimento),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: () => _mostrarDetalhesNutricionais(context, alimento),
                    child: _buildFoto(foto),
                  ),
                  title: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categoria: $categoria',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (alimento['unidade_medida'] != null)
                        Text(
                          'Medição: ${alimento['unidade_medida']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      // Confirmação (opcional) ou exclusão direta
                      await DatabaseHelper().deleteAlimento(alimento['id']);
                      setState(() {
                        _carregarAlimentos(); // Recarrega a lista
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$nome excluído com sucesso!')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
