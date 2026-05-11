class FlavorConfig {
  static const String _definedFlavor = String.fromEnvironment('FLAVOR');
  static const String _definedEnvFile = String.fromEnvironment('ENV_FILE');

  static String get flavor {
    if (_definedFlavor.isNotEmpty) return _definedFlavor;
    return 'dev';
  }

  static String get envFile {
    if (_definedEnvFile.isNotEmpty) return _definedEnvFile;

    switch (flavor) {
      case 'homologacao':
        return 'assets/env/env.homologacao';
      case 'prod':
        return 'assets/env/env.prod';
      case 'dev':
      default:
        return '.env';
    }
  }

  static String get appName {
    switch (flavor) {
      case 'dev':
        return 'Integra Desenvolvimento';
      case 'homologacao':
        return 'Integra Homologação';
      case 'prod':
      default:
        return 'Integra';
    }
  }

  static String get logoAsset {
    switch (flavor) {
      case 'dev':
        return 'assets/images/logo_desenvolvimento.png';
      case 'homologacao':
        return 'assets/images/logo_homologacao.png';
      case 'prod':
      default:
        return 'assets/images/logo_nobackground.png';
    }
  }
}
