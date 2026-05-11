import 'protocol_model.dart';
import 'sector_model.dart';
import 'user_model.dart';

class ProtocolNotificationModel {
  final String id;
  final String? protocolId;
  final String? sectorId;
  final String type;
  final String title;
  final String? message;
  final bool isRead;
  final DateTime? readAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relacionamentos
  final ProtocolModel? protocol;
  final SectorModel? sector;
  final User? user;

  const ProtocolNotificationModel({
    required this.id,
    this.protocolId,
    this.sectorId,
    required this.type,
    required this.title,
    this.message,
    required this.isRead,
    this.readAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.protocol,
    this.sector,
    this.user,
  });


  factory ProtocolNotificationModel.fromJson(Map<String, dynamic> json) {
    return ProtocolNotificationModel(
      id: json['id'] as String,
      protocolId: json['protocol_id'] as String?,
      sectorId: json['sector_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      protocol: json['protocol'] != null ? ProtocolModel.fromJson(json['protocol'] as Map<String, dynamic>) : null,
      sector: json['sector'] != null ? SectorModel.fromJson(json['sector'] as Map<String, dynamic>) : null,
      user: json['user'] != null ? User.fromMap(json['user'] as Map<String, dynamic>) : null,
    );
  }

  ProtocolNotificationModel copyWith({
    String? id,
    String? protocolId,
    String? sectorId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProtocolModel? protocol,
    SectorModel? sector,
    User? user,
  }) {
    return ProtocolNotificationModel(
      id: id ?? this.id,
      protocolId: protocolId ?? this.protocolId,
      sectorId: sectorId ?? this.sectorId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      protocol: protocol ?? this.protocol,
      sector: sector ?? this.sector,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtocolNotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProtocolNotificationModel{id: $id, type: $type, title: $title, isRead: $isRead}';
  }
}