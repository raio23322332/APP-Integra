import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import '../models/favorite_model.dart';
import '../tables/favorite_table.dart';

class FavoriteDao {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  Future<int> insertFavorite(Favorite favorite) async {
    final db = await _dbProvider.database;
    return await db.insert(
      FavoriteTable.tableName,
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteFavorite(String serviceName, String tenantId) async {
    final db = await _dbProvider.database;
    return await db.delete(
      FavoriteTable.tableName,
      where: '${FavoriteTable.serviceName} = ? AND ${FavoriteTable.tenantId} = ?',
      whereArgs: [serviceName, tenantId],
    );
  }

  Future<List<Favorite>> getAllFavorites() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      FavoriteTable.tableName,
      orderBy: '${FavoriteTable.serviceName} ASC',
    );

    return List.generate(maps.length, (i) {
      return Favorite.fromMap(maps[i]);
    });
  }

  Future<List<Favorite>> getFavoritesByTenant(String tenantId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      FavoriteTable.tableName,
      where: '${FavoriteTable.tenantId} = ?',
      whereArgs: [tenantId],
      orderBy: '${FavoriteTable.serviceName} ASC',
    );

    return List.generate(maps.length, (i) {
      return Favorite.fromMap(maps[i]);
    });
  }

  Future<bool> isFavorite(String serviceName, String tenantId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      FavoriteTable.tableName,
      where: '${FavoriteTable.serviceName} = ? AND ${FavoriteTable.tenantId} = ?',
      whereArgs: [serviceName, tenantId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }
}
