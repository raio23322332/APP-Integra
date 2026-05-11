import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/veiculos_e_condutores/meu_ipva_viewmodel.dart';
import 'package:provider/provider.dart';

class MeuIPVATela extends StatelessWidget {
  const MeuIPVATela({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => MeuIpvaViewModel(),
      child: Consumer<MeuIpvaViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF111827)
                : const Color(0xFFF3F4F6),
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
                    ),
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
                          onPressed: () => context.go('/veiculos-e-condutores')

                        ),
                        const Text(
                          "Meu IPVA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
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
                  const Row(
                    children: [
                      Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text(
                        "Veículos e condutores",
                        style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text(
                        "Meu IPVA",
                        style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Acesse serviços ligados ao IPVA",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightPrimaryText,
                    ),
                  ),

                  const SizedBox(height: 24),

                  ...viewModel.services.map((service) {
                    return _itemCard(
                      context: context,
                      titulo: service['titulo']!,
                      descricao: service['descricao']!,
                      onTap: () => context.push(service['rota']!),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------- WIDGET CARD ------------------------------
  Widget _itemCard({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.grey.shade800 : const Color(0xFFE5E7EB),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF137FEC),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descricao,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
