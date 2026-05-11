// lib/domain/entities/auth_response.dart
class AuthResponse {
  final String accessToken;
  final dynamic user; // can be a Map<String, dynamic> or a User instance
  final dynamic tenant; // can be a Map<String, dynamic> or a Tenant instance
  final DateTime expiresAt;

  const AuthResponse({
    required this.accessToken,
    required this.user,
    this.tenant,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? json['token'] ?? '',
      user: json['user'] as dynamic,
      tenant: json['tenant'] as dynamic,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }
}
