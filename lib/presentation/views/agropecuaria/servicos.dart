import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/config/app_config.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/views/webview_page.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';



class ProdutorRuralPage extends StatelessWidget {
  const ProdutorRuralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () {
                    if (GoRouter.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  ),
                  const Text(
                    "Produtor Rural",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(FontAwesomeIcons.wheatAwn, size: 24, color: Colors.white), // Ícone de agropecuária no canto direito
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
            const Row(
              children: [
                Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                Text(
                  "Agropecuária",
                  style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                Text(
                  "Produtor Rural",
                  style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Text(
              "Acesse os serviços da Agência de Defesa Agropecuária ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightPrimaryText,
              ),
            ),
            const SizedBox(height: 24),

            _ActionCard(
              title: "Cadastrar produtor rural",
              subtitle:
                  "Preencha o formulário para se cadastrar como produtor rural",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewPage(
                      title: "Cadastro de Produtor Rural",
                      url: AppConfig.cadastroProdutor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: "Declarar vacinação contra febre aftosa",
              subtitle:
                  "Emita na hora a declaração de vacinação contra a febre aftosa",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewPage(
                      title: "Declaração de Vacinação",
                      url: AppConfig.declaracaoVacina,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: "Solicitar 2ª via de DAE",
              subtitle:
                  "Solicite a 2ª via do documento de arrecadação estadual (DAE) de serviços da Adagri",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewPage(
                      title: "2ª Via de DAE",
                      url: AppConfig.segundaViaDae,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightPrimaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppColors.lightSecondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
