import 'package:flutter/material.dart';
import 'package:integra_app/data/tables/favorite_table.dart';
import 'package:integra_app/data/tables/repair_request_table.dart';
import 'package:integra_app/data/tables/tenant_config_table.dart';
import 'package:integra_app/data/tables/category_table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../tables/user_table.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(UserTable.createTableSQL);
    await db.execute(RepairRequestTable.createTableSQL);
    await db.execute(FavoriteTable.createTableSQL);
    await db.execute(TenantConfigTable.createTableSQL);
    await db.execute(CategoryTable.createTableSQL);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Recria a tabela de usuários para a nova estrutura (inclusão de roles e permissions)
      await db.execute('DROP TABLE IF EXISTS ${UserTable.tableName}');
      await db.execute(UserTable.createTableSQL);
    }
    if (oldVersion < 4) {
      await db.execute(FavoriteTable.createTableSQL);
      await db.execute(TenantConfigTable.createTableSQL);
    }
    if (oldVersion < 5) {
      // Adiciona colunas slug e title à tabela favorites existente
      await db.execute(
          'ALTER TABLE ${FavoriteTable.tableName} ADD COLUMN ${FavoriteTable.slug} TEXT');
      await db.execute(
          'ALTER TABLE ${FavoriteTable.tableName} ADD COLUMN ${FavoriteTable.title} TEXT');
    }
    if (oldVersion < 6) {
      // Garante que a tabela seja criada se não existir (caso o upgrade tenha falhado ou pulado)
      await db.execute('DROP TABLE IF EXISTS ${CategoryTable.tableName}');
      await db.execute(CategoryTable.createTableSQL);
      debugPrint(
          '[LocalDatabase] Tabela de categorias criada no upgrade para v6');
    }
    if (oldVersion < 7) {
      // Adiciona suporte a tenancy na tabela favorites
      await db.execute('''
        ALTER TABLE ${FavoriteTable.tableName} 
        ADD COLUMN ${FavoriteTable.tenantId} INTEGER NOT NULL DEFAULT 1
      ''');

      // Recria a tabela com a nova estrutura e constraint UNIQUE correta
      final tempFavorites = await db.query(FavoriteTable.tableName);
      await db.execute('DROP TABLE ${FavoriteTable.tableName}');
      await db.execute(FavoriteTable.createTableSQL);

      // Restaura os dados com tenantId padrão
      for (final favorite in tempFavorites) {
        favorite[FavoriteTable.tenantId] = 1; // Tenant padrão
        await db.insert(FavoriteTable.tableName, favorite);
      }

      debugPrint(
          '[LocalDatabase] Tabela de favoritos atualizada para suportar tenancy (v7)');
    }
    if (oldVersion < 8) {
      // Adiciona campo idService para buscar dados completos do serviço
      await db.execute(
          'ALTER TABLE ${FavoriteTable.tableName} ADD COLUMN ${FavoriteTable.idService} INTEGER');
      debugPrint(
          '[LocalDatabase] Campo idService adicionado à tabela de favoritos (v8)');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
