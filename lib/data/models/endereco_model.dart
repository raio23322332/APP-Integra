// data/models/endereco_model.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// data/models/endereco_model.dart

class EnderecoModel {
  final int id;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String? latitude;
  final String? longitude;
  final String tipo;

  EnderecoModel({
    required this.id,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.latitude,
    this.longitude,
    required this.tipo,
  });

  EnderecoModel copyWith({
    int? id,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? latitude,
    String? longitude,
    String? tipo,
  }) {
    return EnderecoModel(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tipo: tipo ?? this.tipo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
    };
  }

  factory EnderecoModel.fromMap(Map<String, dynamic> map) {
    return EnderecoModel(
      id: map['id'] as int? ?? 0,
      cep: map['cep'] as String? ?? '',
      logradouro: map['logradouro'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      complemento: map['complemento'] != null
          ? map['complemento'] as String
          : null,
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      latitude: map['latitude'] != null ? map['latitude'] as String : null,
      longitude: map['longitude'] != null ? map['longitude'] as String : null,
      tipo: map['tipo'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EnderecoModel.fromJson(String source) =>
      EnderecoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EnderecoModel(id: $id, cep: $cep, logradouro: $logradouro, numero: $numero, complemento: $complemento, bairro: $bairro, cidade: $cidade, estado: $estado, latitude: $latitude, longitude: $longitude, tipo: $tipo)';
  }

  @override
  bool operator ==(covariant EnderecoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.cep == cep &&
        other.logradouro == logradouro &&
        other.numero == numero &&
        other.complemento == complemento &&
        other.bairro == bairro &&
        other.cidade == cidade &&
        other.estado == estado &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.tipo == tipo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cep.hashCode ^
        logradouro.hashCode ^
        numero.hashCode ^
        complemento.hashCode ^
        bairro.hashCode ^
        cidade.hashCode ^
        estado.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        tipo.hashCode;
  }
}
