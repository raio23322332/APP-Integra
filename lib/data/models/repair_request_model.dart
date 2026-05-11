import 'package:latlong2/latlong.dart';

class RepairRequest {
  final int? id;
  final int userId;
  final String protocol;
  final String description;
  final String? address; // Adicionado
  final int? tipoId;
  final int? subtipoId;
  final double latitude;
  final double longitude;
  final DateTime date;
  final String status;

  RepairRequest({
    this.id,
    required this.userId,
    required this.protocol,
    required this.description,
    this.address, // Adicionado
    this.tipoId,
    this.subtipoId,
    required this.latitude,
    required this.longitude,
    required this.date,
    this.status = 'Pendente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'protocol': protocol,
      'description': description,
      'address': address, // Adicionado
      'tipo_id': tipoId,
      'subtipo_id': subtipoId,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory RepairRequest.fromMap(Map<String, dynamic> map) {
    return RepairRequest(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      protocol: map['protocol'] as String,
      description: map['description'] as String,
      address: map['address'] as String?, // Adicionado
      tipoId: map['tipo_id'] as int?,
      subtipoId: map['subtipo_id'] as int?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String,
    );
  }

  LatLng get location => LatLng(latitude, longitude);
}
