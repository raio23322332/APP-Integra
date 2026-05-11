class CategoryTable {
  static const String tableName = 'categories';

  static const String id = 'id';
  static const String tenantDomain = 'tenantDomain';
  static const String jsonData = 'jsonData';
  static const String lastUpdated = 'lastUpdated';

  static const String createTableSQL = '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $tenantDomain TEXT,
      $jsonData TEXT,
      $lastUpdated TEXT
    )
  ''';
}
