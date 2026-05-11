// lib/services/storage/domain_storage_service_impl.dart

import 'dart:convert';

import 'package:integra_app/core/contracts/storage_service_contract.dart';
import 'package:integra_app/data/models/user_model.dart' show User;

import 'domain_storage.dart';

/// Implementação de StorageServiceContract que delega para DomainStorage
class DomainStorageServiceImpl implements StorageServiceContract {
  final DomainStorage _domainStorage;

  DomainStorageServiceImpl(this._domainStorage);

  @override
  Future<void> saveAuthToken(String token) async {
    await _domainStorage.saveAuthToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await _domainStorage.getAuthToken();
  }

  @override
  Future<void> clearAuthToken() async {
    await _domainStorage.clearAuthToken();
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final user = User.fromMap(userData);
    await _domainStorage.saveUserData(user);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final user = await _domainStorage.getUserData();
    return user?.toMap();
  }

  @override
  Future<void> clearUserData() async {
    await _domainStorage.clearUserData();
  }

  @override
  Future<void> saveSelectedDomain(String domain) async {
    await _domainStorage.saveSelectedDomain(domain);
  }

  @override
  Future<String?> getSelectedDomain() async {
    return await _domainStorage.getSelectedDomain();
  }
}
