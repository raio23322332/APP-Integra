class TenantConfigTable {
  static const String tableName = 'tenant_config';
  static const String cachedTenantsColumn = 'cached_tenants';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY,
      selected_domain TEXT,
      selected_tenant TEXT,
      descricao TEXT,
      $cachedTenantsColumn TEXT
    );
  ''';
}
