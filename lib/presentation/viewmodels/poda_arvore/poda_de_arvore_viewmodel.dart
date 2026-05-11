// lib/presentation/viewmodels/poda_arvore/poda_de_arvore_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/services/poda_de_arvore/image_service.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';

class PodaDeArvoreViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  final ImageService _imageService;

  PodaDeArvoreViewModel(this._authViewModel, this._imageService);

  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  // ✅ CONTROLLERS NO VIEWMODEL
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // ✅ DADOS NO VIEWMODEL
  final List<String> problemOptions = const [
    'Galhos caindo',
    'Risco de queda',
    'Árvore muito grande',
    'Árvore morta',
    'Outro',
  ];

  // ✅ COORDENADAS (poderiam vir de um LocationService)
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedProblem;
  String? get selectedProblem => _selectedProblem;

  String? _imagePath;
  String? get imagePath => _imagePath;

  void initialize() {
    // Inicializar coordenadas (simuladas por enquanto)
    _latitude = -3.7319;
    _longitude = -38.5267;
  }

  void setSelectedProblem(String? value) {
    _selectedProblem = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final path = await _imageService.pickFromGallery();
      if (path != null) {
        _imagePath = path;
        notifyListeners();
        _emit(const ShowSnackBarEvent('Imagem selecionada com sucesso!'));
      }
    } catch (e) {
      _emit(ShowSnackBarEvent('Erro ao selecionar imagem: $e', isError: true));
      if (kDebugMode) debugPrint('pickImage error: $e');
    }
  }

  Future<void> submitRequest() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      if (!_authViewModel.isAuthenticated) {
        _emit(const ShowSnackBarEvent('Faça login para enviar a solicitação.', isError: true));
        return;
      }

      final address = addressController.text.trim();
      final description = descriptionController.text.trim();

      if (address.isEmpty) {
        _emit(const ShowSnackBarEvent('O endereço é obrigatório.', isError: true));
        return;
      }

      if (_selectedProblem == null) {
        _emit(const ShowSnackBarEvent('Selecione o tipo de problema.', isError: true));
        return;
      }

      if (_latitude == null || _longitude == null) {
        _emit(const ShowSnackBarEvent('Localização não disponível.', isError: true));
        return;
      }

      await Future.delayed(const Duration(seconds: 2));

      _emit(const ShowSnackBarEvent('Solicitação enviada com sucesso!'));

      // Reset form
      clearForm();
      
      _emit(const NavigationEvent(AppRoutes.home));

    } catch (e) {
      _emit(ShowSnackBarEvent('Erro ao enviar solicitação: $e', isError: true));
      if (kDebugMode) debugPrint('submitRequest error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearForm() {
    descriptionController.clear();
    addressController.clear();
    _selectedProblem = null;
    _imagePath = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _emit(ViewModelEvent event) {
    if (!_eventController.isClosed) _eventController.add(event);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    addressController.dispose();
    _eventController.close();
    super.dispose();
  }
}