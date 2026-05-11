import 'dart:async';
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class EmpregoViewModel extends ChangeNotifier {
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  void navigateToConcursosPublicos() {
    _eventController.add(
      const OpenWebViewEvent(
        title: "Concursos Públicos",
        url: "https://www.estrategiaconcursos.com.br/blog/concursos-pi/",
      ),
    );
  }

  void navigateToRadarOportunidades() {
    _eventController.add(
      const OpenWebViewEvent(
        title: "Radar de Oportunidades",
        url: "https://piauioportunidades.pi.gov.br/",
      ),
    );
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
