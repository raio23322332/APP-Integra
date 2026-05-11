// data/models/arquivo_model.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// data/models/arquivo_model.dart
class ArquivoModel {
  final String id;
  final String? userId;
  final String? nomeOriginal;
  final String? nomeArquivo;
  final String? extensao;
  final String? dataUpload;
  final String? horaUpload;
  final String? url;

  ArquivoModel({
    required this.id,
    this.userId,
    this.nomeOriginal,
    this.nomeArquivo,
    this.extensao,
    this.dataUpload,
    this.horaUpload,
    this.url,
  });

  ArquivoModel copyWith({
    String? id,
    String? userId,
    String? nomeOriginal,
    String? nomeArquivo,
    String? extensao,
    String? dataUpload,
    String? horaUpload,
    String? url,
  }) {
    return ArquivoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomeOriginal: nomeOriginal ?? this.nomeOriginal,
      nomeArquivo: nomeArquivo ?? this.nomeArquivo,
      extensao: extensao ?? this.extensao,
      dataUpload: dataUpload ?? this.dataUpload,
      horaUpload: horaUpload ?? this.horaUpload,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'nomeOriginal': nomeOriginal,
      'nomeArquivo': nomeArquivo,
      'extensao': extensao,
      'dataUpload': dataUpload,
      'horaUpload': horaUpload,
      'url': url,
    };
  }

  factory ArquivoModel.fromMap(Map<String, dynamic> map) {
    return ArquivoModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      nomeOriginal: map['nome_original'].toString(),
      nomeArquivo: map['nome_arquivo'].toString(),
      extensao: map['extensao'].toString(),
      dataUpload: map['data_upload'].toString(),
      horaUpload: map['hora_upload'].toString(),
      url: map['url'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArquivoModel.fromJson(String source) =>
      ArquivoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ArquivoModel(id: $id, userId: $userId, nomeOriginal: $nomeOriginal, nomeArquivo: $nomeArquivo, extensao: $extensao, dataUpload: $dataUpload, horaUpload: $horaUpload, url: $url)';
  }

  @override
  bool operator ==(covariant ArquivoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.nomeOriginal == nomeOriginal &&
        other.nomeArquivo == nomeArquivo &&
        other.extensao == extensao &&
        other.dataUpload == dataUpload &&
        other.horaUpload == horaUpload &&
        other.url == url;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        nomeOriginal.hashCode ^
        nomeArquivo.hashCode ^
        extensao.hashCode ^
        dataUpload.hashCode ^
        horaUpload.hashCode ^
        url.hashCode;
  }
}
