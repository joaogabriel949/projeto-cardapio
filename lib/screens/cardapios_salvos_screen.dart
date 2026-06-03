import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class CardapiosSalvosScreen extends StatefulWidget {
  const CardapiosSalvosScreen({super.key});

  @override
  State<CardapiosSalvosScreen> createState() => _CardapiosSalvosScreenState();
}

class _CardapiosSalvosScreenState extends State<CardapiosSalvosScreen> {
  late Future<List<Map<String, dynamic>>> _cardapiosCompletosFuture;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  void _carregarTudo() {
    setState(() {
      _cardapiosCompletosFuture = _buscarCardapiosCompletos();
    });
  }

  Future<List<Map<String, dynamic>>> _buscarCardapiosCompletos() async {
    final dbHelper = DatabaseHelper();
    final cardapiosBasicos = await dbHelper.getCardapios();
    
    List<Map<String, dynamic>> listaCompleta = [];
    
    for (var cardapio in cardapiosBasicos) {
      final completo = await dbHelper.getCardapioCompleto(cardapio['id']);
      if (completo != null) {
        listaCompleta.add(completo);
      }
    }
    return listaCompleta;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- BOTÃO DE VOLTAR ADICIONADO AQUI ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context); // Retorna para a Home
          },
        ),
        title: const Text('Meus Cardápios', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cardapiosCompletosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cardápio salvo ainda.\nCrie o seu primeiro!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final cardapios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cardapios.length,
            itemBuilder: (context, index) {
              final cardapio = cardapios[index];
              final refeicoes = cardapio['refeicoes'] as List;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- CABEÇALHO DO CARD COM BOTÃO DE EDITAR ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${cardapio['nome']} #${cardapio['id']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A00E0)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.orange, size: 28),
                            onPressed: () {
                              // Aviso temporário de que o botão foi clicado
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('A preparar edição do Cardápio #${cardapio['id']}')),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      ...refeicoes.map((refeicao) {
                        final itens = refeicao['itens'] as List;
                        final nomeAlimento = itens.isNotEmpty ? itens[0]['nome'] : 'Sem alimento';
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100, 
                                child: Text(refeicao['nome'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
                              ),
                              Expanded(child: Text(nomeAlimento, style: const TextStyle(fontSize: 15))),
                            ],
                          ),
                        );
                      }),
                    ],
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