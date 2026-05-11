import 'sector_model.dart';
import 'protocol_attachment_model.dart';

class ProtocolAppendixModel {
  final String id;
  final String protocolId;
  final int orderNumber;
  final String code;
  final String title;
  final String? documentType;
  final String? notes;
  final String? sectorId;
  final String createdBy;
  final String? createdAt;
  final String? updatedAt;
  final SectorModel? sector;
  final List<ProtocolAttachmentModel>? attachments;

  const ProtocolAppendixModel({
    required this.id,
    required this.protocolId,
    required this.orderNumber,
    required this.code,
    required this.title,
    this.documentType,
    this.notes,
    this.sectorId,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.sector,
    this.attachments,
  });

  factory ProtocolAppendixModel.fromJson(Map<String, dynamic> json) {
    return ProtocolAppendixModel(
      id: json['id'] as String? ?? '',
      protocolId: json['protocol_id'] as String? ?? '',
      orderNumber: json['order_number'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      documentType: json['document_type'] as String?,
      notes: json['notes'] as String?,
      sectorId: json['sector_id'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      sector: json['sector'] != null 
          ? SectorModel.fromJson(json['sector'] as Map<String, dynamic>)
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((item) => ProtocolAttachmentModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'protocol_id': protocolId,
      'order_number': orderNumber,
      'code': code,
      'title': title,
      'document_type': documentType,
      'notes': notes,
      'sector_id': sectorId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sector': sector?.toJson(),
      'attachments': attachments?.map((item) => item.toJson()).toList(),
    };
  }
}
