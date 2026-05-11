import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:integra_app/core/errors/tenant_errors.dart';
import 'package:integra_app/core/navigation/navigation_constants.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/contracts/logout_service.dart';
import 'package:integra_app/domain/mappers/tenant_mapper.dart';
import 'package:integra_app/domain/usecases/tenant/get_tenants_usecase.dart';
import 'package:integra_app/domain/usecases/tenant/save_selected_tenant_usecase.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/navigation_service.dart';

class TenantSelectViewModel extends ChangeNotifier {
  final GetTenantsUseCase _getTenantsUseCase;
  final SaveSelectedTenantUseCase _saveSelectedTenantUseCase;
  final LogoutService _logoutService;
  final TenantConfigDao _tenantConfigDao;

  TenantSelectViewModel({
    required GetTenantsUseCase getTenantsUseCase,
    required SaveSelectedTenantUseCase saveSelectedTenantUseCase,
    required LogoutService logoutService,
    required TenantConfigDao tenantConfigDao,
  }) : _getTenantsUseCase = getTenantsUseCase,
       _saveSelectedTenantUseCase = saveSelectedTenantUseCase,
       _logoutService = logoutService,
       _tenantConfigDao = tenantConfigDao;
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;
  bool _isDisposed = false;
  @override
  void dispose() {
    _eventController.close();
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<Tenant> _allTenants = [];
  List<Tenant> _filteredTenants = [];
  List<Tenant> get tenants => _filteredTenants;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Tenant? _lastSelectedTenant;
  Tenant? get lastSelectedTenant => _lastSelectedTenant;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value.trim();
    _filterTenants();
    notifyListeners();
  }

  void _filterTenants() {
    if (_searchQuery.isEmpty) {
      _filteredTenants = List.from(_allTenants);
    } else {
      final query = _searchQuery.toLowerCase();
      final matchingTenants = _allTenants
          .where((tenant) => tenant.id.toLowerCase().contains(query))
          .toList();

      // If the first tenant (favorite) matches the search, keep it at the top
      if (matchingTenants.isNotEmpty &&
          _allTenants.isNotEmpty &&
          matchingTenants.first.id == _allTenants.first.id) {
        final favorite = matchingTenants.removeAt(0);
        matchingTenants.sort((a, b) => a.id.compareTo(b.id));
        _filteredTenants = [favorite, ...matchingTenants];
      } else {
        // No favorite in results, just sort alphabetically
        matchingTenants.sort((a, b) => a.id.compareTo(b.id));
        _filteredTenants = matchingTenants;
      }
    }
  }

  TenantError _mapError(dynamic error) {
    if (error is SocketException || error is HandshakeException) {
      return NetworkError('Sem conexão com a internet. Verifique sua rede.');
    } else if (error is TimeoutException) {
      return TimeoutError('Tempo limite excedido. Tente novamente.');
    } else if (error is FormatException) {
      return ValidationError('Dados recebidos estão corrompidos.');
    } else if (error is TenantError) {
      return error;
    } else {
      return UnknownError(error);
    }
  }

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();
      // ✅ REMOVIDO: logout automático que estava causando problema no fluxo de login
      // O logout deve ser chamado apenas quando o usuário explicitamente solicita
      final tenantEntities = await _getTenantsUseCase.execute();
      _allTenants = TenantMapper.toModelList(tenantEntities);
      _allTenants.sort((a, b) => a.id.compareTo(b.id));

      // Put last selected tenant at the top
      _lastSelectedTenant = await _tenantConfigDao.getSelectedTenant();
      if (_lastSelectedTenant != null) {
        _allTenants.removeWhere(
          (tenant) => tenant.id == _lastSelectedTenant!.id,
        );
        _allTenants.insert(0, _lastSelectedTenant!);
      }

      _filteredTenants = List.from(_allTenants);
    } on SocketException catch (e) {
      final error = NetworkError(
        'Sem conexão com a internet. Verifique sua rede.',
      );
      ConsoleLog.error(
        "TenantSelectViewModel.init [NETWORK_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
    } on TimeoutException catch (e) {
      final error = TimeoutError(
        'Tempo limite excedido ao carregar municípios.',
      );
      ConsoleLog.error(
        "TenantSelectViewModel.init [TIMEOUT_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
    } on FormatException catch (e) {
      final error = ValidationError('Dados dos municípios estão corrompidos.');
      ConsoleLog.error(
        "TenantSelectViewModel.init [VALIDATION_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
    } catch (err) {
      final error = _mapError(err);
      ConsoleLog.error(
        "TenantSelectViewModel.init [${error.code}]: ${error.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAndSaveTenant({required Tenant tenant}) async {
    try {
      _emitEvent(ShowSnackBarEvent('Salvando seleção...', isError: false));
      final tenantEntity = TenantMapper.toEntity(tenant);
      await _saveSelectedTenantUseCase.execute(tenantEntity);
      NavigationService.instance.navigateTo(
        NavigationConstants.login,
        extra: tenant,
      );
    } on SocketException catch (e) {
      final error = NetworkError('Sem conexão para salvar seleção.');
      ConsoleLog.error(
        "TenantSelectViewModel.selectAndSaveTenant [NETWORK_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
      rethrow;
    } on TimeoutException catch (e) {
      final error = TimeoutError('Tempo limite ao salvar seleção.');
      ConsoleLog.error(
        "TenantSelectViewModel.selectAndSaveTenant [TIMEOUT_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
      rethrow;
    } on FormatException catch (e) {
      final error = ValidationError('Dados do município estão inválidos.');
      ConsoleLog.error(
        "TenantSelectViewModel.selectAndSaveTenant [VALIDATION_ERROR]: ${e.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
      rethrow;
    } catch (err) {
      final error = _mapError(err);
      ConsoleLog.error(
        "TenantSelectViewModel.selectAndSaveTenant [${error.code}]: ${error.message}",
      );
      _emitEvent(ShowSnackBarEvent(error.message, isError: true));
      rethrow;
    }
  }

  void _emitEvent(ViewModelEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}
