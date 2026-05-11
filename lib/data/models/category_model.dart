class Service {
  final int id;
  final String title;
  final String slug;
  final String type;
  final String address;
  final String cost;                       // AGORA É STRING
  final String duration;
  final String users;
  final String responsible;
  final String unit;
  final DateTime lastUpdate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool isExternal;
  final double? lat;
  final double? lng;
  final String? url;
  final List<Map<String, dynamic>> sections;
  final int timesAccessed; // Adicionando campo times_accessed
  final Category? category; // Adicionar o campo category
  final String? description; // Adicionando campo description
  final bool isFavorite; // Adicionando campo isFavorite (non-nullable)
  final bool canOpenRequest; // Adicionando campo can_open_request

  Service({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.address,
    required this.cost,
    required this.duration,
    required this.users,
    required this.responsible,
    required this.unit,
    required this.lastUpdate,
    required this.timesAccessed, // Adicionando ao construtor
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isExternal = false,
    this.lat,
    this.lng,
    this.url,
    required this.sections,
    this.category, // Adicionar ao construtor
    this.description, // Adicionar ao construtor
    this.isFavorite = false, // Adicionar ao construtor com valor padrão obrigatório
    this.canOpenRequest = false, // Adicionar ao construtor com valor padrão
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Converte sections para lista de Map<String, dynamic>
    var sectionsJson = json['sections'] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> sectionsList = sectionsJson
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return Service(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      cost: json['cost']?.toString() ?? '',                         // <-- STRING
      duration: json['duration'] ?? '',
      users: json['users'] ?? '',
      responsible: json['responsible'] ?? '',
      unit: json['unit'] ?? '',
      lastUpdate: DateTime.tryParse(json['last_update'] ?? '') ?? DateTime.now(),
      timesAccessed: json['times_accessed'] ?? 0, // Adicionando parse do times_accessed
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.tryParse(json['deleted_at']) 
          : null,
      isExternal: json['is_external'] ?? false,
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      url: json['url'],
      sections: sectionsList,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null, // Parsear o campo category
      description: json['description'] ?? 
                  (sectionsList.isNotEmpty ? sectionsList.first['content'] : null), // Parsear o campo description ou do primeiro section
      isFavorite: (json['is_favorite'] as bool?) ?? false, // Parsear o campo is_favorite com segurança
      canOpenRequest: (json['can_open_request'] as bool?) ?? false, // Parsear o campo can_open_request com segurança
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'type': type,
      'address': address,
      'cost': cost,
      'duration': duration,
      'users': users,
      'responsible': responsible,
      'unit': unit,
      'last_update': lastUpdate.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_external': isExternal,
      'lat': lat,
      'lng': lng,
      'url': url,
      'sections': sections.map((s) => s).toList(),
      'description': description,
      'is_favorite': isFavorite,
      'can_open_request': canOpenRequest,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String icon;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? parentId;
  final List<Category> children; // Subcategorias
  final List<Service> services; // Serviços da categoria

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.parentId,
    this.children = const [],
    this.services = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Parse children (subcategorias)
    var childrenJson = json['children'] as List<dynamic>? ?? [];
    List<Category> childrenList = childrenJson
        .map((c) => Category.fromJson(c))
        .toList();

    // Parse services
    var servicesJson = json['services'] as List<dynamic>? ?? [];
    List<Service> servicesList = servicesJson
        .map((s) => Service.fromJson(s))
        .toList();

    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.tryParse(json['deleted_at']) 
          : null,
      parentId: json['parent_id'],
      children: childrenList,
      services: servicesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'parent_id': parentId,
      'children': children.map((c) => c.toJson()).toList(),
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}
