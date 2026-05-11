import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/views/reparo_iluminacao/iluminacao.dart';
import 'package:integra_app/presentation/views/reparo_iluminacao/iluminacao.dart';

class MulherAcolhimento extends StatelessWidget {
  const MulherAcolhimento({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => context.go('/servicos-mulher'), // volta pra home
                  ),

                  // Título
                  const Text(
                    'Consulta Acolhimento Mulher',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCQe8b0rcgumCw4AWQLtML_xiUPWdKEMUF5KmW-p2cOc8ykshUnyWOHfhbClPtJmISNfXsd7cXY13UjMhngr4b56_HbQBdwR3uEPTwG10JwLc3AJO3vR4XYQMZdnKgLviLD1RU1egu3nntoTkDM2vwr1u52cjJkWIcVEPUTlnQarIszi8tM2czo9ZzPPXuU1kmUrVYdnH97dZsfChTNn8GOwoGwqX7z6iPyD5B2UHXmWDlAyH-wUPdaa-nA2tgGHGF_zyn4Zih4dw',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: const [
                Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                Text(
                  "Mulheres",
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Serviço Não Digital",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 16),

            // Descrição
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.blue, width: 4),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Text(
                "É uma consulta sobre o acolhimento"
                "Institucional para mulheres em situação de violência doméstica e familiar"
                
                
                ,
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões de ação
            Column(
              children: [
                
                const SizedBox(height: 12),
                _ActionCard(
                  title: "Mais informações",
                  subtitle: "Encontre aqui mais informações sobre o serviço",
                  onTap: () {
                   context.go(AppRoutes.MulherAcolhimentoinfo);

                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
           
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: darkText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
