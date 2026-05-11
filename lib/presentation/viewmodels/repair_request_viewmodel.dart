import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:integra_app/data/dao/repair_request_dao.dart';
import 'package:integra_app/data/models/repair_request_model.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart' as ViewModelEvent;
import 'package:uuid/uuid.dart';


import 'package:image_picker/image_picker.dart';
import '../widgets/shared/view_model_event.dart';
import 'auth/auth_viewmodel.dart';

class RepairRequestViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  final RepairRequestDao _requestDao = RepairRequestDao(); // ALTERADO

  final Uuid _uuid = const Uuid();

  final _eventController = StreamController<ViewModelEvent.ViewModelEvent>.broadcast();
  Stream<ViewModelEvent.ViewModelEvent> get events => _eventController.stream;

  RepairRequestViewModel(this._authViewModel);

  String? _selectedProblem;
  String _description = '';
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successProtocol;
  String? _imagePath;

  String? get selectedProblem => _selectedProblem;
  String get description => _description;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successProtocol => _successProtocol;
  String? get imagePath => _imagePath;

  void selectProblem(String problem) {
    _selectedProblem = problem;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
  }

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
  }

  void clearProtocol() {
    _successProtocol = null;
    notifyListeners();
  }

  void clearImage() {
    _imagePath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _imagePath = image.path;
      notifyListeners();
    }
  }

  Future<void> submitRequest() async {
    _isLoading = true;
    _errorMessage = null;
    _successProtocol = null;
    notifyListeners();

    final userId = _authViewModel.currentUser?.id;

    if (userId == null) {
      _errorMessage = 'Usuário não autenticado. Por favor, faça login.';
      _eventController.add(ShowSnackBarEvent(
        _errorMessage!,
        isError: true,
      ));
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_selectedProblem == null || _latitude == null || _longitude == null) {
      _errorMessage = 'Selecione o tipo de problema e a localização no mapa.';
      _eventController.add(ShowSnackBarEvent(
        _errorMessage!,
        isError: true,
      ));
      _isLoading = false;
      notifyListeners();
      return;
    }

    final protocol = _uuid.v4().substring(0, 8).toUpperCase();

    final request = RepairRequest(
      userId: userId,
      protocol: protocol,
      description:
          'Problema: $_selectedProblem. Detalhes: $_description. Imagem: ${_imagePath ?? "Nenhuma"}',
      latitude: _latitude!,
      longitude: _longitude!,
      date: DateTime.now(),
    );

    try {
      await _requestDao.insertRepairRequest(request); // ALTERADO
      _successProtocol = protocol;
      // Emite um evento de navegação
      _eventController.add(ViewModelEvent.NavigationEvent(
          '/?success_message=Solicitação enviada! Protocolo: $_successProtocol'));
    } catch (e) {
      _errorMessage = 'Erro ao enviar a solicitação: $e';
      _eventController.add(ShowSnackBarEvent(_errorMessage!, isError: true));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTODO ADICIONADO PARA CORRIGIR O ERRO DE COMPILAÇÃO
  Future<List<RepairRequest>> getRequestsByUserId(int userId) async {
    return await _requestDao.getRequestsByUserId(userId);
  }
}
