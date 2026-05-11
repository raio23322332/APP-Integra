import 'package:flutter/material.dart';

/// Diálogo exibido quando não há conexão com a internet
class NoInternetDialog {
  static Future<void> show({
    required BuildContext context,
    String? customMessage,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Sem Conexão'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sem Conexão com a Internet',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              customMessage ?? 'Não foi possível carregar as informações. Verifique sua conexão com a internet e tente novamente.',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
