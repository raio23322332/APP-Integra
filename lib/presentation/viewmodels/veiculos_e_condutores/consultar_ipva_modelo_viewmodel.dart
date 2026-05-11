import 'package:integra_app/presentation/viewmodels/base/base_viewmodel.dart';

class ConsultarIpvaModeloViewModel extends BaseViewModel {
  String? _modeloSelecionado;
  String? get modeloSelecionado => _modeloSelecionado;

  String? _anoSelecionado;
  String? get anoSelecionado => _anoSelecionado;

  void setModelo(String? value) {
    _modeloSelecionado = value;
    notifyListeners();
  }

  void setAno(String? value) {
    _anoSelecionado = value;
    notifyListeners();
  }
}
