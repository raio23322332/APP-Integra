import 'package:integra_app/data/database/database_service.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../tables/user_table.dart';

class UserDao {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  // Salva o usuário logado (incluindo o token)
  Future<int> saveUser(User user) async {
    final db = await _dbProvider.database;
    // Sempre substitui o usuário existente, pois só deve haver um usuário logado
    return await db.insert(
      UserTable.tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca o usuário logado (o último salvo)
  Future<User?> getCurrentUser() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      UserTable.tableName,
      limit: 1, // Limita a 1, pois só deve haver um usuário logado
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Remove o usuário logado (logout)
  Future<int> deleteUser() async {
    final db = await _dbProvider.database;
    return await db.delete(UserTable.tableName);
  }
}
