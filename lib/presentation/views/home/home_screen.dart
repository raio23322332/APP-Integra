// lib/presentation/views/integra_home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';

import 'package:integra_app/services/category_service.dart';
import 'package:integra_app/services/domain/domain_service.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/services/navigation_service.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/home/home_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/favorite_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ✅ MVVM: Widgets separados importados
import '../../widgets/home/welcome_section_widget.dart';
import '../../widgets/home/home_content_widget.dart';

class IntegraHomePage extends StatelessWidget {
  final Widget? child;

  const IntegraHomePage({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // ✅ MVVM: Agora usa o HomeViewModel global provido pelo InitProvider
    // Isso evita que o estado seja reiniciado toda vez que voltamos para a Home
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _eventSubscription;
  
  // ✅ GlobalKey para controlar o campo de busca
  final GlobalKey<WelcomeSectionWidgetState> _welcomeSectionKey = GlobalKey();

  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final accentOrange = const Color(0xFFD5692B);
  final highlightTeal = const Color(0xFF248e95);
  final lightBackground = const Color(0xFFecf2f2);
  final textDark = const Color(0xFF263860);
  final text = const Color(0xFF1F2D3D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      homeVM.init();
      context.read<FavoriteViewModel>().loadFavorites();

      _eventSubscription = homeVM.events.listen(_handleEvent);

      // ✅ CORREÇÃO: Mostrar snackbar de sucesso apenas uma vez após login
      final authVM = context.read<AuthViewModel>();
      print('🏠 HomeScreen: Verificando justLoggedIn=${authVM.justLoggedIn}');
      debugPrint('🔍 HomeScreen: justLoggedIn=${authVM.justLoggedIn}');
      if (authVM.justLoggedIn) {
        print('✅ HomeScreen: Vai mostrar snackbar de sucesso');
        debugPrint('🔍 HomeScreen: Vai mostrar snackbar de sucesso');
        // Usar Future.microtask para evitar conflitos com o build
        Future.microtask(() {
          if (mounted) {
            print('📱 HomeScreen: Chamando showLoginSuccessSnackBar');
            debugPrint('🔍 HomeScreen: Chamando showLoginSuccessSnackBar');
            authVM.showLoginSuccessSnackBar(context);
          }
        });
      }
      
      // Limpa campo de busca ao iniciar a home
      // _searchController.clear(); // ✅ COMENTADO: Pode estar ativando o campo
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Limpa busca quando a home recebe foco (volta de outras telas)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      homeVM.onFocusGained();
      
      // ✅ Desativa campo de busca ao voltar para home
      WelcomeSectionWidget.disableSearchField(_welcomeSectionKey);
    });
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    debugPrint('🔍 HomeScreen._handleEvent: Recebeu evento=${event.runtimeType}');
    // CORREÇÃO: Evitar acessar ViewModel após dispose
    // O context.read pode falhar se o Provider foi disposed
    try {
      final homeVM = context.read<HomeViewModel>();

      switch (event) {
        case ShowSnackBarEvent():
          debugPrint('🔍 HomeScreen: ShowSnackBarEvent isError=${event.isError} message="${event.message}"');
          // MVVM: Usar CustomSnackBar para snackbars consistentes
          // ✅ MVVM: Usar CustomSnackBar para snackbars consistentes
          if (event.isError) {
            debugPrint('🔍 HomeScreen: Mostrando snackbar de erro');
            CustomSnackBar.showError(context, event.message);
          } else {
            debugPrint('🔍 HomeScreen: Mostrando snackbar de sucesso');
            CustomSnackBar.showSuccess(context, event.message);
          }
          break;
        case CategoryTappedEvent():
          // ✅ MVVM: Navegar para tela de serviços da categoria (empilhar)
          homeVM.navigationService.pushTo('/services', extra: event.category);
          break;
        case NavigationEvent():
          if (event.extra != null) {
            context.go(event.route, extra: event.extra);
          } else {
            context.go(event.route);
          }
          break;
        case OpenWebViewEvent():
          // Para webview, você pode navegar para uma tela específica
          _openWebView(event);
          break;
        default:
          debugPrint('Evento não tratado: ${event.runtimeType}');
      }
    } catch (e) {
      // ✅ CORREÇÃO: Capturar erro se ViewModel foi disposed
      debugPrint('[HomeScreen] ViewModel disposed, ignorando evento: $e');
    }
  }

  void _openWebView(OpenWebViewEvent event) {
    // Ou use o GoRouter se tiver rota definida
    context.push('/webview', extra: {
      'title': event.title,
      'url': event.url,
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Na Home o comportamento padrão de sair do app é mantido
        if (didPop) return;
      },
      child: GestureDetector(
      onTap: () {
        // ✅ Fecha teclado ao clicar em qualquer lugar da tela
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeSectionWidget(
                  key: _welcomeSectionKey, // ✅ Adicionada GlobalKey para controle externo
                  homeVM: homeVM,
                  searchController: _searchController,
                ),
                const HomeContentWidget(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: highlightTeal,
          onPressed: () {},
          child: const Icon(FontAwesomeIcons.whatsapp, color: Color(0xFFF9FAFB)),
        ),
        bottomNavigationBar: null,
      ),
      ),
    );
  }








}
