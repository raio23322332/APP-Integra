import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class PagarIpvaViewModel extends BaseViewModel {
  String _placa = '';
  String get placa => _placa;

  String _renavam = '';
  String get renavam => _renavam;

  void setPlaca(String value) {
    _placa = value;
    notifyListeners();
  }

  void setRenavam(String value) {
    _renavam = value;
    notifyListeners();
  }
}
