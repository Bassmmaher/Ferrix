import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// UserDto — data transfer object for a user
// ─────────────────────────────────────────────────────────────
class UserDto {
  final String id;
  final String name;
  final String email;
  final String status;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  /// Serialize to a plain map (ready for `jsonEncode`).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'status': status,
      };

  /// Parse from a decoded JSON map.
  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        status: json['status'] as String,
      );

  @override
  String toString() =>
      'UserDto(id: $id, name: $name, email: $email, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDto &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.status == status;

  @override
  int get hashCode => Object.hash(id, name, email, status);
}

// ─────────────────────────────────────────────────────────────
// AuthResult — payload returned from a successful login
// ─────────────────────────────────────────────────────────────
class AuthResult {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  /// Serialize to a plain map (ready for `jsonEncode`).
  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };

  /// Parse from a decoded JSON map.
  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );

  @override
  String toString() =>
      'AuthResult(accessToken: ${_mask(accessToken)}, '
      'refreshToken: ${_mask(refreshToken)}, user: $user)';

  static String _mask(String token) =>
      token.length <= 8 ? '***' : '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise serialization round-trips
// ─────────────────────────────────────────────────────────────
void main() {
  final user = UserDto(
    id: '1',
    name: 'Ali',
    email: 'ali@test.com',
    status: 'active',
  );

  final result = AuthResult(
    accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.access',
    refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh',
    user: user,
  );

  // Test 1: encode to JSON (what the controller sends)
  final encoded = jsonEncode(result.toJson());
  print('encoded  → $encoded');

  // Test 2: decode back (what a client would do)
  final decoded = AuthResult.fromJson(
    jsonDecode(encoded) as Map<String, dynamic>,
  );
  print('decoded  → $decoded');

  // Test 3: equality after round-trip
  print('round-trip equal → ${decoded.user == user}');

  // Test 4: what the controller would actually return
  print('controller body → ${jsonEncode({
    'message': 'Login successful',
    ...result.toJson(),
  })}');
}