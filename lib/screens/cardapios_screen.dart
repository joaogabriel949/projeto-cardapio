import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cardapio.dart';

class CardapiosScreen extends StatefulWidget {
  const CardapiosScreen({super.key});

  @override
  State<CardapiosScreen> createState() => _CardapiosScreenState();
}

class _CardapiosScreenState extends State<CardapiosScreen> {
  List<Cardapio> _cardapios = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final lista = (await DatabaseHelper().getTodosCardapios())
          .map(Cardapio.fromMap)
          .toList();
      if (!mounted) return;
      setState(() {
        _cardapios = lista;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar cardápios.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápios Salvos', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildCorpo(textTheme),
    );
  }

  Widget _buildCorpo(TextTheme textTheme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_cardapios.isEmpty) {
      return Center(
        child: Text(
          'Nenhum cardápio salvo ainda.',
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cardapios.length,
      itemBuilder: (context, index) {
        final c = _cardapios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cardápio #${c.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildRefeicaoRow(
                    Icons.coffee_outlined, 'Café', c.cafeNome),
                _buildRefeicaoRow(
                    Icons.restaurant_outlined, 'Almoço', c.almocoNome),
                _buildRefeicaoRow(
                    Icons.dinner_dining_outlined, 'Jantar', c.jantaNome),
                if (c.pacienteNome != null) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(c.pacienteNome!,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefeicaoRow(IconData icone, String label, String? nome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              nome ?? 'Não definido',
              style: TextStyle(
                  color: nome == null ? Colors.grey : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
