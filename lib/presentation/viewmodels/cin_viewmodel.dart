import 'package:flutter/foundation.dart';

class CinViewModel extends ChangeNotifier {
  String _appointmentType = 'pessoal';
  String get appointmentType => _appointmentType;

  void selectAppointmentType(String type) {
    _appointmentType = type;
    notifyListeners();
  }
}
