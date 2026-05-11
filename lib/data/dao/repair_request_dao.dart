import 'package:integra_app/data/database/database_service.dart';
import 'package:integra_app/data/models/repair_request_model.dart';
import 'package:sqflite/sqflite.dart';

import '../tables/repair_request_table.dart';

class RepairRequestDao {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  Future<int> insertRepairRequest(RepairRequest request) async {
    final db = await _dbProvider.database;
    return await db.insert(
      RepairRequestTable.tableName,
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RepairRequest>> getRequestsByUserId(int userId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      RepairRequestTable.tableName,
      where: '${RepairRequestTable.userId} = ?',
      whereArgs: [userId],
      orderBy: '${RepairRequestTable.date} DESC',
    );

    return List.generate(maps.length, (i) {
      return RepairRequest.fromMap(maps[i]);
    });
  }

  Future<List<RepairRequest>> getRequestsByUserIdAndFilters(
    int userId, {
    int? tipoId,
    int? subtipoId,
  }) async {
    final db = await _dbProvider.database;
    
    String whereClause = '${RepairRequestTable.userId} = ?';
    List<dynamic> whereArgs = [userId];
    
    if (tipoId != null) {
      whereClause += ' AND ${RepairRequestTable.tipoId} = ?';
      whereArgs.add(tipoId);
    }
    
    if (subtipoId != null) {
      whereClause += ' AND ${RepairRequestTable.subtipoId} = ?';
      whereArgs.add(subtipoId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      RepairRequestTable.tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${RepairRequestTable.date} DESC',
    );

    return List.generate(maps.length, (i) {
      return RepairRequest.fromMap(maps[i]);
    });
  }
}
