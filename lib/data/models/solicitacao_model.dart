// data/models/solicitacao_model.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/core/models/subt_tipo_model.dart';
import 'package:integra_app/data/models/endereco_model.dart';
import '../../core/constants/tipos_constants.dart';
import '../../core/models/tipo_model.dart';
import 'arquivo_model.dart';
import 'subtipo_model.dart';
import 'service_model.dart';

class SolicitacaoModel {
  final String id;
  final String? userId;
  final String? tipoId;
  final String? subtipoId;
  final String? codigo;
  final String? descricao;
  final String? dateTime;
  final String? updatedAt;
  final String? observacao;
  final bool? privacidade;
  final String? latitude;
  final String? longitude;
  final String? status;
  final String? prazo;
  final List<EnderecoModel>? enderecos;
  final List<ArquivoModel>? arquivos;
  final SubtipoModel? subtipo;
  final ServiceModel? service;
  SolicitacaoModel({
    required this.id,
    this.userId,
    this.tipoId,
    this.subtipoId,
    this.codigo,
    this.descricao,
    this.dateTime,
    this.updatedAt,
    this.observacao,
    this.privacidade,
    this.latitude,
    this.longitude,
    this.status,
    this.prazo,
    this.enderecos,
    this.arquivos,
    this.subtipo,
    this.service,
  });
  SolicitacaoModel copyWith({
    String? id,
    String? userId,
    String? tipoId,
    String? subtipoId,
    String? codigo,
    String? descricao,
    String? dateTime,
    String? observacao,
    String? privacidade,
    String? latitude,
    String? longitude,
    String? status,
    String? prazo,
    SubtipoModel? subtipo,
  }) {
    return SolicitacaoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tipoId: tipoId ?? this.tipoId,
      subtipoId: subtipoId ?? this.subtipoId,
      codigo: codigo ?? this.codigo,
      descricao: descricao ?? this.descricao,
      dateTime: dateTime ?? this.dateTime,
      observacao: observacao ?? this.observacao,
      privacidade: this.privacidade,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      prazo: prazo ?? this.prazo,
      enderecos: enderecos,
      arquivos: arquivos,
      subtipo: subtipo ?? this.subtipo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'tipoId': tipoId,
      'subtipoId': subtipoId,
      'codigo': codigo,
      'descricao': descricao,
      'dateTime': dateTime,
      'observacao': observacao,
      'privacidade': privacidade,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'prazo': prazo,
      'enderecos': enderecos,
      'arquivos': arquivos,
      'subtipo': subtipo,
      'service': service,
    };
  }

  factory SolicitacaoModel.fromMap(Map<String, dynamic> map) {
    List<EnderecoModel>? enderecos;
    List<ArquivoModel>? arquivos;
    if (map['enderecos'] != null && map['enderecos'] is List) {
      try {
        enderecos = (map['enderecos'] as List)
            .map((e) => EnderecoModel.fromMap(e))
            .toList();
      } catch (e) {
        ConsoleLog.error('Erro ao converter endereços: $e');
        enderecos = [];
      }
    }
    if (map['arquivos'] != null && map['arquivos'] is List) {
      try {
        arquivos = (map['arquivos'] as List)
            .map((e) => ArquivoModel.fromMap(e))
            .toList();
      } catch (e) {
        ConsoleLog.error('Erro ao converter endereços: $e');
        arquivos = [];
      }
    }
    final id = map['id'];
    final userId = map['user_id'];
    final tipoId = map['tipo_id'];
    final subtipoId = map['subtipo_id'];
    final codigo = map['codigo'];
    final descricao = map['descricao'];
    final dateTime = map['data_time'];
    final updatedAt = map['updated_at'];
    final observacao = map['observacao'];
    final privacidade = map['privacidade'];
    final latitude = map['latitude'];
    final longitude = map['longitude'];
    final status = map['status'];
    final prazo = map['prazo'];
    final solicitacao = SolicitacaoModel(
      id: id?.toString() ?? '',
      userId: userId?.toString(),
      tipoId: tipoId?.toString(),
      subtipoId: subtipoId?.toString(),
      codigo: codigo?.toString(),
      descricao: descricao?.toString(),
      dateTime: dateTime?.toString(),
      observacao: observacao?.toString(),
      privacidade: privacidade ?? false,
      latitude: latitude?.toString(),
      longitude: longitude?.toString(),
      status: status?.toString(),
      prazo: prazo?.toString(),
      enderecos: enderecos,
      updatedAt: updatedAt,
      arquivos: arquivos,
      subtipo: map['subtipo'] != null
          ? SubtipoModel.fromMap(map['subtipo'] as Map<String, dynamic>)
          : null,
      service: map['service'] != null
          ? ServiceModel.fromMap(map['service'] as Map<String, dynamic>)
          : null,
    );
    return solicitacao;
  }
  String getDescricaoTipo(String value) {
    final tipos = TiposConstants.data
        .where((item) => item.id.toString() == value.toString())
        .toList();
    if (tipos.isEmpty) {
      return "Sem tipo";
    }
    return tipos.first.descricao.toString();
  }

  String get dataBr {
    try {
      return DateFormat(
        'dd/MM/yyyy HH:mm',
        'pt_BR',
      ).format(DateTime.parse(dateTime.toString()));
    } catch (err) {
      ConsoleLog.informacao('Model.dataBr: $err');
      return '- - -';
    }
  }

  String getDescricaoTipoSubTipo(String tipoId, String subtipoId) {
    final tipo = TiposConstants.data.firstWhere(
      (tipo) => tipo.id.toString() == tipoId,
      orElse: () => TipoModel.empty(),
    );
    final subtipo = tipo.subtipos.firstWhere(
      (sub) => sub.id.toString() == subtipoId,
      orElse: () => SubtTipoModel.empty(),
    );
    return subtipo.descricao ?? "Sem subtipo";
  }

  static List<SolicitacaoModel> fromJsonList(List<dynamic> list) {
    try {
      final result = list.map((item) {
        return SolicitacaoModel.fromMap(item as Map<String, dynamic>);
      }).toList();
      return result;
    } catch (e) {
      ConsoleLog.error('❌ Erro em fromJsonList: $e');
      ConsoleLog.error(
        'Item que causou erro: ${list.isNotEmpty ? list.first : "lista vazia"}',
      );
      return [];
    }
  }

  String toJson() => json.encode(toMap());
  factory SolicitacaoModel.fromJson(String source) =>
      SolicitacaoModel.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'SolicitacaoModel(id: $id, userId: $userId, tipoId: $tipoId, subtipoId: $subtipoId, codigo: $codigo, descricao: $descricao, dateTime: $dateTime, updatedAt: $updatedAt, observacao: $observacao, privacidade: $privacidade, latitude: $latitude, longitude: $longitude, status: $status, enderecos: $enderecos, arquivos: $arquivos, subtipo: $subtipo)';
  }

  @override
  bool operator ==(covariant SolicitacaoModel other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.userId == userId &&
        other.tipoId == tipoId &&
        other.subtipoId == subtipoId &&
        other.codigo == codigo &&
        other.descricao == descricao &&
        other.dateTime == dateTime &&
        other.observacao == observacao &&
        other.privacidade == privacidade &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.status == status &&
        other.enderecos == enderecos &&
        other.arquivos == arquivos &&
        other.subtipo == subtipo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        tipoId.hashCode ^
        subtipoId.hashCode ^
        codigo.hashCode ^
        descricao.hashCode ^
        dateTime.hashCode ^
        observacao.hashCode ^
        privacidade.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        status.hashCode ^
        enderecos.hashCode ^
        arquivos.hashCode ^
        subtipo.hashCode;
  }
}
