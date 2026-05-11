import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class ConsultarIpvaViewModel extends BaseViewModel {
  String _placa = '';
  String get placa => _placa;

  void setPlaca(String value) {
    _placa = value;
    notifyListeners();
  }
}
