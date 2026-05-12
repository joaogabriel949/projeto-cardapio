import 'package:flutter/material.dart';

class ConsultarScreen extends StatelessWidget {
  const ConsultarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final foods = [
      {'name': 'Hambúrguer Artesanal', 'kcal': '650 kcal'},
      {'name': 'Salada Caesar com Frango', 'kcal': '320 kcal'},
      {'name': 'Fatia de Pizza Margherita', 'kcal': '280 kcal'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encontre informações nutricionais.', style: textTheme.bodyLarge),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Buscar alimento...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: foods.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return Card(
                    child: ListTile(
                      title: Text(food['name']!, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      trailing: Chip(
                        label: Text(food['kcal']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
