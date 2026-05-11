// data/models/status_ui.dart
import 'package:flutter/material.dart';

class StatusUI {
  final Color side;
  final Color badgeBg;
  final Color badgeText;
  final String label;

  const StatusUI({
    required this.side,
    required this.badgeBg,
    required this.badgeText,
    required this.label,
  });
}

const Map<String, StatusUI> statusMap = {
  'pendente': StatusUI(
    side: Colors.orange,
    badgeBg: Color(0xFFFFF3E0),
    badgeText: Colors.orange,
    label: 'Pendente',
  ),
  'aguardando': StatusUI(
    side: Colors.blue,
    badgeBg: Color(0xFFE3F2FD),
    badgeText: Colors.blue,
    label: 'Aguardando',
  ),
  'execucao': StatusUI(
    side: Colors.purple,
    badgeBg: Color(0xFFF3E5F5),
    badgeText: Colors.purple,
    label: 'Em Execução',
  ),
  'concluida': StatusUI(
    side: Colors.green,
    badgeBg: Color(0xFFE8F5E9),
    badgeText: Colors.green,
    label: 'Concluída',
  ),
  'cancelada': StatusUI(
    side: Colors.red,
    badgeBg: Color(0xFFFDECEA),
    badgeText: Colors.red,
    label: 'Cancelada',
  ),
};
