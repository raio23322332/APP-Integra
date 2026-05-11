// lib/presentation/viewmodels/protocol/protocol_list_viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:integra_app/data/models/solicitacao_model.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/services/http/solicitacao_http.dart';
import 'package:integra_app/core/models/tipo_model.dart';
import 'package:integra_app/core/models/subt_tipo_model.dart';
import 'package:integra_app/core/constants/tipos_constants.dart';
import 'package:integra_app/core/helpers/console_log.dart';

// ✅ MVVM: ViewModel autocontido que gerencia seu próprio estado
class ProtocolListViewModel extends ChangeNotifier {
  final SolicitacaoHttp _solicitacaoHttp = SolicitacaoHttp();
  final AuthViewModel _authViewModel;
  final NavigationService _navigationService;

  // Stream para eventos
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  ProtocolListViewModel({
    required AuthViewModel authViewModel,
    required NavigationService navigationService,
  })  : _authViewModel = authViewModel,
        _navigationService = navigationService {
    // ✅ MVVM: Escuta mudanças no estado de autenticação
    _authViewModel.addListener(_onAuthStateChanged);
  }

  List<SolicitacaoModel> _requests = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedTipoId;
  String? _selectedSubtipoId;

  List<SolicitacaoModel> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authViewModel.isAuthenticated;
  dynamic get currentUser => _authViewModel.currentUser;
  String? get selectedTipoId => _selectedTipoId;
  String? get selectedSubtipoId => _selectedSubtipoId;
  
  // Getters para tipos e subtipos disponíveis
  List<TipoModel> get tiposDisponiveis => TiposConstants.data;
  
  List<SubtTipoModel> get subtiposDisponiveis {
    if (_selectedTipoId == null) return [];
    final tipo = TiposConstants.data.firstWhere(
      (t) => t.id == _selectedTipoId,
      orElse: () => TipoModel.empty(),
    );
    return tipo.subtipos;
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthStateChanged);
    _eventController.close();
    super.dispose();
  }

  // ✅ MVVM: Reage automaticamente às mudanças de autenticação
  void _onAuthStateChanged() {
    if (!_authViewModel.isAuthenticated) {
      // Limpa dados quando usuário faz logout
      _requests = [];
      _error = null;
      notifyListeners();
    }
  }

  // ✅ MVVM: Inicialização autocontida
  void initialize() {
    final userId = _authViewModel.currentUser?.id;
    if (userId != null && _authViewModel.isAuthenticated) {
      loadRequests();
    }
  }

  Future<void> loadRequests() async {
    if (!_authViewModel.isAuthenticated) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authViewModel.currentUser?.id?.toString();
      
      // Constrói parâmetros para a API
      Map<String, dynamic> queryParams = {};
      if (userId != null) {
        queryParams['user_id'] = userId;
      }
      if (_selectedTipoId != null) {
        queryParams['tipo_id'] = _selectedTipoId!;
      }
      if (_selectedSubtipoId != null) {
        queryParams['subtipo_id'] = _selectedSubtipoId!;
      }

      final response = await _solicitacaoHttp.solicitacoesComFiltros(
        tipoId: _selectedTipoId != null ? int.tryParse(_selectedTipoId!) : null,
        subtipoId: _selectedSubtipoId != null ? int.tryParse(_selectedSubtipoId!) : null,
        userId: userId,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<SolicitacaoModel> todasSolicitacoes = SolicitacaoModel.fromJsonList(jsonData);
        
        // Filtra pelo usuário autenticado
        if (userId != null) {
          _requests = todasSolicitacoes
              .where((solicitacao) => solicitacao.userId == userId)
              .toList();
        } else {
          _requests = todasSolicitacoes;
        }
        
        ConsoleLog.informacao('Carregadas ${_requests.length} solicitações do usuário');
      } else {
        _error = 'Erro ao carregar solicitações: ${response.statusCode}';
        _requests = [];
      }
    } catch (e) {
      ConsoleLog.error('Erro ao carregar solicitações: $e');
      _error = 'Erro ao carregar solicitações: $e';
      _requests = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTipoFilter(String? tipoId) {
    _selectedTipoId = tipoId;
    _selectedSubtipoId = null; // Limpa subtipo ao mudar tipo
    notifyListeners();
    loadRequests();
  }

  void setSubtipoFilter(String? subtipoId) {
    _selectedSubtipoId = subtipoId;
    notifyListeners();
    loadRequests();
  }

  void clearFilters() {
    _selectedTipoId = null;
    _selectedSubtipoId = null;
    notifyListeners();
    loadRequests();
  }

  void refresh() {
    loadRequests();
  }

  // ✅ MVVM: Navegação delegada para ViewModel
  void navigateToDetail(SolicitacaoModel request) {
    _navigationService.navigateTo(AppRoutes.ProtocolDetailPage, extra: request);
  }

  // Métodos auxiliares para formatação (lógica de apresentação)
  String extractProblemFromDescription(String? description) {
    if (description == null || description.isEmpty) return 'Sem descrição';
    
    // Tenta extrair problema antes do primeiro ponto
    final firstDot = description.indexOf('.');
    if (firstDot > 0) {
      return description.substring(0, firstDot).trim();
    }
    
    // Limita a 100 caracteres se não houver ponto
    return description.length > 100 
        ? '${description.substring(0, 100)}...' 
        : description;
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Data não disponível';
    
    try {
      final solicitacao = SolicitacaoModel(
        id: '0', // ID temporário para formatação
        dateTime: dateTime,
      );
      return solicitacao.dataBr;
    } catch (e) {
      ConsoleLog.error('Erro ao formatar data: $e');
      return 'Data inválida';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluído':
        return const Color(0xFF4b8c40);
      case 'em andamento':
        return const Color(0xFF248e95);
      case 'cancelado':
        return Colors.red;
      case 'pendente':
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'concluído':
        return FontAwesomeIcons.circleCheck;
      case 'em andamento':
        return FontAwesomeIcons.hourglassHalf;
      case 'cancelado':
        return FontAwesomeIcons.circleXmark;
      case 'pendente':
      default:
        return FontAwesomeIcons.clock;
    }
  }
}
