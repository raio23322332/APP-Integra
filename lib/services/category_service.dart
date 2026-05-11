import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/data/dao/category_dao.dart';
import '../data/models/category_model.dart' as models;
import '../data/models/tenant_model.dart';
import '../core/contracts/category_service_contract.dart';

class CategoryService implements CategoryServiceContract {
  final CategoryDao _categoryDao = CategoryDao();

  /// Busca categorias apenas do banco de dados local
  Future<List<models.Category>> getLocalCategories(Tenant tenant) async {
    final String? tenantDomain =
        tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;
    if (tenantDomain == null) return [];
    
    final local = await _categoryDao.getCategories(tenantDomain);
    return local ?? [];
  }

  // Cache simples para categorias - chave: tenantDomain, valor: (categories, timestamp)
  final Map<String, (List<models.Category>, DateTime)> _cache = {};
  static const Duration _cacheDuration = Duration(
    minutes: 1,
  ); // Cache por 1 minuto

  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ Cache de categorias limpo');
  }

  void clearCacheForTenant(String tenantDomain) {
    _cache.remove(tenantDomain);
    debugPrint('🗑️ Cache de categorias limpo para o tenant: $tenantDomain');
  }

  Future<void> clearCategoriesForTenant(String tenantDomain) async {
    // Limpa do cache
    clearCacheForTenant(tenantDomain);
    
    // Limpa do banco local
    await _categoryDao.deleteCategories(tenantDomain);
    
    debugPrint('🗑️ Categorias completamente removidas para o tenant: $tenantDomain');
  }

  Future<List<models.Category>> getCategories(
    Tenant tenant,
    String token,
  ) async {
    // Obtém domínio do tenant para usar como chave do cache
    final String? tenantDomain =
        tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;

    if (tenantDomain != null) {
      // Verifica se temos dados em cache válidos
      final cached = _cache[tenantDomain];
      if (cached != null) {
        final (categories, timestamp) = cached;
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          debugPrint('🔄 Usando categorias do cache para $tenantDomain');
          return categories;
        } else {
          // Cache expirado, remove
          _cache.remove(tenantDomain);
        }
      }
    }

    if (tenantDomain == null || tenantDomain.isEmpty) {
      throw Exception('Tenant sem domínio configurado para buscar categorias.');
    }

    // 2. Obter a URL base da API a partir do .env
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no arquivo .env');
    }

    // 3. Construir a URL final da requisição
    final Uri categoriesUrl = Uri.parse('$baseFromEnv/api/v1/categories');
    debugPrint('🔗 Buscando categorias em: $categoriesUrl');
    debugPrint('🔗 Buscando baseFromEnv em: $baseFromEnv');
    debugPrint('🌐 Para o Host: $tenantDomain');

    try {
      final response = await http.get(
        categoriesUrl,
        headers: {
          'Accept': 'application/json',
          'Host': tenantDomain, // ESSENCIAL para identificar o tenant
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Status Code Categorias: ${response.statusCode}');
      if (response.statusCode == 200) {
        // API retorna array direto, não com chave 'data'
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData is List 
            ? responseData 
            : (responseData['data'] as List<dynamic>? ?? []);
        ConsoleLog.sucesso('Dados da API: ${data.toString()}');
        ConsoleLog.sucesso('Quantidade categorias API: ${data.length}');
        // A API agora retorna categorias prontas com services incluídos
        List<models.Category> categories = data
            .map((c) => models.Category.fromJson(c))
            .toList();

        // Cache em memória
        _cache[tenantDomain] = (categories, DateTime.now());
        
        // Persistência local para uso offline
        await _categoryDao.saveCategories(tenantDomain, categories);
        debugPrint('💾 Categorias salvas localmente para $tenantDomain');
        debugPrint('💾 Quantidade salva: ${categories.length}');

        return categories;
      } else {
        // Se falhar a API (ex: erro de servidor), tenta carregar do banco local
        debugPrint('⚠️ Falha na API (${response.statusCode}), tentando carregar categorias locais...');
        final localCategories = await _categoryDao.getCategories(tenantDomain);
        if (localCategories != null && localCategories.isNotEmpty) {
          debugPrint('✅ Categorias recuperadas do banco local após falha na API.');
          return localCategories;
        }
        
        throw Exception(
          'Falha ao carregar categorias. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('🌐 Erro de conexão ou requisição ao buscar categorias: $e');
      
      // Em caso de erro (offline), tenta carregar do banco local
      debugPrint('📦 Tentando recuperar categorias do banco de dados local...');
      try {
        final localCategories = await _categoryDao.getCategories(tenantDomain);
        
        if (localCategories != null && localCategories.isNotEmpty) {
          debugPrint('✅ Categorias recuperadas do banco local com sucesso após erro de rede.');
          return localCategories;
        }
      } catch (dbError) {
        debugPrint('❌ Erro ao acessar banco local: $dbError');
      }
      
      // Se não houver dados locais, relança a exceção original
      throw Exception('Você está offline e não há categorias salvas localmente.');
    }
  }
}
