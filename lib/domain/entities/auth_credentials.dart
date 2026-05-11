// lib/domain/entities/auth_credentials.dart
class AuthCredentials {
  final String email;
  final String password;
  final String deviceName;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.deviceName = 'flutter_app',
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'device_name': deviceName,
  };
}