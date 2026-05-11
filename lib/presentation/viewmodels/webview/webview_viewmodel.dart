// lib/presentation/viewmodels/webview/webview_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/navigation_service.dart';

/// ✅ MVVM: ViewModel para WebView
/// Centraliza lógica de navegação, estado de loading e animações
class WebViewViewModel extends ChangeNotifier {
  final String title;
  final String url;

  late final WebViewController webViewController;
  AnimationController? _animController;
  late Animation<Offset> _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);

  bool _isLoading = true;
  bool _isDisposed = false;

  // Stream para eventos
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  // Getters para exposição de estado
  bool get isLoading => _isLoading;
  Animation<Offset> get slideAnimation => _slideAnimation;

  WebViewViewModel({
    required this.title,
    required this.url,
    NavigationService? navigationService, // Opcional já que não usamos
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
            _isLoading = true;
            notifyListeners();
          },
          onPageFinished: (_) {
            _isLoading = false;
            notifyListeners();
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
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
