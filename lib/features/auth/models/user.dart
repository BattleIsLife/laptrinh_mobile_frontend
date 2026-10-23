/// Represents an authenticated user in the system.
class User {
  final int id;
  final String email;
  final String name;

  const User({required this.id, required this.email, required this.name});

  /// Creates a [User] from JSON representation.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  /// Converts this [User] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}

/// Represents the authentication payload returned by the login endpoint.
class AuthResult {
  final User user;
  final String token;

  const AuthResult({required this.user, required this.token});

  /// Creates an [AuthResult] from the backend response JSON.
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final token = json['token'] as String? ?? '';
    return AuthResult(user: User.fromJson(userJson), token: token);
  }

  /// Converts this [AuthResult] to JSON.
  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResult &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          token == other.token;

  @override
  int get hashCode => user.hashCode ^ token.hashCode;

  @override
  String toString() => 'AuthResult(user: $user, token: [PROTECTED])';
}
