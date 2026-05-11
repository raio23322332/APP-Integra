import 'package:flutter/material.dart';
import 'confirmation_dialog.dart';

/// Exemplos de como usar o ConfirmationDialog
class DialogExamples {
  
  /// Diálogo de exclusão (padrão)
  static Future<bool?> showDeleteDialog({
    required BuildContext context,
    String? itemName,
    String? itemDescription,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: 'Excluir Item',
      message: itemName != null 
          ? 'Tem certeza que deseja excluir "$itemName"?'
          : 'Tem certeza que deseja excluir este item?',
      detailText: itemDescription,
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red,
      confirmText: 'Excluir',
      confirmColor: Colors.red,
      warningText: 'Esta ação não poderá ser desfeita!',
    );
  }

  /// Diálogo de confirmação genérico
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? detailText,
    String? warningText,
    String confirmText = 'Confirmar',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      detailText: detailText,
      warningText: warningText,
      icon: Icons.check_circle_outline,
      iconColor: Colors.blue,
      iconBackgroundColor: Colors.blue,
      confirmText: confirmText,
      confirmColor: Colors.blue,
    );
  }

  /// Diálogo de aviso
  static Future<bool?> showWarningDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? detailText,
    String confirmText = 'Continuar',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      detailText: detailText,
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange,
      confirmText: confirmText,
      confirmColor: Colors.orange,
      warningText: 'Verifique as informações antes de continuar.',
    );
  }

  /// Diálogo de sucesso
  static Future<bool?> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? detailText,
    String confirmText = 'OK',
    bool showWarning = false,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      detailText: detailText,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      iconBackgroundColor: Colors.green,
      confirmText: confirmText,
      confirmColor: Colors.green,
      showWarning: showWarning,
    );
  }

  /// Diálogo de informação
  static Future<bool?> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? detailText,
    String confirmText = 'Entendi',
    bool showWarning = false,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      detailText: detailText,
      icon: Icons.info_outline,
      iconColor: Colors.blue,
      iconBackgroundColor: Colors.blue,
      confirmText: confirmText,
      confirmColor: Colors.blue,
      showWarning: showWarning,
    );
  }

  /// Diálogo de logout
  static Future<bool?> showLogoutDialog({
    required BuildContext context,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: 'Sair da Conta',
      message: 'Tem certeza que deseja sair da sua conta?',
      icon: Icons.exit_to_app,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red,
      confirmText: 'Confirmar',
      confirmColor: Colors.red,
      warningText: 'Você precisará fazer login novamente para acessar o aplicativo.',
    );
  }

  /// Diálogo de cancelamento
  static Future<bool?> showCancelDialog({
    required BuildContext context,
    String? itemName,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: 'Cancelar Operação',
      message: itemName != null 
          ? 'Tem certeza que deseja cancelar "$itemName"?'
          : 'Tem certeza que deseja cancelar esta operação?',
      icon: Icons.cancel_outlined,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange,
      confirmText: 'Cancelar',
      confirmColor: Colors.orange,
      warningText: 'Todas as alterações não salvas serão perdidas.',
    );
  }

  /// Diálogo de reset
  static Future<bool?> showResetDialog({
    required BuildContext context,
    required String itemName,
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: 'Redefinir $itemName',
      message: 'Tem certeza que deseja redefinir $itemName?',
      icon: Icons.refresh,
      iconColor: Colors.purple,
      iconBackgroundColor: Colors.purple,
      confirmText: 'Redefinir',
      confirmColor: Colors.purple,
      warningText: 'Esta ação restaurará os valores padrão.',
    );
  }
}
