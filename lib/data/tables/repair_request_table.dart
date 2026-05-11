class RepairRequestTable {
  static const String tableName = 'repair_requests';

  static const String id = 'id';
  static const String userId = 'userId';
  static const String protocol = 'protocol';
  static const String description = 'description';
  static const String address = 'address';
  static const String tipoId = 'tipo_id';
  static const String subtipoId = 'subtipo_id';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String date = 'date';
  static const String status = 'status';

  static const String createTableSQL = '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $userId INTEGER,
      $protocol TEXT UNIQUE,
      $description TEXT,
      $address TEXT,
      $tipoId INTEGER,
      $subtipoId INTEGER,
      $latitude REAL,
      $longitude REAL,
      $date TEXT,
      $status TEXT,
      FOREIGN KEY ($userId) REFERENCES users($id)
    )
  ''';
}
