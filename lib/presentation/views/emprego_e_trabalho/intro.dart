import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/emprego_viewmodel.dart';
import 'package:integra_app/presentation/views/webview_page.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';
import 'package:integra_app/presentation/widgets/common/service_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class TrabalhoEmpregoPage extends StatelessWidget {
  const TrabalhoEmpregoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final empregoViewModel = Provider.of<EmpregoViewModel>(context, listen: false);

    return EventSubscriber(
      viewModel: empregoViewModel,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),

        // ======== APP BAR PADRÃO ========
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
                      'Trabalho e emprego',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    // Ícone
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(FontAwesomeIcons.briefcase, size: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ======== CORPO ========
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BREADCRUMB
                Row(
                  children: const [
                    Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                    Text(
                      'Trabalho e emprego',
                      style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // DESCRIÇÃO
                Text(
                  "Consulte os serviços relacionados a trabalho e emprego",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),

                // GRADE DE SERVIÇOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ServiceCardWidget(
                        title: "Concursos Públicos",
                        icon: Icons.school, // Ícone original mantido
                        primaryColor: const Color(0xFF28669b),
                        onTap: empregoViewModel.navigateToConcursosPublicos,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ServiceCardWidget(
                        title: "Radar de Oportunidades",
                        icon: Icons.radar, // Ícone original mantido
                        primaryColor: const Color(0xFF28669b),
                        onTap: empregoViewModel.navigateToRadarOportunidades,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======== EVENT SUBSCRIBER ========
class EventSubscriber extends StatefulWidget {
  final EmpregoViewModel viewModel;
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

    _subscription = widget.viewModel.events.listen((event) {
      if (!mounted) return;

      if (event is OpenWebViewEvent) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => WebViewPage(
              title: event.title,
              url: event.url,
            ),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          ),
        );
      } else if (event is NavigationEvent) {
        context.push(event.route, extra: event.extra);
      } else if (event is ShowSnackBarEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor: event.isError ? Colors.red : Colors.green,
          ),
        );
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
