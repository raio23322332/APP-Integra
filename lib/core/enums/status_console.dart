enum StatusConsole {
  sucesso,
  error,
  informacao,
  alerta,
  debug;

  String getDescricao() {
    switch (this) {
      case StatusConsole.sucesso:
        return 'Operação realizada com sucesso.';
      case StatusConsole.error:
        return 'Ocorreu um erro durante a operação.';
      case StatusConsole.informacao:
        return 'Informação relevante para o usuário.';
      case StatusConsole.alerta:
        return 'Atenção: algo importante precisa ser verificado.';
      case StatusConsole.debug:
        return 'Mensagem de depuração para desenvolvedores.';
    }
  }

  String getCor() {
    switch (this) {
      case StatusConsole.sucesso:
        return '\x1B[32m';
      case StatusConsole.error:
        return '\x1B[31m';
      case StatusConsole.informacao:
        return '\x1B[34m';
      case StatusConsole.alerta:
        return '\x1B[33m';
      case StatusConsole.debug:
        return '\x1B[36m';
    }
  }

  String getEmoji() {
    switch (this) {
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
}
