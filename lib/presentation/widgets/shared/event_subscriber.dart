import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';

class EventSubscriber extends StatefulWidget {
  final BaseViewModel viewModel;
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

      // debug: log every event received
      // ignore: avoid_print
      print('EventSubscriber: received event -> ${event.runtimeType}');

      if (event is TopSnackBarEvent) {
        // Only TopSnackBarEvent should use the custom top snack bar.
        // ignore: avoid_print
        print('EventSubscriber: handling TopSnackBarEvent -> ${event.message}');
        // hide any scaffold/snack currently visible (e.g. 'Autenticando...')
        try {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        } catch (_) {}
        if (event.isError) {
          AppLoader.hide(context);
          CustomSnackBar.showError(context, event.message);
        } else {
          CustomSnackBar.showSuccess(context, event.message);
        }
        return;
      }

      if (event is ShowSnackBarEvent) {
        // Default snackbar behavior for generic events.
        // ignore: avoid_print
        print('EventSubscriber: showing scaffold snackbar -> ${event.message}');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (event.isError) {
          AppLoader.hide(context);
          CustomSnackBar.showError(context, event.message);
        } else {
          CustomSnackBar.showSuccess(context, event.message);
        }
        return;
      }

      if (event is NavigationEvent) {
        AppLoader.hide(context);
        context.go(event.route, extra: event.extra);
        return;
      }

      if (event is OpenWebViewEvent) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewPage(title: event.title, url: event.url),
          ),
        );
        return;
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
