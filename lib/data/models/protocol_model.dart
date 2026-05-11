import 'package:flutter/material.dart';
import 'sector_model.dart';

class ProtocolMovementModel {
  final String id;
  final String protocolId;
  final String? fromSectorId;
  final String? toSectorId;
  final String movedBy;
  final String action;
  final String? message;
  final String movedAt;
  final Map<String, dynamic>? fromSector;
  final Map<String, dynamic>? toSector;

  const ProtocolMovementModel({
    required this.id,
    required this.protocolId,
    this.fromSectorId,
    this.toSectorId,
    required this.movedBy,
    required this.action,
    this.message,
    required this.movedAt,
    this.fromSector,
    this.toSector,
  });

  factory ProtocolMovementModel.fromJson(Map<String, dynamic> json) {
    return ProtocolMovementModel(
      id: json['id'] as String? ?? '',
      protocolId: json['protocol_id'] as String? ?? '',
      fromSectorId: json['from_sector_id'] as String?,
      toSectorId: json['to_sector_id'] as String?,
      movedBy: json['moved_by'] as String? ?? '',
      action: json['action'] as String? ?? '',
      message: json['message'] as String?,
      movedAt: json['moved_at'] as String? ?? '',
      fromSector: json['from_sector'] as Map<String, dynamic>?,
      toSector: json['to_sector'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocol_id': protocolId,
      'from_sector_id': fromSectorId,
      'to_sector_id': toSectorId,
      'moved_by': movedBy,
      'action': action,
      'message': message,
      'moved_at': movedAt,
      'from_sector': fromSector,
      'to_sector': toSector,
    };
  }

  // Getters para facilitar o acesso
  String? get fromSectorName => fromSector?['name'] as String?;
  String? get toSectorName => toSector?['name'] as String?;
  String? get fromSectorCode => fromSector?['code'] as String?;
  String? get toSectorCode => toSector?['code'] as String?;
  
  // Helper para obter descrição completa da movimentação
  String get fullDescription {
    final actionLabel = _getActionLabel(action);
    final fromName = fromSectorName ?? 'Setor não informado';
    final toName = toSectorName ?? 'Setor não informado';
    
    switch (action.toUpperCase()) {
      case 'FORWARDED':
        return 'Tramitado de $fromName para $toName';
      case 'RECEIVED':
        return 'Recebido em $toName';
      case 'REGISTERED':
        return 'Registrado em $fromName';
      case 'COMMENTED':
        return 'Comentado em $fromName';
      case 'CANCELED':
        return 'Cancelado em $fromName';
      case 'ARCHIVED':
        return 'Arquivado em $fromName';
      default:
        return '$actionLabel em $fromName';
    }
  }
  
  // Helper para obter cor da movimentação
  Color get movementColor => _getActionColor(action);
  
  // Helper para obter ícone da movimentação
  IconData get movementIcon => _getActionIcon(action);
  
  // Métodos privados para helpers
  static String _getActionLabel(String? action) {
    switch (action?.toUpperCase()) {
      case 'REGISTERED':
        return 'Registrado';
      case 'FORWARDED':
        return 'Tramitado';
      case 'RECEIVED':
        return 'Recebido';
      case 'COMMENTED':
        return 'Comentado';
      case 'CANCELED':
        return 'Cancelado';
      case 'ARCHIVED':
        return 'Arquivado';
      default:
        return action ?? 'Desconhecido';
    }
  }
  
  static Color _getActionColor(String? action) {
    switch (action?.toUpperCase()) {
      case 'REGISTERED':
        return Colors.green;
      case 'FORWARDED':
        return Colors.blue;
      case 'RECEIVED':
        return Colors.orange;
      case 'COMMENTED':
        return Colors.purple;
      case 'CANCELED':
        return Colors.red;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  static IconData _getActionIcon(String? action) {
    switch (action?.toUpperCase()) {
      case 'REGISTERED':
        return Icons.add_circle;
      case 'FORWARDED':
        return Icons.send;
      case 'RECEIVED':
        return Icons.inbox;
      case 'COMMENTED':
        return Icons.comment;
      case 'CANCELED':
        return Icons.cancel;
      case 'ARCHIVED':
        return Icons.archive;
      default:
        return Icons.info;
    }
  }
}

class ProtocolModel {
  final String id;
  final String number;
  final int year;
  final int seq;
  final int sectorCode;
  final int dv;
  final String sectorId;
  final String createdBy;
  final String direction;
  final String? documentType;
  final String subject;
  final String? notes;
  final String? originProtocol;
  final String? originAgency;
  final bool isConfidential;
  final bool isEmergency;
  final String status;
  final String? registeredAt;
  final String? createdAt;
  final String? updatedAt;
  final SectorModel? sector;
  final List<ProtocolMovementModel>? movements;

  const ProtocolModel({
    required this.id,
    required this.number,
    required this.year,
    required this.seq,
    required this.sectorCode,
    required this.dv,
    required this.sectorId,
    required this.createdBy,
    required this.direction,
    this.documentType,
    required this.subject,
    this.notes,
    this.originProtocol,
    this.originAgency,
    required this.isConfidential,
    required this.isEmergency,
    required this.status,
    this.registeredAt,
    this.createdAt,
    this.updatedAt,
    this.sector,
    this.movements,
  });

  factory ProtocolModel.fromJson(Map<String, dynamic> json) {
    return ProtocolModel(
      id: json['id'] as String? ?? '',
      number: json['number'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      seq: json['seq'] as int? ?? 0,
      sectorCode: json['sector_code'] as int? ?? 0,
      dv: json['dv'] as int? ?? 0,
      sectorId: json['sector_id'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      direction: json['direction'] as String? ?? '',
      documentType: json['document_type'] as String?,
      subject: json['subject'] as String? ?? '',
      notes: json['notes'] as String?,
      originProtocol: json['origin_protocol'] as String?,
      originAgency: json['origin_agency'] as String?,
      isConfidential: json['is_confidential'] as bool? ?? false,
      isEmergency: json['is_emergency'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      registeredAt: json['registered_at'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      sector: json['sector'] != null 
          ? SectorModel.fromJson(json['sector'] as Map<String, dynamic>)
          : null,
      movements: json['movements'] != null
          ? (json['movements'] as List)
              .map((item) => ProtocolMovementModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'year': year,
      'seq': seq,
      'sector_code': sectorCode,
      'dv': dv,
      'sector_id': sectorId,
      'created_by': createdBy,
      'direction': direction,
      'document_type': documentType,
      'subject': subject,
      'notes': notes,
      'origin_protocol': originProtocol,
      'origin_agency': originAgency,
      'is_confidential': isConfidential,
      'is_emergency': isEmergency,
      'status': status,
      'registered_at': registeredAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sector': sector?.toJson(),
      'movements': movements?.map((item) => item.toJson()).toList(),
    };
  }

  ProtocolModel copyWith({
    String? id,
    String? number,
    int? year,
    int? seq,
    int? sectorCode,
    int? dv,
    String? sectorId,
    String? createdBy,
    String? direction,
    String? documentType,
    String? subject,
    String? notes,
    String? originProtocol,
    String? originAgency,
    bool? isConfidential,
    bool? isEmergency,
    String? status,
    String? registeredAt,
    String? createdAt,
    String? updatedAt,
    SectorModel? sector,
    List<ProtocolMovementModel>? movements,
  }) {
    return ProtocolModel(
      id: id ?? this.id,
      number: number ?? this.number,
      year: year ?? this.year,
      seq: seq ?? this.seq,
      sectorCode: sectorCode ?? this.sectorCode,
      dv: dv ?? this.dv,
      sectorId: sectorId ?? this.sectorId,
      createdBy: createdBy ?? this.createdBy,
      direction: direction ?? this.direction,
      documentType: documentType ?? this.documentType,
      subject: subject ?? this.subject,
      notes: notes ?? this.notes,
      originProtocol: originProtocol ?? this.originProtocol,
      originAgency: originAgency ?? this.originAgency,
      isConfidential: isConfidential ?? this.isConfidential,
      isEmergency: isEmergency ?? this.isEmergency,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sector: sector ?? this.sector,
      movements: movements ?? this.movements,
    );
  }
}
