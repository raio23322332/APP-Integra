class Favorite {
  final int? id;
  final String tenantId;
  final String serviceName;
  final String route;
  final String iconCodePoint; // Para armazenar o ícone como String
  final String? slug; // Para armazenar o slug específico do serviço
  final String? title; // Para armazenar o título específico
  final int? idService; // Para armazenar o ID do serviço original

  Favorite({
    this.id,
    required this.tenantId,
    required this.serviceName,
    required this.route,
    required this.iconCodePoint,
    this.slug,
    this.title,
    this.idService,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'serviceName': serviceName,
      'route': route,
      'iconCodePoint': iconCodePoint,
      'slug': slug,
      'title': title,
      'idService': idService,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int?,
      tenantId: map['tenantId']?.toString() ?? '', // Converte para String
      serviceName: map['serviceName'] as String,
      route: map['route'] as String,
      iconCodePoint: map['iconCodePoint'] as String,
      slug: map['slug'] as String?,
      title: map['title'] as String?,
      idService: map['idService'] as int?,
    );
  }
}
