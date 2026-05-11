import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class ValidarCertidaoViewModel extends BaseViewModel {
  String _chassi = '';
  String get chassi => _chassi;

  String _certidao = '';
  String get certidao => _certidao;

  void setChassi(String value) {
    _chassi = value;
    notifyListeners();
  }

  void setCertidao(String value) {
    _certidao = value;
    notifyListeners();
  }
}
