// lib/core/constants/tenant_constants.dart

/// Constantes centralizadas para o módulo de tenancy
/// Elimina valores mágicos e facilita manutenção
class TenantConstants {
  // IDs e limites de banco de dados
  static const int defaultRecordId = 1;
  static const int queryLimit = 1;

  // Dimensões e espaçamentos da UI
  static const double cardPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 20.0;
  static const double iconContainerSize = 40.0;
  static const double arrowIconSize = 18.0;

  // Animações
  static const Duration cardFadeInDuration = Duration(milliseconds: 600);
  static const Duration iconScaleInDuration = Duration(milliseconds: 500);
  static const Duration arrowFadeInDuration = Duration(milliseconds: 400);
  static const int animationDelayMultiplier = 100;
  static const int iconDelayOffset = 200;
  static const int arrowDelayOffset = 400;

  // Offsets de animação
  static const double cardSlideOffsetY = 0.2;
  static const double arrowSlideOffsetX = 0.3;

  // Opacidades
  static const double splashOpacity = 0.1;
  static const double highlightOpacity = 0.05;
  static const double iconBackgroundOpacity = 0.1;
  static const double dividerOpacity = 0.3;

  // Espaçamentos específicos
  static const double listHorizontalPadding = 16.0;
  static const double listVerticalPadding = 20.0;
  static const double cardHorizontalPadding = 16.0;
  static const double cardVerticalPadding = 16.0;
  static const double emptyStateIconSize = 48.0;
  static const double emptyStateSpacing = 16.0;
  static const double emptyStateButtonSpacing = 24.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 72.0;
  static const double dividerEndIndent = 16.0;

  // Database column names
  static const String selectedDomainColumn = 'selected_domain';
  static const String selectedTenantColumn = 'selected_tenant';
  static const String cachedTenantsColumn = 'cached_tenants';
  static const String descricaoColumn = 'descricao';
}
