import 'package:flutter/foundation.dart';
import '../../../data/models/protocol_notification_model.dart';
import '../../../services/http/protocol_http.dart';

class ProtocolNotificationViewModel extends ChangeNotifier {
  final ProtocolHttp _protocolHttp = ProtocolHttp();

  List<ProtocolNotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Getters
  List<ProtocolNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;

  // Contagem de notificações não lidas
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications.clear();
    }

    if (_isLoading || !_hasMore) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _protocolHttp.getNotifications(page: _currentPage);
      
      if (result['success'] == true) {
        final newNotifications = result['data'] as List<ProtocolNotificationModel>;
        final pagination = result['pagination'] as Map<String, dynamic>;
        
        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }
        
        _currentPage++;
        _totalPages = pagination['last_page'] ?? 1;
        _hasMore = _currentPage <= _totalPages;
        
        notifyListeners();
      } else {
        _setError(result['message'] ?? 'Erro ao carregar notificações');
      }
    } catch (e) {
      _setError('Falha ao carregar notificações: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _protocolHttp.markNotificationAsRead(notificationId);
      
      // Atualizar a notificação na lista
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Forçar atualização localmente como fallback
        final localUpdated = _notifications[index].copyWith(isRead: true);
        _notifications[index] = localUpdated;
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Falha ao marcar notificação como lida: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final unreadNotificationIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    
    if (unreadNotificationIds.isEmpty) {
      return;
    }

    try {
      await _protocolHttp.markMultipleNotificationsAsRead(unreadNotificationIds);
      
      // Atualizar todas as notificações como lidas na lista local
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Falha ao marcar notificações como lidas: $e');
    }
  }

  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
