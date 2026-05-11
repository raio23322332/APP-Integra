// data/models/service_model.dart
import 'dart:convert';

class ServiceModel {
  final String id;
  final String? categoryId;
  final String? sectorId;
  final String? slug;
  final String? title;
  final String? type;
  final String? cost;
  final String? duration;
  final bool? isExternal;
  final bool? canOpenRequest;
  final String? responsible;
  final String? unit;
  final String? address;
  final double? lat;
  final double? lng;

  ServiceModel({
    required this.id,
    this.categoryId,
    this.sectorId,
    this.slug,
    this.title,
    this.type,
    this.cost,
    this.duration,
    this.isExternal,
    this.canOpenRequest,
    this.responsible,
    this.unit,
    this.address,
    this.lat,
    this.lng,
  });

  ServiceModel copyWith({
    String? id,
    String? categoryId,
    String? sectorId,
    String? slug,
    String? title,
    String? type,
    String? cost,
    String? duration,
    bool? isExternal,
    bool? canOpenRequest,
    String? responsible,
    String? unit,
    String? address,
    double? lat,
    double? lng,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      sectorId: sectorId ?? this.sectorId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      duration: duration ?? this.duration,
      isExternal: isExternal ?? this.isExternal,
      canOpenRequest: canOpenRequest ?? this.canOpenRequest,
      responsible: responsible ?? this.responsible,
      unit: unit ?? this.unit,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category_id': categoryId,
      'sector_id': sectorId,
      'slug': slug,
      'title': title,
      'type': type,
      'cost': cost,
      'duration': duration,
      'is_external': isExternal,
      'can_open_request': canOpenRequest,
      'responsible': responsible,
      'unit': unit,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id']?.toString() ?? '',
      categoryId: map['category_id']?.toString(),
      sectorId: map['sector_id']?.toString(),
      slug: map['slug']?.toString(),
      title: map['title']?.toString(),
      type: map['type']?.toString(),
      cost: map['cost']?.toString(),
      duration: map['duration']?.toString(),
      isExternal: map['is_external'] as bool?,
      canOpenRequest: map['can_open_request'] as bool?,
      responsible: map['responsible']?.toString(),
      unit: map['unit']?.toString(),
      address: map['address']?.toString(),
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceModel.fromJson(String source) =>
      ServiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ServiceModel(id: $id, slug: $slug, title: $title, type: $type)';

  @override
  bool operator ==(covariant ServiceModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.categoryId == categoryId &&
        other.sectorId == sectorId &&
        other.slug == slug &&
        other.title == title &&
        other.type == type &&
        other.cost == cost &&
        other.duration == duration &&
        other.isExternal == isExternal &&
        other.canOpenRequest == canOpenRequest &&
        other.responsible == responsible &&
        other.unit == unit &&
        other.address == address &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categoryId.hashCode ^
        sectorId.hashCode ^
        slug.hashCode ^
        title.hashCode ^
        type.hashCode ^
        cost.hashCode ^
        duration.hashCode ^
        isExternal.hashCode ^
        canOpenRequest.hashCode ^
        responsible.hashCode ^
        unit.hashCode ^
        address.hashCode ^
        lat.hashCode ^
        lng.hashCode;
  }

  static ServiceModel empty() => ServiceModel(id: '');
}
