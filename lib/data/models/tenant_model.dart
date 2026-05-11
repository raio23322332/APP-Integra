// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';


import 'domain_model.dart';

class Tenant {
  final String id;
  final String? tenancyDbName;
  final String? urlSubdomainBase;
  final List<DomainModel> domains;
  final String? descricao;
  Tenant({
    required this.id,
    this.tenancyDbName,
    this.urlSubdomainBase,
    required this.domains,
    this.descricao,
  });
  String? get primaryDomain {
    if (domains.isEmpty) return null;
    return domains.first.domain;
  }

  String? get devDomain {
    if (domains.isEmpty) return null;
    return domains
            .firstWhere(
              (d) => (d.domain ?? '').contains('.dev.integradigital.com.br'),
              orElse: () => domains.first,
            )
            .domain ??
        domains.first.domain;
  }

  @override
  String toString() {
    return 'Tenant(id: $id, tenancyDbName: $tenancyDbName, urlSubdomainBase: $urlSubdomainBase, domains: $domains, descricao: $descricao)';
  }

  Tenant copyWith({
    String? id,
    String? tenancyDbName,
    String? urlSubdomainBase,
    List<DomainModel>? domains,
    String? descricao,
  }) {
    return Tenant(
      id: id ?? this.id,
      tenancyDbName: tenancyDbName ?? this.tenancyDbName,
      urlSubdomainBase: urlSubdomainBase ?? this.urlSubdomainBase,
      domains: domains ?? this.domains,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tenancyDbName': tenancyDbName,
      'urlSubdomainBase': urlSubdomainBase,
      'domains': domains.map((x) => x.toMap()).toList(),
      'descricao': descricao,
    };
  }

  factory Tenant.fromMap(Map<String, dynamic> map) {
    return Tenant(
      id: map['id'].toString(),
      tenancyDbName: map['tenancy_db_name'] != null
          ? map['tenancy_db_name'].toString()
          : null,
      urlSubdomainBase: map['url_subdomain_base'] != null
          ? map['url_subdomain_base'].toString()
          : null,
      domains: List<DomainModel>.from(
        (map['domains'] as List<dynamic>? ?? []).map(
          (x) => DomainModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      descricao: map['descricao'] != null ? map['descricao'].toString() : null,
    );
  }
  factory Tenant.empty() {
    return Tenant(
      id: '-1',
      tenancyDbName: null,
      urlSubdomainBase: null,
      domains: [],
      descricao: null,
    );
  }
  String toJson() => json.encode(toMap());
  factory Tenant.fromJson(String source) =>
      Tenant.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tenant) return false;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.tenancyDbName == tenancyDbName &&
        other.urlSubdomainBase == urlSubdomainBase &&
        listEquals(other.domains, domains) &&
        other.descricao == descricao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenancyDbName.hashCode ^
        urlSubdomainBase.hashCode ^
        domains.hashCode ^
        descricao.hashCode;
  }
}
