import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart' as tsf;
import 'package:top_snackbar_flutter/safe_area_values.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CustomSnackBar {
  CustomSnackBar._(); // Construtor privado para evitar instanciação

  static void showSuccess(BuildContext context, String message, {Key? key}) {
    try {
      final OverlayState? overlayState =
          Overlay.of(context, rootOverlay: true) ?? Overlay.of(context);

      if (overlayState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      showTopSnackBar(
        overlayState,
        tsf.CustomSnackBar.success(
          message: message,
          key: key,
        ),
        snackBarPosition: SnackBarPosition.top,
        animationDuration: const Duration(milliseconds: 400),
        reverseAnimationDuration: const Duration(milliseconds: 300),
        dismissDirection: const [DismissDirection.up, DismissDirection.down],
        safeAreaValues: const SafeAreaValues(top: true),
        displayDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Erro ao mostrar snackbar de sucesso: $e');
      // Fallback para ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void showError(BuildContext context, String message, {Key? key}) {
    try {
      final OverlayState? overlayState =
          Overlay.of(context, rootOverlay: true) ?? Overlay.of(context);

      if (overlayState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      showTopSnackBar(
        overlayState,
        tsf.CustomSnackBar.error(
          message: message,
          key: key ?? const Key("snackbar_error"),
        ),
        snackBarPosition: SnackBarPosition.top,
        animationDuration: const Duration(milliseconds: 400),
        reverseAnimationDuration: const Duration(milliseconds: 300),
        dismissDirection: const [DismissDirection.up, DismissDirection.down],
        safeAreaValues: const SafeAreaValues(top: true),
        displayDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Erro ao mostrar snackbar de erro: $e');
      // Fallback para ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void showInfo(BuildContext context, String message, {Key? key}) {
    try {
      final OverlayState? overlayState =
          Overlay.of(context, rootOverlay: true) ?? Overlay.of(context);

      if (overlayState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      showTopSnackBar(
        overlayState,
        tsf.CustomSnackBar.info(
          message: message,
          key: key,
        ),
        snackBarPosition: SnackBarPosition.top,
        animationDuration: const Duration(milliseconds: 400),
        reverseAnimationDuration: const Duration(milliseconds: 300),
        dismissDirection: const [DismissDirection.up, DismissDirection.down],
        safeAreaValues: const SafeAreaValues(top: true),
        displayDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Erro ao mostrar snackbar de info: $e');
      // Fallback para ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
