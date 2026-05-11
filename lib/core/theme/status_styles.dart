// core/theme/status_styles.dart
import 'package:flutter/material.dart';

class StatusStyle {
  final String label;
  final Color color;
  final Color background;
  final Color textColor;

  const StatusStyle({
    required this.label,
    required this.color,
    required this.background,
    required this.textColor,
  });
}

// Tornando público: remova o "_"
const defaultStatus = StatusStyle(
  label: 'Desconhecido',
  color: Colors.grey,
  background: Color(0xFFF3F4F6),
  textColor: Colors.grey,
);

final Map<String, StatusStyle> statusMap = {
  'pendente': StatusStyle(
    label: 'Pendente',
    color: Color(0xFFA855F7), // sua cor preferida
    background: Color(0xFFF3E8FF),
    textColor: Color(0xFF6B21A8),
  ),
  'aguardando': StatusStyle(
    label: 'Aguardando',
    color: Color(0xFF3B82F6),
    background: Color(0xFFEFF6FF),
    textColor: Color(0xFF1D4ED8),
  ),
  'execucao': StatusStyle(
    label: 'Execução',
    color: Color(0xFF8B5CF6),
    background: Color(0xFFF5F3FF),
    textColor: Color(0xFF5B21B6),
  ),
  'concluida': StatusStyle(
    label: 'Concluída',
    color: Color(0xFF10B981),
    background: Color(0xFFECFDF5),
    textColor: Color(0xFF047857),
  ),
  'cancelada': StatusStyle(
    label: 'Cancelada',
    color: Color(0xFFEF4444),
    background: Color(0xFFFFF1F1),
    textColor: Color(0xFFB91C1C),
  ),
};
