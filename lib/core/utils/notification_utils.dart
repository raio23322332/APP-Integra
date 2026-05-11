// lib/core/utils/notification_utils.dart
import 'package:flutter/material.dart';

class NotificationTypeConfig {
  final String type;
  final String displayName;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const NotificationTypeConfig({
    required this.type,
    required this.displayName,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

class NotificationUtils {
  static const Map<String, NotificationTypeConfig> _notificationConfigs = {
    'FORWARDED': NotificationTypeConfig(
      type: 'FORWARDED',
      displayName: 'Tramitado',
      backgroundColor: Color(0xFF2196F3), // Azul
      textColor: Colors.white,
      icon: Icons.send,
    ),
    'RECEIVED': NotificationTypeConfig(
      type: 'RECEIVED',
      displayName: 'Recebido',
      backgroundColor: Color(0xFF4CAF50), // Verde
      textColor: Colors.white,
      icon: Icons.inbox,
    ),
    'COMMENTED': NotificationTypeConfig(
      type: 'COMMENTED',
      displayName: 'Comentado',
      backgroundColor: Color(0xFFFF9800), // Laranja
      textColor: Colors.white,
      icon: Icons.comment,
    ),
    'CANCELLED': NotificationTypeConfig(
      type: 'CANCELLED',
      displayName: 'Cancelado',
      backgroundColor: Color(0xFFF44336), // Vermelho
      textColor: Colors.white,
      icon: Icons.cancel,
    ),
    'ARCHIVED': NotificationTypeConfig(
      type: 'ARCHIVED',
      displayName: 'Arquivado',
      backgroundColor: Color(0xFF9C27B0), // Roxo
      textColor: Colors.white,
      icon: Icons.archive,
    ),
  };

  static NotificationTypeConfig getConfig(String type) {
    return _notificationConfigs[type] ?? NotificationTypeConfig(
      type: type,
      displayName: type,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      icon: Icons.notifications,
    );
  }

  static Color getBackgroundColor(String type, bool isRead) {
    if (isRead) {
      return Colors.grey.shade200;
    }
    return getConfig(type).backgroundColor;
  }

  static Color getTextColor(String type, bool isRead) {
    if (isRead) {
      return Colors.grey.shade700;
    }
    return getConfig(type).textColor;
  }

  static IconData getIcon(String type) {
    return getConfig(type).icon;
  }

  static String getDisplayName(String type) {
    return getConfig(type).displayName;
  }
}