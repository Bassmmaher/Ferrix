// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/errors/auth_errors.dart
// ─────────────────────────────────────────────────────────────
sealed class AuthError implements Exception {
  final String message;
  const AuthError(this.message);
  @override
  String toString() => message;
}

class ValidationError extends AuthError {
  const ValidationError(super.message);
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/user_id.dart
// ─────────────────────────────────────────────────────────────
class UserId {
  final String value;
  UserId(this.value) {
    if (value.trim().isEmpty) {
      throw const ValidationError('UserId cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/full_name.dart
// ─────────────────────────────────────────────────────────────
class FullName {
  final String value;
  FullName(this.value) {
    final t = value.trim();
    if (t.isEmpty || t.length > 100) {
      throw const ValidationError('Invalid name');
    }
  }

  @override
  bool operator ==(Object other) => other is FullName && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/email.dart
// ─────────────────────────────────────────────────────────────
class Email {
  static final _regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final String value;
  Email._(this.value);

  factory Email(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty ||
        trimmed.length > 254 ||
        !_regex.hasMatch(trimmed)) {
      throw const ValidationError('Invalid email address');
    }
    return Email._(trimmed);
  }

  @override
  bool operator ==(Object other) => other is Email && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/password.dart
// ─────────────────────────────────────────────────────────────
class HashedPassword {
  final String value;
  HashedPassword(this.value);

  @override
  bool operator ==(Object other) =>
      other is HashedPassword && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'HashedPassword(${value.substring(0, 8)}...)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/user_status.dart
// ─────────────────────────────────────────────────────────────
enum UserStatus { unverified, active, disabled }

// ─────────────────────────────────────────────────────────────
// The real thing — your User entity, unchanged
// ─────────────────────────────────────────────────────────────
class User {
  final UserId id;
  final FullName name;
  final Email email;
  final HashedPassword passwordHash;
  final UserStatus status;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.status,
    required this.createdAt,
  });

  User copyWith({UserStatus? status}) => User(
        id: id,
        name: name,
        email: email,
        passwordHash: passwordHash,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
void main() {
  final user = User(
    id: UserId('u-1'),
    name: FullName('Ali Hassan'),
    email: Email('ali@test.com'),
    passwordHash: HashedPassword('fakehashvalue1234567890'),
    status: UserStatus.unverified,
    createdAt: DateTime.utc(2025, 1, 1, 12, 0),
  );

  print('user         → id=${user.id}, name=${user.name}, '
      'email=${user.email}, status=${user.status}');

  // Test 1: copyWith changes only status
  final activated = user.copyWith(status: UserStatus.active);
  print('activated    → status=${activated.status}');
  print('same id      → ${identical(user.id, activated.id)}');
  print('same email   → ${identical(user.email, activated.email)}');
  print('same created → ${user.createdAt == activated.createdAt}');

  // Test 2: copyWith with no args → identical status
  final clone = user.copyWith();
  print('clone status → ${clone.status} (same as original: '
      '${clone.status == user.status})');

  // Test 3: copyWith(null) falls back to existing value
  final nullCopy = user.copyWith(status: null);
  print('null status  → ${nullCopy.status} (unchanged)');
}