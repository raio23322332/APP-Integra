// lib/presentation/viewmodels/view_model_event.dart
import 'package:integra_app/data/models/category_model.dart' as models;


sealed class ViewModelEvent {
  const ViewModelEvent();
}

class NavigationEvent extends ViewModelEvent {
  final String route;
  final Object? extra;

  const NavigationEvent(this.route, {this.extra});
}

class ShowSnackBarEvent extends ViewModelEvent {
  final String message;
  final bool isError;

  const ShowSnackBarEvent(this.message, {this.isError = false});
}

class ShowNoInternetDialogEvent extends ViewModelEvent {
  final String? message;

  const ShowNoInternetDialogEvent({this.message});
}

/// A top snackbar event that should be displayed using the custom
/// top-positioned snack bar (e.g. `CustomSnackBar`). Use this for
/// special cases like login success where a different UI is desired.
class TopSnackBarEvent extends ViewModelEvent {
  final String message;
  final bool isError;

  const TopSnackBarEvent(this.message, {this.isError = false});
}

class OpenWebViewEvent extends ViewModelEvent {
  final String title;
  final String url;

  const OpenWebViewEvent({required this.title, required this.url});
}

// ============================================================
// EVENTOS ESPECÍFICOS DA HOME (adicionados no MESMO arquivo)
// ============================================================

class CategoryTappedEvent extends ViewModelEvent {
  final models.Category category;

  const CategoryTappedEvent(this.category);
}

// Se precisar de um evento específico para resultado de busca
class SearchResultTappedEvent extends ViewModelEvent {
  final models.Service service;

  const SearchResultTappedEvent(this.service);
}

// ============================================================
// EVENTOS ESPECÍFICOS DAS CATEGORIAS (categories module)
// ============================================================

class CategorySelectedEvent extends ViewModelEvent {
  final models.Category category;

  const CategorySelectedEvent(this.category);
}

// ============================================================
// EVENTOS DO MÓDULO DE PERFIL
// ============================================================

class NavigateToLoginEvent extends ViewModelEvent {
  const NavigateToLoginEvent();
}

// ============================================================
// EVENTOS DO MÓDULO DE WEBVIEW
// ============================================================

class NavigateBackEvent extends ViewModelEvent {
  const NavigateBackEvent();
}
