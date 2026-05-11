// lib/presentation/widgets/shared/view_state_builder.dart

import 'package:flutter/material.dart';
import 'package:integra_app/presentation/viewmodels/base/base_view_state.dart';


/// Widget builder para estados ViewState
/// Fornece uma forma consistente de renderizar diferentes estados da UI
class ViewStateBuilder<T> extends StatelessWidget {
  final ViewState<T> state;
  final Widget Function()? initialBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function(T data)? successBuilder;
  final Widget Function(String message, T? data)? errorBuilder;

  const ViewStateBuilder({
    super.key,
    required this.state,
    this.initialBuilder,
    this.loadingBuilder,
    this.successBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return state.map(
      initial: (_) => initialBuilder?.call() ?? const SizedBox.shrink(),
      loading: (_) => loadingBuilder?.call() ?? _buildDefaultLoading(),
      success: (successState) => successBuilder?.call(successState.data) ?? _buildDefaultSuccess(successState.data),
      error: (errorState) => errorBuilder?.call(errorState.message, errorState.data) ?? _buildDefaultError(errorState.message),
    );
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultSuccess(T data) {
    return Center(
      child: Text('Dados carregados: $data'),
    );
  }

  Widget _buildDefaultError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Widget builder para estados SimpleViewState
class SimpleViewStateBuilder extends StatelessWidget {
  final SimpleViewState state;
  final Widget Function()? initialBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function()? successBuilder;
  final Widget Function(String message)? errorBuilder;

  const SimpleViewStateBuilder({
    super.key,
    required this.state,
    this.initialBuilder,
    this.loadingBuilder,
    this.successBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (state is InitialSimpleState) {
      return initialBuilder?.call() ?? const SizedBox.shrink();
    } else if (state is LoadingSimpleState) {
      return loadingBuilder?.call() ?? _buildDefaultLoading();
    } else if (state is SuccessSimpleState) {
      return successBuilder?.call() ?? _buildDefaultSuccess();
    } else if (state is ErrorSimpleState) {
      final errorState = state as ErrorSimpleState;
      return errorBuilder?.call(errorState.message) ?? _buildDefaultError(errorState.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultSuccess() {
    return const Center(
      child: Icon(Icons.check_circle, size: 48, color: Colors.green),
    );
  }

  Widget _buildDefaultError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar loading com overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(loadingMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension para usar ViewStateBuilder diretamente em ViewState
extension ViewStateBuilderExtension<T> on ViewState<T> {
  Widget build({
    Widget Function()? initialBuilder,
    Widget Function()? loadingBuilder,
    Widget Function(T data)? successBuilder,
    Widget Function(String message, T? data)? errorBuilder,
  }) {
    return ViewStateBuilder<T>(
      state: this,
      initialBuilder: initialBuilder,
      loadingBuilder: loadingBuilder,
      successBuilder: successBuilder,
      errorBuilder: errorBuilder,
    );
  }
}

/// Extension para usar SimpleViewStateBuilder diretamente em SimpleViewState
extension SimpleViewStateBuilderExtension on SimpleViewState {
  Widget build({
    Widget Function()? initialBuilder,
    Widget Function()? loadingBuilder,
    Widget Function()? successBuilder,
    Widget Function(String message)? errorBuilder,
  }) {
    return SimpleViewStateBuilder(
      state: this,
      initialBuilder: initialBuilder,
      loadingBuilder: loadingBuilder,
      successBuilder: successBuilder,
      errorBuilder: errorBuilder,
    );
  }
}
