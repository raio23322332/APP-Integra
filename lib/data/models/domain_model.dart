import 'dart:convert';

class DomainModel {
  final String id;
  final String? domain;
  final String? tenantId;

  DomainModel({
    required this.id,
    this.domain,
    this.tenantId,
  });

  DomainModel copyWith({
    String? id,
    String? domain,
    String? tenantId,
  }) {
    return DomainModel(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    if (domain != null) {
      result.addAll({'domain': domain});
    }
    if (tenantId != null) {
      result.addAll({'tenantId': tenantId});
    }

    return result;
  }

  factory DomainModel.fromMap(Map<String, dynamic> map) {
    return DomainModel(
      id: map['id'].toString(),
      domain: map['domain']?.toString(),
      // sua API manda "tenantId", não "tenant_id"
      tenantId: (map['tenantId'] ?? map['tenant_id'])?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DomainModel.fromJson(String source) =>
      DomainModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'DomainModel(id: $id, domain: $domain, tenantId: $tenantId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DomainModel &&
        other.id == id &&
        other.domain == domain &&
        other.tenantId == tenantId;
  }

  @override
  int get hashCode => id.hashCode ^ domain.hashCode ^ tenantId.hashCode;
}
