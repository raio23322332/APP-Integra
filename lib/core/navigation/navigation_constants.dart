// lib/core/navigation/navigation_constants.dart

/// Constantes de navegação para reduzir acoplamento
/// Centraliza todas as rotas da aplicação
class NavigationConstants {
  // Rotas de autenticação
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String tenantSelect = '/selecao-subdominio';

  // Rotas de Protocolos
  static const String protocols = '/protocolos';
  static const String protocolDetail = '/protocolos/detail';
  static const String createProtocol = '/protocolos/create';

  // Rotas de Setores
  static const String sectors = '/setores';
  static const String createSector = '/setores/create';
  static const String editSector = '/setores/edit';

  // Evita instanciação
  NavigationConstants._();
}
