// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:integra_app/core/models/subt_tipo_model.dart';

class TipoModel {
  final String id;
  final String? descricao;
  final String? slug;
  final String? status;
  final List<SubtTipoModel> subtipos;

  TipoModel({
    required this.id,
    this.descricao,
    this.slug,
    this.status,
    required this.subtipos,
  });

  TipoModel copyWith({
    String? id,
    String? descricao,
    String? slug,
    String? status,
    List<SubtTipoModel>? subtipos,
  }) {
    return TipoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      subtipos: subtipos ?? this.subtipos,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'descricao': descricao,
      'slug': slug,
      'status': status,
      'subtipos': subtipos.map((x) => x.toMap()).toList(),
    };
  }

  factory TipoModel.fromMap(Map<String, dynamic> map) {
    return TipoModel(
      id: map['id'] as String,
      descricao: map['descricao'] != null ? map['descricao'] as String : null,
      slug: map['slug'] != null ? map['slug'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      subtipos: List<SubtTipoModel>.from(
        (map['subtipos'] as List<int>).map<SubtTipoModel>(
          (x) => SubtTipoModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  factory TipoModel.empty() {
    return TipoModel(
      id: '-1',
      descricao: null,
      slug: null,
      status: null,
      subtipos: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory TipoModel.fromJson(String source) =>
      TipoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TipoModel(id: $id, descricao: $descricao, slug: $slug, status: $status, subtipos: $subtipos)';
  }

  @override
  bool operator ==(covariant TipoModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.descricao == descricao &&
        other.slug == slug &&
        other.status == status &&
        listEquals(other.subtipos, subtipos);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        descricao.hashCode ^
        slug.hashCode ^
        status.hashCode ^
        subtipos.hashCode;
  }
}
