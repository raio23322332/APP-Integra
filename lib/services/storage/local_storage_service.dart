abstract class LocalStorageService {
  Future<void> saveTenantSelection(String tenantId);
  Future<String?> getTenantSelection();
  Future<void> saveUserPreferences(Map<String, dynamic> prefs);
  Future<Map<String, dynamic>?> getUserPreferences();
}
