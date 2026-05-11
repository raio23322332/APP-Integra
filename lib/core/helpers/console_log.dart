// core/helpers/console_log.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:integra_app/core/enums/status_console.dart';
import 'package:logger/logger.dart';

import 'data_time_helper.dart';

class ConsoleLog {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // ✅ Mais contexto para debug
      errorMethodCount: 8, // ✅ Mantém para erros
      lineLength: 120, // ✅ Mais espaço para logs
      colors: true,
      printEmojis: true,
      printTime: true, // ✅ Timestamp para debug
    ),
    level: Level.debug, // ✅ Força nível debug
  );
  static Level _getLogLevel(StatusConsole tipo) {
    switch (tipo) {
      case StatusConsole.sucesso:
        return Level.info;
      case StatusConsole.error:
        return Level.error;
      case StatusConsole.informacao:
        return Level.info;
      case StatusConsole.alerta:
        return Level.warning;
      case StatusConsole.debug:
        return Level.debug;
    }
  }

  static void mensagem({
    required String titulo,
    required String mensagem,
    required StatusConsole tipo,
  }) {
    String emoji = _getEmoji(tipo);
    final logMessage = '$emoji $titulo: $mensagem';

    // ✅ Sempre mostrar no debug console do VS Code
    debugPrint(logMessage);

    // ✅ Também no logger formatado
    _logger.log(_getLogLevel(tipo), logMessage);
  }

  static void logError({
    required Object error,
    required StackTrace stackTrace,
    String? className,
    String? methodName,
  }) {
    DateTime? time = DateTimeHelper.dataTime();
    _logger.e('🚨 Erro', time: time, error: error, stackTrace: stackTrace);
  }

  static String _getEmoji(StatusConsole tipo) {
    switch (tipo) {
      case StatusConsole.sucesso:
        return '✅';
      case StatusConsole.error:
        return '❌';
      case StatusConsole.informacao:
        return 'ℹ️';
      case StatusConsole.alerta:
        return '⚠️';
      case StatusConsole.debug:
        return '🔧';
    }
  }

  static error(String message) {
    mensagem(titulo: 'Erro', mensagem: message, tipo: StatusConsole.error);
  }

  static sucesso(String message) {
    mensagem(titulo: 'Sucesso', mensagem: message, tipo: StatusConsole.sucesso);
  }

  static debug(String message) {
    mensagem(titulo: 'Debug', mensagem: message, tipo: StatusConsole.debug);
  }

  static informacao(String message) {
    mensagem(
      titulo: 'Informacao',
      mensagem: message,
      tipo: StatusConsole.informacao,
    );
  }
}
