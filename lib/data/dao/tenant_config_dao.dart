import 'dart:convert';
import 'package:integra_app/core/constants/tenant_constants.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/data/database/database_service.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/data/tables/tenant_config_table.dart';
import 'package:integra_app/data/models/tenant_config_model.dart';

class TenantConfigDao {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  Future<void> saveSelectedDomain(String domain) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        TenantConfigTable.tableName,
        where: 'id = ?',
        whereArgs: [TenantConstants.defaultRecordId],
        limit: TenantConstants.queryLimit,
      );
      if (existing.isNotEmpty) {
        await txn.update(
          TenantConfigTable.tableName,
          {TenantConstants.selectedDomainColumn: domain},
          where: 'id = ?',
          whereArgs: [TenantConstants.defaultRecordId],
        );
      } else {
        await txn.insert(TenantConfigTable.tableName, {
          'id': TenantConstants.defaultRecordId,
          TenantConstants.selectedDomainColumn: domain,
        });
      }
    });
  }

  Future<String?> getSelectedDomain() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TenantConfigTable.tableName,
      where: 'id = ?',
      whereArgs: [TenantConstants.defaultRecordId],
      limit: TenantConstants.queryLimit,
    );

    if (maps.isNotEmpty) {
      return maps.first[TenantConstants.selectedDomainColumn] as String?;
    }
    return null;
  }

  Future<void> saveTenantSelection(Tenant tenant) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        TenantConfigTable.tableName,
        where: 'id = ?',
        whereArgs: [TenantConstants.defaultRecordId],
        limit: TenantConstants.queryLimit,
      );
      ConsoleLog.debug("saveTenantSelection: existing record: $existing");

      if (existing.isNotEmpty) {
        await txn.update(
          TenantConfigTable.tableName,
          {TenantConstants.selectedTenantColumn: jsonEncode(tenant.toJson())},
          where: 'id = ?',
          whereArgs: [TenantConstants.defaultRecordId],
        );
      } else {
        await txn.insert(TenantConfigTable.tableName, {
          'id': TenantConstants.defaultRecordId,
          TenantConstants.selectedTenantColumn: jsonEncode(tenant.toJson()),
        });
      } 
    }); 
  }
  // Future<void> saveTenantSelection(Tenant tenant) async {
  //   final db = await _dbProvider.database;

  //   try {
  //     await db.transaction((txn) async {
  //       await txn.delete(TenantConfigTable.tableName);

  //       await txn.insert(
  //         TenantConfigTable.tableName,
  //         {
  //           'id': TenantConstants.defaultRecordId,
  //           'selected_tenant': jsonEncode(tenant.toJson()),
  //           'selected_domain': tenant.urlSubdomainBase,
  //           'descricao': tenant.descricao,
  //         },
  //       );
  //     });

  //     final result = await db.query(TenantConfigTable.tableName);

  //     ConsoleLog.debug('saveTenantSelection: registro salvo no banco: $result');
  //   } catch (e, stack) {
  //     ConsoleLog.error('Erro ao salvar tenant: $e');
  //     ConsoleLog.error('Stack: $stack');
  //     rethrow;
  //   }
  // }

  Future<Tenant?> getSelectedTenant() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TenantConfigTable.tableName,
      where: 'id = ?',
      whereArgs: [TenantConstants.defaultRecordId],
      limit: TenantConstants.queryLimit,
    );

    if (maps.isNotEmpty &&
        maps.first[TenantConstants.selectedTenantColumn] != null) {
      final tenantData = maps.first[TenantConstants.selectedTenantColumn];
      if (tenantData is String) {
        return Tenant.fromJson(jsonDecode(tenantData));
      }
    }
    return null;
  }

  Future<TenantConfig?> getTenantConfig() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TenantConfigTable.tableName,
      where: 'id = ?',
      whereArgs: [TenantConstants.defaultRecordId],
      limit: TenantConstants.queryLimit,
    );

    if (maps.isNotEmpty) {
      final domain =
          maps.first[TenantConstants.selectedDomainColumn] as String?;
      final tenantJson =
          maps.first[TenantConstants.selectedTenantColumn] as String?;
      final tenant =
          tenantJson != null ? Tenant.fromJson(jsonDecode(tenantJson)) : null;
      return TenantConfig(selectedDomain: domain, selectedTenant: tenant);
    }
    return null;
  }

  Future<void> saveCachedTenants(List<Tenant> tenants) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        TenantConfigTable.tableName,
        where: 'id = ?',
        whereArgs: [TenantConstants.defaultRecordId],
        limit: TenantConstants.queryLimit,
      );
      final tenantsJson = jsonEncode(tenants.map((t) => t.toJson()).toList());
      if (existing.isNotEmpty) {
        await txn.update(
          TenantConfigTable.tableName,
          {TenantConstants.cachedTenantsColumn: tenantsJson},
          where: 'id = ?',
          whereArgs: [TenantConstants.defaultRecordId],
        );
      } else {
        await txn.insert(TenantConfigTable.tableName, {
          'id': TenantConstants.defaultRecordId,
          TenantConstants.cachedTenantsColumn: tenantsJson,
        });
      }
    });
  }

  Future<List<Tenant>> getCachedTenants() async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TenantConfigTable.tableName,
      where: 'id = ?',
      whereArgs: [TenantConstants.defaultRecordId],
      limit: TenantConstants.queryLimit,
    );

    if (maps.isNotEmpty &&
        maps.first[TenantConstants.cachedTenantsColumn] != null) {
      final cachedData = maps.first[TenantConstants.cachedTenantsColumn];
      if (cachedData is String) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => Tenant.fromJson(item)).toList();
      }
    }
    return [];
  }

  Future<void> clearTenantConfig() async {
    final db = await _dbProvider.database;
    await db.update(
      TenantConfigTable.tableName,
      {
        TenantConstants.selectedDomainColumn: null,
        TenantConstants.selectedTenantColumn: null,
      },
      where: 'id = ?',
      whereArgs: [TenantConstants.defaultRecordId],
    );
  }
}
