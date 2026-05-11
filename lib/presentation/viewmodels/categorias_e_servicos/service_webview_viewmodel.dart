// lib/presentation/viewmodels/categorias_e_servicos/service_webview_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

/// ✅ MVVM: ViewModel para WebView de serviços
/// Centraliza lógica de navegação, estado de loading e animações
/// Específico para o botão "Abrir no Web" dos serviços
class ServiceWebViewViewModel extends ChangeNotifier {
  final String title;
  final String url;

  late final WebViewController webViewController;
  AnimationController? _animController;
  late Animation<Offset> _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDisposed = false;

  // Stream para eventos
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  // Getters para exposição de estado
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  Animation<Offset> get slideAnimation => _slideAnimation;

  ServiceWebViewViewModel({
    required this.title,
    required this.url,
  }) {
    _initializeWebView();
    // Animações serão inicializadas depois com setVsync
  }

  // ✅ Método para definir o vsync após a criação
  void setVsync(TickerProvider vsync) {
    _initializeAnimations(vsync);
  }

  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _resetErrorState();
            _isLoading = true;
            notifyListeners();
          },
          onPageFinished: (_) {
            _isLoading = false;
            notifyListeners();
          },
          onWebResourceError: (WebResourceError error) {
            // Tratar erros de carregamento (incluindo falta de conexão)
            _hasError = true;
            _isLoading = false;
            
            // Verificar se é erro de conexão baseado na descrição
            final errorDescription = error.description.toLowerCase();
            if (errorDescription.contains('network') ||
                errorDescription.contains('connection') ||
                errorDescription.contains('internet') ||
                errorDescription.contains('host') ||
                errorDescription.contains('timeout')) {
              _errorMessage = 'Não foi possível carregar a página. Verifique sua conexão com a internet e tente novamente.';
            } else {
              _errorMessage = 'Ocorreu um erro ao carregar a página: ${error.description}';
            }
            
            notifyListeners();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Permitir navegação para qualquer URL
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _resetErrorState() {
    _hasError = false;
    _errorMessage = '';
  }

  /// Método para tentar recarregar a página após erro
  Future<void> retry() async {
    _resetErrorState();
    await webViewController.reload();
  }

  void _initializeAnimations(TickerProvider? vsync) {
    if (vsync != null) {
      _animController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 500),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController!,
        curve: Curves.easeOutCubic,
      ));

      _animController!.forward();
      notifyListeners(); // ✅ Notifica mudança na animação
    } else {
      // Fallback se não houver vsync
      _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
    }
  }

  /// ✅ Trata navegação para trás (AppBar + Android)
  /// Botão de voltar da WebView ou botão voltar do dispositivo
  Future<void> handleBack() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
    } else {
      _emitEvent(NavigateBackEvent());
    }
  }

  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  @override
  void dispose() {
    _eventController.close();
    _animController?.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
