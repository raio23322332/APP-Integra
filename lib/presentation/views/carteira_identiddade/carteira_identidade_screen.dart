import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CarteiraIdentidadeScreen extends StatelessWidget {
  const CarteiraIdentidadeScreen({super.key});

  final primaryGreen = const Color(0xFF4b8c40);
  final textDark = const Color(0xFF263860);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    tooltip: 'Voltar',
                    onPressed: () {
                      // Evita erro de pop quando não há páginas
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/carteira-identidade-intro'); // Rota segura caso seja a primeira tela
                      }
                    },
                  ),
                  // Título
                  const Text(
                    'Carteira de Identidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  // Ícone
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(FontAwesomeIcons.idCard, size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  ' > Carteira de Identidade',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Acesse os serviços relacionados a carteira de Identidade',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            _buildServiceCard(
              context,
              title: 'Quero solicitar a Carteira de Identidade Nacional (CIN)',
              subtitle: 'Agende o pedido da 1ª ou da 2ª via da CIN.',
              onTap: () => context.go(AppRoutes.CinAvisoAgendamentoPage),
            ),
            const SizedBox(height: 16),

            _buildServiceCard(
              context,
              title: 'Acompanhar pedido da CIN',
              subtitle:
                  'Acompanhe em que etapa está o pedido da sua Carteira de Identidade Nacional.',
              onTap: () => context.go(AppRoutes.CinAcompanhamentoPage),
            ),
            const SizedBox(height: 16),

            _buildServiceCard(
              context,
              title: 'Ver CIN digitalizada',
              subtitle:
                  'Veja a versão digitalizada da sua Carteira de Identidade Nacional.',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
