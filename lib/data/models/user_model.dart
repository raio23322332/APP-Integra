class User {
  final int? id;
  final String email;
  final String token;
  final String? name; // Exemplo de outro dado do usuário
  final String? cpf; // Exemplo de outro dado do usuário
  final List<String> roles;
  final List<String> permissions;

  User({
    this.id,
    required this.email,
    required this.token,
    this.name,
    this.cpf,
    this.roles = const [],
    this.permissions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'name': name,
      'cpf': cpf,
      'roles': roles.join(','), // Salva como String separada por vírgula
      'permissions': permissions.join(
        ',',
      ), // Salva como String separada por vírgula
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: (map['email'] ?? '') as String,
      token: (map['token'] as String?) ?? '',
      name: map['name'] as String?,
      cpf: map['cpf'] as String?,
      roles: () {
        final r = map['roles'];
        if (r is String) {
          return (r).split(',').where((e) => e.isNotEmpty).toList();
        } else if (r is List) {
          return r.map((e) => e.toString()).toList();
        }
        return <String>[];
      }(),
      permissions: () {
        final p = map['permissions'];
        if (p is String) {
          return (p).split(',').where((e) => e.isNotEmpty).toList();
        } else if (p is List) {
          return p.map((e) => e.toString()).toList();
        }
        return <String>[];
      }(),
    );
  }
}
