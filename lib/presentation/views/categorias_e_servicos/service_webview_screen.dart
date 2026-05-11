import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/categorias_e_servicos/service_webview_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/widgets/common/network_error_widget.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:provider/provider.dart';

/// ✅ WebView MVVM para serviços - botão "Abrir no Web"
class ServiceWebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const ServiceWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceWebViewViewModel(
        title: title,
        url: url,
      ),
      child: const _ServiceWebViewContent(),
    );
  }
}

class _ServiceWebViewContent extends StatefulWidget {
  const _ServiceWebViewContent();

  @override
  State<_ServiceWebViewContent> createState() => _ServiceWebViewContentState();
}

class _ServiceWebViewContentState extends State<_ServiceWebViewContent>
    with SingleTickerProviderStateMixin {
  StreamSubscription<ViewModelEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ServiceWebViewViewModel>();
      viewModel.setVsync(this); // ✅ Define o vsync para animações
      _eventSubscription = viewModel.events.listen(_handleEvent);
      
      // ✅ Mostra mensagem informativa igual ao WebViewPage
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          CustomSnackBar.showInfo(
            context,
            'Você está sendo redirecionado para o serviço externo',
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    switch (event) {
      case NavigateBackEvent():
        // ✅ Fecha a tela WebView
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
      default:
        debugPrint('Evento não tratado: ${event.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceWebViewViewModel>(
      builder: (context, viewModel, _) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await viewModel.handleBack();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(viewModel.title),
              actions: [
                // Botão de refresh (essencial)
                Consumer<ServiceWebViewViewModel>(
                  builder: (context, viewModel, _) => IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Recarregar página',
                    onPressed: () async {
                      await viewModel.webViewController.reload();
                    },
                  ),
                ),
              ],
              foregroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                tooltip: 'Voltar',
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: () => viewModel.handleBack(),
              ),
              titleSpacing: -16,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.lightBlue,
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                // WebView ou tela de erro
                if (viewModel.hasError)
                  NetworkErrorWidget(
                    customMessage: viewModel.errorMessage,
                    onRetry: () => viewModel.retry(),
                  )
                else
                  SlideTransition(
                    position: viewModel.slideAnimation,
                    child: WebViewWidget(controller: viewModel.webViewController),
                  ),
                
                // Loading indicator
                if (viewModel.isLoading && !viewModel.hasError)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
