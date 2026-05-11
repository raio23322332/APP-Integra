class SectorModel {
  final String id;
  final String name;
  final int code;
  final bool isActive;

  const SectorModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
    };
  }

  SectorModel copyWith({
    String? id,
    String? name,
    int? code,
    bool? isActive,
  }) {
    return SectorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
    );
  }
}
