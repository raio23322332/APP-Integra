import 'package:flutter/material.dart';
import '../../../data/models/protocol_model.dart';
import '../auth/auth_viewmodel.dart';
import '../../../services/navigation_service.dart';
import '../../../services/http/protocol_http.dart';

class ProtocolViewModel extends ChangeNotifier {
  final ProtocolHttp _http;
  final AuthViewModel _auth;
  final NavigationService _nav;

  List<ProtocolModel> _protocols = [];
  bool _loading = false;
  String? _error;

  ProtocolViewModel(this._http, this._auth, this._nav) {
    _auth.addListener(_onAuthChange);
  }

  List<ProtocolModel> get protocols => _protocols;
  bool get loading => _loading;
  String? get error => _error;

  void _onAuthChange() {
    if (!_auth.isAuthenticated) {
      _protocols.clear();
      notifyListeners();
    }
  }

  Future<void> loadProtocols() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _protocols = await _http.getProtocols();
      // Ordenar por registeredAt descendente (mais recentes primeiro), igual ao web
      _protocols.sort((a, b) {
        if (a.registeredAt == null && b.registeredAt == null) return 0;
        if (a.registeredAt == null) return 1;
        if (b.registeredAt == null) return -1;
        return DateTime.parse(b.registeredAt!).compareTo(DateTime.parse(a.registeredAt!));
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createProtocol(Map<String, dynamic> data) async {
    try {
      await _http.createProtocol(
        sectorId: data['sectorId'],
        direction: data['direction'],
        subject: data['subject'],
        documentType: data['documentType'],
        notes: data['notes'],
        originProtocol: data['originProtocol'],
        originAgency: data['originAgency'],
        isConfidential: data['isConfidential'] ?? false,
        isEmergency: data['isEmergency'] ?? false,
        registeredAt: data['registeredAt'],
      );
      
      // Recarregar a lista para manter a ordenação correta
      await loadProtocols();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProtocol(String id, Map<String, dynamic> data) async {
    try {
      await _http.updateProtocol(
        id,
        documentType: data['documentType'] ?? '',
        subject: data['subject'] ?? '',
        notes: data['notes'],
      );
      
      // Recarregar a lista para obter dados atualizados
      await loadProtocols();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelProtocol(String id, {required String reason}) async {
    try {
      final updated = await _http.cancelProtocol(id, reason: reason);
      
      final index = _protocols.indexWhere((p) => p.id == id);
      if (index != -1) {
        _protocols[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveProtocol(String id, {String? message}) async {
    try {
      final updated = await _http.archiveProtocol(id, message: message);
      
      final index = _protocols.indexWhere((p) => p.id == id);
      if (index != -1) {
        _protocols[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> forwardProtocol(String id, {required String toSectorId, String? message}) async {
    try {
      final updated = await _http.forwardProtocol(id, toSectorId: toSectorId, message: message);
      
      final index = _protocols.indexWhere((p) => p.id == id);
      _protocols[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> receiveProtocol(String id, {String? message}) async {
    try {
      final updated = await _http.receiveProtocol(id, message: message);
      
      final index = _protocols.indexWhere((p) => p.id == id);
      _protocols[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> commentProtocol(String id, {required String message}) async {
    try {
      final updated = await _http.commentProtocol(id, message: message);
      
      final index = _protocols.indexWhere((p) => p.id == id);
      _protocols[index] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void goDetail(ProtocolModel protocol) => _nav.pushTo('/protocolos/detail', extra: protocol);
  void goCreate() => _nav.pushTo('/protocolos/create');

  void navigateToProtocolDetail(ProtocolModel protocol) => _nav.pushTo('/protocolos/detail', extra: protocol);
  void navigateToCreateProtocol() => _nav.pushTo('/protocolos/create');

  void navigateToProtocolForward(ProtocolModel protocol) => _nav.pushTo('/protocolos/forward', extra: protocol);
  void navigateToProtocolReceive(ProtocolModel protocol) => _nav.pushTo('/protocolos/receive', extra: protocol);
  void navigateToProtocolComment(ProtocolModel protocol) => _nav.pushTo('/protocolos/comment', extra: protocol);

  @override
  void dispose() {
    _auth.removeListener(_onAuthChange);
    super.dispose();
  }
}
