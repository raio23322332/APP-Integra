import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/veiculos_e_condutores/detran_services_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';
import 'package:provider/provider.dart';

class DetranServicesPage extends StatelessWidget {
  const DetranServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => DetranServicesViewModel(),
      child: Consumer<DetranServicesViewModel>(
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
                          onPressed: () => context.go('/veiculos-e-condutores'),
                        ),
                        const Text(
                          "Detran",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40), // Espaçamento para centralizar
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
                  // Breadcrumb
                  const Row(
                    children: [
                      Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text("Veículos e condutores", style: TextStyle(color: Color(0xFF374151), fontSize: 14)),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text("Detran", style: TextStyle(color: Color(0xFF374151), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Headline
                  Text(
                    "Acesse os serviços relacionados ao Detran",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ====================== CARDS ======================
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.services.length,
                    itemBuilder: (context, index) {
                      final service = viewModel.services[index];
                      return _itemCard(
                        context: context,
                        titulo: service['title'],
                        descricao: service['subtitle'],
                        onTap: () {
                        if (service['isWebView'] == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WebViewPage(
                                url: service['url'],
                                title: service['title'],
                              ),
                            ),
                          );
                        } else {
                          context.push(service['route']);
                        }
                      },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
    );
  }
}
