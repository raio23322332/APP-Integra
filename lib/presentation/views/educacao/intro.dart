import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/educacao_viewmodel.dart';
import 'package:integra_app/presentation/views/webview_page.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';
import 'package:provider/provider.dart';

class SeducServicosPage extends StatelessWidget {
  const SeducServicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF137fec);

    final educacaoViewModel = Provider.of<EducacaoViewModel>(
      context,
      listen: false,
    );

    return EventSubscriber(
      viewModel: educacaoViewModel,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF101922)
            : const Color(0xFFF6F7F8),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
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
                    Expanded(
                      child: Center(
                        child: Text(
                          'Seduc',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Home > Educação > Seduc",
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : const Color(0xFF617589),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Acesse os serviços da Secretaria da Educação",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            _ServicoCard(
              icon: Icons.school,
              title: "Aluno online",
              description: "Consulte notas, frequência e comunicados.",
              primaryColor: primaryColor,
              isDark: isDark,
              onTap: educacaoViewModel.navigateToAlunoOnline,
            ),
            _ServicoCard(
              icon: Icons.co_present,
              title: "Professor online",
              description: "Acesse o diário de classe e materiais de apoio.",
              primaryColor: primaryColor,
              isDark: isDark,
              onTap: educacaoViewModel.navigateToProfessorOnline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ServicoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B2732) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: Colors.grey.shade800.withOpacity(0.8))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF617589),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}

/// ✅ EventSubscriber genérico para BaseViewModel (precisa ter `events`)
class EventSubscriber extends StatefulWidget {
  final dynamic
  viewModel; // BaseViewModel ou qualquer um que exponha Stream<ViewModelEvent>
  final Widget child;

  const EventSubscriber({
    super.key,
    required this.viewModel,
    required this.child,
  });

  @override
  State<EventSubscriber> createState() => _EventSubscriberState();
}

class _EventSubscriberState extends State<EventSubscriber> {
  StreamSubscription<ViewModelEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = (widget.viewModel.events as Stream<ViewModelEvent>).listen((
      event,
    ) {
      if (!mounted) return;

      if (event is OpenWebViewEvent) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WebViewPage(title: event.title, url: event.url),
          ),
        );
        return;
      }

      if (event is NavigationEvent) {
        context.push(event.route, extra: event.extra);
        return;
      }

      if (event is ShowSnackBarEvent) {
        if (event.isError) {
          CustomSnackBar.showError(context, event.message);
        } else {
          CustomSnackBar.showSuccess(context, event.message);
        }
        return;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
