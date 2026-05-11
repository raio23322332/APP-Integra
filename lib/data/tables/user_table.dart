class UserTable {
  static const String tableName = 'users';

  static const String id = 'id';
  static const String email = 'email';
  static const String token = 'token';
  static const String name = 'name';
  static const String cpf = 'cpf';
  static const String roles = 'roles';
  static const String permissions = 'permissions';
  static const String createTableSQL = '''
    CREATE TABLE $tableName(
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $email TEXT UNIQUE,
      $token TEXT NOT NULL,
      $name TEXT,
      $cpf TEXT,
      $roles TEXT,
      $permissions TEXT
    )
  ''';
}
