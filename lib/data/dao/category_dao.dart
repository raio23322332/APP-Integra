import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:integra_app/data/database/database_service.dart';
import 'package:integra_app/data/models/category_model.dart';
import 'package:integra_app/data/tables/category_table.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDao {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  Future<void> saveCategories(String tenantDomain, List<Category> categories) async {
    final db = await _dbProvider.database;
    
    // Converte a lista de categorias para JSON usando o método toJson do modelo
    final String jsonData = jsonEncode(
      categories.map((c) => c.toJson()).toList()
    );

    // Verifica se já existe registro para este tenant
    final List<Map<String, dynamic>> existing = await db.query(
      CategoryTable.tableName,
      where: '${CategoryTable.tenantDomain} = ?',
      whereArgs: [tenantDomain],
    );

    if (existing.isNotEmpty) {
      await db.update(
        CategoryTable.tableName,
        {
          CategoryTable.jsonData: jsonData,
          CategoryTable.lastUpdated: DateTime.now().toIso8601String(),
        },
        where: '${CategoryTable.tenantDomain} = ?',
        whereArgs: [tenantDomain],
      );
    } else {
      await db.insert(
        CategoryTable.tableName,
        {
          CategoryTable.tenantDomain: tenantDomain,
          CategoryTable.jsonData: jsonData,
          CategoryTable.lastUpdated: DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Future<List<Category>?> getCategories(String tenantDomain) async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        CategoryTable.tableName,
        where: '${CategoryTable.tenantDomain} = ?',
        whereArgs: [tenantDomain],
      );

      if (maps.isEmpty) {
        debugPrint('[CategoryDao] Nenhuma categoria encontrada para $tenantDomain');
        return null;
      }

      final String jsonData = maps.first[CategoryTable.jsonData];
      final List<dynamic> decoded = jsonDecode(jsonData);
      
      final categories = decoded.map((item) => Category.fromJson(item)).toList();
      debugPrint('[CategoryDao] ${categories.length} categorias recuperadas do banco para $tenantDomain');
      return categories;
    } catch (e) {
      debugPrint('[CategoryDao] Erro ao buscar categorias: $e');
      return null;
    }
  }

  Future<void> deleteCategories(String tenantDomain) async {
    try {
      final db = await _dbProvider.database;
      final int deleted = await db.delete(
        CategoryTable.tableName,
        where: '${CategoryTable.tenantDomain} = ?',
        whereArgs: [tenantDomain],
      );
      debugPrint('[CategoryDao] Categorias para $tenantDomain deletadas do banco ($deleted registros)');
    } catch (e) {
      debugPrint('[CategoryDao] Erro ao deletar categorias: $e');
    }
  }
}
