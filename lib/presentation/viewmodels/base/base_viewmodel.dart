import 'dart:async';
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

abstract class BaseViewModel extends ChangeNotifier {
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  void emitEvent(ViewModelEvent event) {
    _eventController.add(event);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
