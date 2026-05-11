// core/models/subt_tipo_model.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SubtTipoModel {
  final String id;
  final String? tipoId;
  final String? descricao;
  final String? slug;
  final String? status;

  SubtTipoModel({
    required this.id,
    this.tipoId,
    this.descricao,
    this.slug,
    this.status,
  });

  SubtTipoModel copyWith({
    String? id,
    String? tipoId,
    String? descricao,
    String? slug,
    String? status,
  }) {
    return SubtTipoModel(
      id: id ?? this.id,
      tipoId: tipoId ?? this.tipoId,
      descricao: descricao ?? this.descricao,
      slug: slug ?? this.slug,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tipoId': tipoId,
      'descricao': descricao,
      'slug': slug,
      'status': status,
    };
  }

  factory SubtTipoModel.fromMap(Map<String, dynamic> map) {
    return SubtTipoModel(
      id: map['id'] as String,
      tipoId: map['tipoId'] != null ? map['tipoId'] as String : null,
      descricao: map['descricao'] != null ? map['descricao'] as String : null,
      slug: map['slug'] != null ? map['slug'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
    );
  }

  factory SubtTipoModel.empty() {
    return SubtTipoModel(
      id: '-1',
      tipoId: null,
      descricao: null,
      slug: null,
      status: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubtTipoModel.fromJson(String source) =>
      SubtTipoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SubtTipoModel(id: $id, tipoId: $tipoId, descricao: $descricao, slug: $slug, status: $status)';
  }

  @override
  bool operator ==(covariant SubtTipoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.tipoId == tipoId &&
        other.descricao == descricao &&
        other.slug == slug &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tipoId.hashCode ^
        descricao.hashCode ^
        slug.hashCode ^
        status.hashCode;
  }
}
