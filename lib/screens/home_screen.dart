import 'package:flutter/material.dart';
import 'novo_alimento_screen.dart';
import 'login_screen.dart';
import 'consultar_screen.dart';
import 'novo_paciente_screen.dart';
import 'criar_cardapio_screen.dart';
import 'buscar_usuarios_screen.dart';
import 'cardapios_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('NutriGo', style: textTheme.displayMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Text('Acesso Rápido', style: textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Novo Paciente',
              subtitle: 'Cadastrar perfil',
              icon: Icons.person_add_alt_1,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NovoPacienteScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Novo Alimento',
              subtitle: 'Adicionar à base',
              icon: Icons.restaurant_menu,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NovoAlimentoScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Criar Cardápio',
              subtitle: 'Montar plano alimentar personalizado',
              icon: Icons.edit_note,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CriarCardapioScreen())),
            ),
            const SizedBox(height: 32),
            Text('Consultas', style: textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Buscar Usuários',
              subtitle: 'Histórico e perfis',
              icon: Icons.people_outline,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuscarUsuariosScreen())),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Tabela de Alimentos',
              subtitle: 'Valores nutricionais',
              icon: Icons.table_chart_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConsultarScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Cardápios Salvos',
              subtitle: 'Modelos e planos anteriores',
              icon: Icons.save_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardapiosScreen())),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Semantics(
      label: '$title, $subtitle',
      button: true,
      child: Card(
        child: ListTile(
          leading: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
          ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
  }
}
