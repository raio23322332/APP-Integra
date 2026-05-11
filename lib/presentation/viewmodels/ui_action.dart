abstract class UiAction {}

class ShowSnackAction extends UiAction {
  final String message;
  final bool isError;
  ShowSnackAction(this.message, {this.isError = false});
}

class NavigateAction extends UiAction {
  final String route;
  final Object? extra;
  NavigateAction(this.route, {this.extra});
}
