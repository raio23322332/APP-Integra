import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class EmitirCertidaoViewModel extends BaseViewModel {
  String _chassi = '';
  String get chassi => _chassi;

  void setChassi(String value) {
    _chassi = value;
    notifyListeners();
  }
}
