import 'package:flutter/material.dart';

class NovoAlimentoScreen extends StatefulWidget {
  const NovoAlimentoScreen({super.key});

  @override
  State<NovoAlimentoScreen> createState() => _NovoAlimentoScreenState();
}

class _NovoAlimentoScreenState extends State<NovoAlimentoScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Cadastro', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Adicionar Alimento', style: textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Preencha os dados nutricionais do novo alimento.', style: textTheme.bodyLarge),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nome do Alimento',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Calorias (kcal)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Carboidratos (g)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Proteínas (g)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Gorduras (g)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Fibras (g)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('SALVAR ALIMENTO'),
            ),
          ],
        ),
      ),
    );
  }
}
