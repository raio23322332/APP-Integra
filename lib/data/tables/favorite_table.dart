class FavoriteTable {
  static const String tableName = 'favorites';

  static const String id = 'id';
  static const String tenantId = 'tenantId';
  static const String serviceName = 'serviceName';
  static const String route = 'route';
  static const String iconCodePoint = 'iconCodePoint';
  static const String slug = 'slug';
  static const String title = 'title';
  static const String idService = 'idService';

  static const String createTableSQL = '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $tenantId INTEGER NOT NULL,
      $serviceName TEXT NOT NULL,
      $route TEXT NOT NULL,
      $iconCodePoint TEXT NOT NULL,
      $slug TEXT,
      $title TEXT,
      $idService INTEGER,
      UNIQUE($tenantId, $serviceName)
    )
  ''';
}
