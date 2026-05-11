// presentation/widgets/protocols/protocol_app_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// AppBar padrão do módulo de protocolos — mesmo gradiente do módulo de solicitações
PreferredSizeWidget protocolAppBar({
  required String title,
  List<Widget>? actions,
  VoidCallback? onBack,
}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    actions: actions,
    foregroundColor: Colors.white,
    elevation: 1,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        tooltip: 'Voltar',
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onPressed: onBack ?? () {
          Navigator.pop(context);
        },
      ),
    ),
    titleSpacing: -16,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryBlue, AppColors.lightBlue],
        ),
      ),
    ),
  );
}

/// Card padrão de seção — mesmo estilo do detail screen
Widget protocolSectionCard({
  Key? key,
  required IconData icon,
  required String title,
  required Widget child,
  Color? iconColor,
}) {
  return Card(
    key: key,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    color: Colors.white,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: iconColor ?? AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

/// Input padrão do módulo de protocolos
InputDecoration protocolInputDecoration({
  required String label,
  String? hint,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryBlue) : null,
    filled: true,
    fillColor: Colors.grey.shade50,
    labelStyle: const TextStyle(color: AppColors.primaryBlue),
  );
}
