// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';
import 'package:integra_app/core/navigation/custom_transitions.dart';
import 'package:integra_app/presentation/providers/breadcrumb_provider.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

/// Serviço de navegação para desacoplar ViewModels do BuildContext
/// Permite que ViewModels façam navegação sem violar princípios de arquitetura MVVM
///
/// ✅ CORREÇÕES IMPLEMENTADAS (13/01/2026):
/// - Adicionado método pushTo() para navegação que empilha rotas
/// - Alterado navigateToServiceDetails() para usar pushTo() em vez de navigateTo()
/// - Alterado navigateToServices() para usar pushTo() para manter pilha de navegação
/// - Alterado back buttons em services_screen.dart, login.dart, register_page.dart para usar goBack()
/// - Alterado navegação login/tenancy para usar pushTo() para manter pilha de navegação
/// - Isso corrige o botão "Voltar" físico/virtual do Android que agora volta corretamente em todo o app
class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance {
    _instance ??= NavigationService._internal();
    return _instance!;
  }

  NavigationService._internal();

  GoRouter? _router;

  /// Define o router do GoRouter (chamado uma vez na inicialização do AppRouter)
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// Navega para uma rota específica
  void navigateTo(String route, {Object? extra}) {
    if (_router != null) {
      _router!.go(route, extra: extra);
    } else {
      debugPrint('NavigationService: Router not initialized');
    }
  }

  /// Navega para uma rota específica usando push (empilha na navegação)
  void pushTo(String route, {Object? extra}) {
    // debugPrint('🧭 NavigationService - pushTo chamado');
    // debugPrint('🧭 Route: $route');
    // debugPrint('🧭 Extra: ${extra.toString()}');
    
    if (_router != null) {
      _router!.push(route, extra: extra);
    } else {
      debugPrint('NavigationService: Router not initialized');
    }
  }

  /// Navega para uma rota e remove todas as rotas anteriores da pilha
  void navigateToAndRemoveUntil(String route, {Object? extra}) {
    if (_router != null) {
      _router!.go(route, extra: extra);
      // Note: go_router handles route replacement differently
      // If you need to clear history, consider using GoRouter's redirect
    } else {
      debugPrint('NavigationService: Router not initialized');
    }
  }

  /// Volta para a rota anterior
  void goBack() {
    if (_router != null) {
      _router!.pop();
    } else {
      debugPrint('NavigationService: Router not initialized');
    }
  }

  /// Verifica se pode voltar
  bool canGoBack() {
    // GoRouter doesn't expose canPop directly, so we'll assume true
    // This could be improved by tracking navigation state
    return true;
  }

  /// ✅ NOVO: Navegação específica para detalhes de serviço
  void navigateToServiceDetail(dynamic service) {
    navigateTo(AppRoutes.serviceDetail, extra: service);
  }

  /// ✅ NOVO: Navegação para login com tenant
  void navigateToLogin(dynamic tenant) {
    navigateTo(AppRoutes.login, extra: tenant);
  }

  /// ✅ NOVO: Navegação para home
  void navigateToHome() {
    navigateTo(AppRoutes.home);
  }

  // ========================================
  // 🚀 NOVO: NAVEGAÇÃO COM TRANSIÇÕES FLUIDAS
  // ========================================

  /// Navega com transição customizada usando Navigator (para transições avançadas)
  Future<void> navigateWithTransition(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideRight,
    bool fullscreenDialog = false,
  }) async {
    final route = transition.buildRoute(page);
    await Navigator.of(context).push(route);
  }

  /// Navega para tela de serviço com transição hero (detalhes)
  Future<void> navigateToServiceWithHero(BuildContext context, Widget servicePage) async {
    await navigateWithTransition(
      context,
      servicePage,
      transition: PageTransitionType.materialHero,
    );
  }

  /// Navega para webview com transição slide up
  Future<void> navigateToWebView(BuildContext context, Widget webViewPage) async {
    await navigateWithTransition(
      context,
      webViewPage,
      transition: PageTransitionType.slideUp,
    );
  }

  /// Navega para tela de sucesso com bounce effect
  Future<void> navigateToSuccess(BuildContext context, Widget successPage) async {
    await navigateWithTransition(
      context,
      successPage,
      transition: PageTransitionType.bounceIn,
    );
  }

  /// Navega para modal com fade e scale
  Future<void> navigateToModal(BuildContext context, Widget modalPage) async {
    await navigateWithTransition(
      context,
      modalPage,
      transition: PageTransitionType.fadeScale,
    );
  }

  /// Substitui tela atual com transição customizada
  Future<void> replaceWithTransition(
    BuildContext context,
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideRight,
  }) async {
    final route = transition.buildRoute(page);
    await Navigator.of(context).pushReplacement(route);
  }

  /// Navega com transição baseada no tipo de conteúdo
  Future<void> navigateByContentType(
    BuildContext context,
    Widget page,
    String contentType, {
    Object? extra,
  }) async {
    PageTransitionType transition;

    // Define transição baseada no tipo de conteúdo
    switch (contentType) {
      case 'service_detail':
      case 'category_detail':
        transition = PageTransitionType.materialHero;
        break;
      case 'webview':
      case 'external_link':
        transition = PageTransitionType.slideUp;
        break;
      case 'success':
      case 'confirmation':
        transition = PageTransitionType.bounceIn;
        break;
      case 'modal':
      case 'popup':
        transition = PageTransitionType.fadeScale;
        break;
      case 'special':
      case 'onboarding':
        transition = PageTransitionType.rotateIn;
        break;
      default:
        transition = PageTransitionType.slideRight;
    }

    await navigateWithTransition(context, page, transition: transition);
  }

  // ========================================
  // 🧭 BREADCRUMB NAVIGATION METHODS
  // ========================================

  /// Navega para serviços de uma categoria com breadcrumb
  void navigateToServices(BuildContext context, dynamic category) {
    final provider = context.read<BreadcrumbProvider>();
    provider.setBreadcrumbs([
      const BreadcrumbItem(title: 'Home', route: AppRoutes.home),
      BreadcrumbItem(
        title: category.name ?? 'Categoria',
        route: AppRoutes.services,
        extra: category,
      ),
    ]);
    pushTo(AppRoutes.services, extra: category);
    provider.sendBreadcrumbToApi(); // Envia para API
  }

  /// Navega para detalhes do serviço com breadcrumb
  void navigateToServiceDetails(dynamic service, dynamic category) {
    debugPrint('🧭 NavigationService - navigateToServiceDetails chamado');
    debugPrint('🧭 Service: ${service?.title}');
    debugPrint('🧭 Category: ${category?.name}');
    
    // Note: BreadcrumbProvider will be accessed via context in the screen
    pushTo(AppRoutes.serviceDetail, extra: {'service': service, 'category': category});
  }

  /// Limpa breadcrumbs ao voltar para home
  void navigateToHomeWithBreadcrumbClear(BuildContext context) {
    final provider = context.read<BreadcrumbProvider>();
    provider.clear();
    navigateToHome();
  }

  /// Volta com breadcrumb
  void goBackWithBreadcrumb(BuildContext context) {
    final provider = context.read<BreadcrumbProvider>();
    provider.removeLast();
    goBack();
    provider.sendBreadcrumbToApi(); // Atualiza API
  }
}
