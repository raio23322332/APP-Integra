import 'package:flutter/material.dart';
import '../../../data/models/sector_model.dart';
import '../auth/auth_viewmodel.dart';
import '../../../services/navigation_service.dart';
import '../../../services/http/sector_http.dart';

class SectorViewModel extends ChangeNotifier {
  final SectorHttp _http;
  final AuthViewModel _auth;
  final NavigationService _nav;

  List<SectorModel> _sectors = [];
  bool _loading = false;
  String? _error;
  bool _showInactive = false;

  SectorViewModel(this._http, this._auth, this._nav) {
    _auth.addListener(_onAuthChange);
  }

  List<SectorModel> get sectors => _sectors;
  bool get loading => _loading;
  String? get error => _error;
  bool get showInactive => _showInactive;

  void _onAuthChange() {
    if (!_auth.isAuthenticated) {
      _sectors.clear();
      notifyListeners();
    }
  }

  Future<void> loadSectors() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _sectors = await _http.getSectors(isActive: _showInactive ? null : true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleInactive() {
    _showInactive = !_showInactive;
    notifyListeners();
    return loadSectors();
  }

  Future<void> toggleStatus(String id) async {
    try {
      final sector = _sectors.firstWhere((s) => s.id == id);
      final updated = await _http.updateSector(id: id, isActive: !sector.isActive);
      
      final index = _sectors.indexWhere((s) => s.id == id);
      _sectors[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSector(String id) async {
    try {
      await _http.deleteSector(id);
      _sectors.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void goCreate() => _nav.navigateTo('/setores/create');
  void goEdit(SectorModel sector) => _nav.navigateTo('/setores/edit', extra: sector);

  void navigateToCreateSector() => _nav.navigateTo('/setores/create');
  void navigateToEditSector(SectorModel sector) => _nav.navigateTo('/setores/edit', extra: sector);

  @override
  void dispose() {
    _auth.removeListener(_onAuthChange);
    super.dispose();
  }
}
