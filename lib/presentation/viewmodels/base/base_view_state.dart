// lib/presentation/viewmodels/base/base_view_state.dart

/// Estado base para gerenciamento consistente de estado em ViewModels
/// Usa sealed classes para garantir exhaustividade no pattern matching
sealed class ViewState<T> {
  const ViewState();

  /// Estado inicial (antes de qualquer operação)
  const factory ViewState.initial() = InitialViewState<T>;

  /// Estado de carregamento
  const factory ViewState.loading() = LoadingViewState<T>;

  /// Estado de sucesso com dados
  const factory ViewState.success(T data) = SuccessViewState<T>;

  /// Estado de erro com mensagem opcional e dados anteriores
  const factory ViewState.error(String message, {T? data}) = ErrorViewState<T>;

  /// Executa uma função baseada no tipo de estado
  R map<R>({
    required R Function(InitialViewState<T>) initial,
    required R Function(LoadingViewState<T>) loading,
    required R Function(SuccessViewState<T>) success,
    required R Function(ErrorViewState<T>) error,
  }) {
    if (this is InitialViewState<T>) {
      return initial(this as InitialViewState<T>);
    } else if (this is LoadingViewState<T>) {
      return loading(this as LoadingViewState<T>);
    } else if (this is SuccessViewState<T>) {
      return success(this as SuccessViewState<T>);
    } else if (this is ErrorViewState<T>) {
      return error(this as ErrorViewState<T>);
    }
    throw StateError('Unknown state type');
  }

  /// Executa uma função apenas se for sucesso, retorna null caso contrário
  R? mapOrNull<R>({
    R Function(SuccessViewState<T>)? success,
    R Function(ErrorViewState<T>)? error,
  }) {
    if (this is SuccessViewState<T> && success != null) {
      return success(this as SuccessViewState<T>);
    } else if (this is ErrorViewState<T> && error != null) {
      return error(this as ErrorViewState<T>);
    }
    return null;
  }
}

/// Estado inicial
class InitialViewState<T> extends ViewState<T> {
  const InitialViewState();
}

/// Estado de carregamento
class LoadingViewState<T> extends ViewState<T> {
  const LoadingViewState();
}

/// Estado de sucesso com dados
class SuccessViewState<T> extends ViewState<T> {
  final T data;
  const SuccessViewState(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessViewState<T> &&
      runtimeType == other.runtimeType &&
      data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Estado de erro
class ErrorViewState<T> extends ViewState<T> {
  final String message;
  final T? data; // Dados anteriores em caso de erro

  const ErrorViewState(this.message, {this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorViewState<T> &&
      runtimeType == other.runtimeType &&
      message == other.message &&
      data == other.data;

  @override
  int get hashCode => message.hashCode ^ (data?.hashCode ?? 0);
}

/// Extension methods para facilitar o uso de ViewState
extension ViewStateExt<T> on ViewState<T> {
  /// Verifica se está carregando
  bool get isLoading => this is LoadingViewState<T>;

  /// Verifica se foi bem-sucedido
  bool get isSuccess => this is SuccessViewState<T>;

  /// Verifica se houve erro
  bool get isError => this is ErrorViewState<T>;

  /// Verifica se tem dados disponíveis
  bool get hasData => map(
        initial: (_) => false,
        loading: (_) => false,
        success: (_) => true,
        error: (state) => state.data != null,
      );

  /// Retorna os dados se disponíveis, null caso contrário
  T? get dataOrNull => map(
        initial: (_) => null,
        loading: (_) => null,
        success: (state) => state.data,
        error: (state) => state.data,
      );

  /// Retorna a mensagem de erro se houver
  String? get errorMessage => mapOrNull(
        error: (state) => state.message,
      );

  /// Converte para string para debug
  String get debugString => map(
        initial: (_) => 'Initial',
        loading: (_) => 'Loading',
        success: (_) => 'Success',
        error: (state) => 'Error: ${state.message}',
      );
}

/// Classe auxiliar para estados que não precisam de dados genéricos
sealed class SimpleViewState {
  const SimpleViewState();

  const factory SimpleViewState.initial() = InitialSimpleState;
  const factory SimpleViewState.loading() = LoadingSimpleState;
  const factory SimpleViewState.success() = SuccessSimpleState;
  const factory SimpleViewState.error(String message) = ErrorSimpleState;
}

class InitialSimpleState extends SimpleViewState {
  const InitialSimpleState();
}

class LoadingSimpleState extends SimpleViewState {
  const LoadingSimpleState();
}

class SuccessSimpleState extends SimpleViewState {
  const SuccessSimpleState();
}

class ErrorSimpleState extends SimpleViewState {
  final String message;
  const ErrorSimpleState(this.message);
}

extension SimpleViewStateExt on SimpleViewState {
  bool get isLoading => this is LoadingSimpleState;
  bool get isSuccess => this is SuccessSimpleState;
  bool get isError => this is ErrorSimpleState;

  String? get errorMessage =>
      this is ErrorSimpleState ? (this as ErrorSimpleState).message : null;

  String get debugString {
    if (this is InitialSimpleState) return 'Initial';
    if (this is LoadingSimpleState) return 'Loading';
    if (this is SuccessSimpleState) return 'Success';
    if (this is ErrorSimpleState) return 'Error: ${(this as ErrorSimpleState).message}';
    return 'Unknown';
  }
}
