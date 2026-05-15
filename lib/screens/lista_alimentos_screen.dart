import 'package:flutter/material.dart';
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: _buildFoto(foto),
                  title: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Categoria: $categoria',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
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
