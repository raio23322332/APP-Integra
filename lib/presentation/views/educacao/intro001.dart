import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/educacao_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/event_subscriber.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class EducacaoPage extends StatelessWidget {
  const EducacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final educacaoViewModel =
        Provider.of<EducacaoViewModel>(context, listen: false); // Access the ViewModel

    const primaryColor = Color(0xFFA413EC);
    final bgColor = isDark ? const Color(0xFF1C1022) : const Color(0xFFF7F6F8);
    final textColor = isDark ? Colors.white : Colors.black87;

    return EventSubscriber(
      viewModel: educacaoViewModel,
      child: Scaffold(
        backgroundColor: bgColor,
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
                    // Botão de voltar
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        if (GoRouter.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),

                    // Título
                    const Text(
                      'Educação',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    // Ícone
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(FontAwesomeIcons.graduationCap, size: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // conteúdo principal
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Home > Educação" estilo chips
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade300.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Home",
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Educação",
                        style: TextStyle(
                          color: Color(0xFF1F2D3D),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // título
                Text(
                  "Consulte os serviços relacionados à educação",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // grid de opções
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _ServicoCard(
                      icon: Icons.menu_book,
                      title: "Seduc",
                      subtitle: "Secretaria da Educação",
                      primaryColor: Color(0xFF3F4E63),
                      isDark: isDark,
                      onTap: () {
                        // Mostrar snack bar usando CustomSnackBar
                        CustomSnackBar.showSuccess(context, 'Abrindo Seduc...');

                        // Navegar para Seduc
                        context.push(AppRoutes.educacao);
                      },

                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ServicoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
