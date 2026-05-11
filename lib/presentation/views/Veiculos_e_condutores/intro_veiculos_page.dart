import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/veiculos_e_condutores/intro_veiculos_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IntroVeiculosPage extends StatelessWidget {
  const IntroVeiculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => IntroVeiculosViewModel(),
      child: Consumer<IntroVeiculosViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF28669b), Color(0xFF3FA9F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.go('/'),
                        ),
                        const Text(
                          "Veículos e Condutores",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Ícone
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(FontAwesomeIcons.car, size: 24, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BREADCRUMB
                  const Row(
                    children: [
                      Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text(
                        "Veículos e condutores",
                        style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // TÍTULO DA PÁGINA
                  Text(
                    "Consulte os serviços relacionados a veículos e condutores",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // GRADE DE SERVIÇOS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _ServicoCard(
                        icon: Icons.local_police,
                        title: "Detran",
                        onTap: () {
                          context.push('/detran');
                        },
                      ),
                      _ServicoCard(
                        icon: Icons.receipt_long,
                        title: "Meu IPVA",
                        onTap: () {
                          context.push('/meu-ipva');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServicoCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.lightIcon),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.lightPrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
