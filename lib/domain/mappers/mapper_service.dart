import '../../../data/models/user_model.dart';
import '../../../data/models/tenant_model.dart';
import '../../../data/models/category_model.dart' as category_models;
import '../../../data/models/repair_request_model.dart';
import '../../../data/models/favorite_model.dart';
import '../../../data/models/domain_model.dart';

/// Serviço centralizado para mapeamento de dados
/// Centraliza todas as conversões entre diferentes formatos de dados
class MapperService {
  MapperService._();

  // ------------------------------------------------------------ USER MAPPERS
  static User userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: (map['email'] ?? '') as String,
      token: (map['token'] as String?) ?? '',
      name: map['name'] as String?,
      cpf: map['cpf'] as String?,
      roles: _parseRoles(map['roles']),
      permissions: _parsePermissions(map['permissions']),
    );
  }

  static Map<String, dynamic> userToMap(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'token': user.token,
      'name': user.name,
      'cpf': user.cpf,
      'roles': user.roles,
      'permissions': user.permissions,
    };
  }

  // ------------------------------------------------------------ TENANT MAPPERS
  static Tenant tenantFromMap(Map<String, dynamic> map) {
    try {
      return Tenant.fromMap(map);
    } catch (err) {
      return Tenant.empty();
    }
  }

  // Tenant usa implementação nativa - problemas de tipo resolvidos deixando em branco
  static Map<String, dynamic> tenantToMap(Tenant tenant) {
    // TODO: Implementar quando necessário - usar tenant.toMap() diretamente onde chamado
    throw UnimplementedError('tenantToMap not implemented - use tenant.toMap() directly');
  }

  // ------------------------------------------------------------ DOMAIN MODEL MAPPERS
  static DomainModel domainModelFromMap(Map<String, dynamic> map) {
    return DomainModel(
      id: map['id'].toString(),
      domain: map['domain']?.toString(),
    );
  }

  static Map<String, dynamic> domainModelToMap(DomainModel model) {
    final result = <String, dynamic>{};
    result['id'] = model.id;
    if (model.domain != null) result['domain'] = model.domain;
    return result;
  }

  // ------------------------------------------------------------ CATEGORY MAPPERS
  static category_models.Category categoryFromJson(Map<String, dynamic> json) {
    return category_models.Category.fromJson(json);
  }

  static category_models.Service serviceFromJson(Map<String, dynamic> json) {
    return category_models.Service.fromJson(json);
  }

  // ------------------------------------------------------------ REPAIR REQUEST MAPPERS
  static RepairRequest repairRequestFromMap(Map<String, dynamic> map) {
    return RepairRequest(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      protocol: map['protocol'] as String,
      description: map['description'] as String,
      address: map['address'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'Pendente',
    );
  }

  static Map<String, dynamic> repairRequestToMap(RepairRequest request) {
    return {
      'id': request.id,
      'userId': request.userId,
      'protocol': request.protocol,
      'description': request.description,
      'address': request.address,
      'latitude': request.latitude,
      'longitude': request.longitude,
      'date': request.date.toIso8601String(),
      'status': request.status,
    };
  }

  // ------------------------------------------------------------ FAVORITE MAPPERS
  static Favorite favoriteFromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int?,
      tenantId: map['tenantId']?.toString() ?? '', // Converte para String
      serviceName: map['serviceName'] as String? ?? '',
      route: map['route'] as String? ?? '',
      iconCodePoint: (map['iconCodePoint'] as int?)?.toString() ?? '0',
    );
  }

  static Map<String, dynamic> favoriteToMap(Favorite favorite) {
    return {
      'id': favorite.id,
      'serviceName': favorite.serviceName,
      'route': favorite.route,
      'iconCodePoint': favorite.iconCodePoint,
    };
  }

  // ------------------------------------------------------------ USER DATA MAPPERS
  static User userFromApiResponse(Map<String, dynamic> userData) {
    return User(
      email: userData['email'] ?? '',
      token: '', // Token será definido separadamente
      name: userData['name'] ?? '',
      cpf: userData['cpf'] ?? '',
      roles: _parseRoles(userData['roles']),
      permissions: _parsePermissions(userData['permissions']),
    );
  }

  static User userFromOfflineData(Map<String, dynamic> userMap) {
    return User(
      id: userMap['id'] as int?,
      email: (userMap['email'] ?? '') as String,
      token: (userMap['token'] as String?) ?? '',
      name: userMap['name'] as String?,
      cpf: userMap['cpf'] as String?,
      roles: (userMap['roles'] is String)
          ? (userMap['roles'] as String)
                .split(',')
                .where((e) => e.isNotEmpty)
                .toList()
          : (userMap['roles'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
      permissions: (userMap['permissions'] is String)
          ? (userMap['permissions'] as String)
                .split(',')
                .where((e) => e.isNotEmpty)
                .toList()
          : (userMap['permissions'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
    );
  }

  // ------------------------------------------------------------ HELPER METHODS
  static List<String> _parseRoles(dynamic roles) {
    if (roles is List) {
      return roles.map((e) => e.toString()).toList();
    } else if (roles is String) {
      return roles.split(',').where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static List<String> _parsePermissions(dynamic permissions) {
    if (permissions is List) {
      return permissions.map((e) => e.toString()).toList();
    } else if (permissions is String) {
      return permissions.split(',').where((e) => e.isNotEmpty).toList();
    }
    return [];
  }
}
