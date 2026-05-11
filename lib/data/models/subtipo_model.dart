// data/models/subtipo_model.dart
import 'dart:convert';

class SubtipoModel {
  final String id;
  final String? tipoId;
  final String? descricao;
  SubtipoModel({required this.id, this.tipoId, this.descricao});

  SubtipoModel copyWith({String? id, String? tipoId, String? descricao}) {
    return SubtipoModel(
      id: id ?? this.id,
      tipoId: tipoId ?? this.tipoId,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tipoId': tipoId,
      'descricao': descricao,
    };
  }

  factory SubtipoModel.fromMap(Map<String, dynamic> map) {
    return SubtipoModel(
      id: map['id'].toString(),
      tipoId: map['tipo_id']?.toString(),
      descricao: map['descricao']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubtipoModel.fromJson(String source) =>
      SubtipoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SubtipoModel(id: $id, tipoId: $tipoId, descricao: $descricao)';

  @override
  bool operator ==(covariant SubtipoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.tipoId == tipoId &&
        other.descricao == descricao;
  }

  @override
  int get hashCode => id.hashCode ^ tipoId.hashCode ^ descricao.hashCode;
}
