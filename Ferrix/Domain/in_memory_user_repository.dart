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
// Stub: lib/domain/value_objects/full_name.dart
// ─────────────────────────────────────────────────────────────
class FullName {
  final String value;
  FullName._(this.value);

  factory FullName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw const ValidationError('Name must be 1–100 characters');
    }
    return FullName._(trimmed);
  }

  @override
  bool operator ==(Object other) => other is FullName && other.value == value;
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
// Stub: lib/domain/enums/user_status.dart
// ─────────────────────────────────────────────────────────────
enum UserStatus { unverified, active, disabled }

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/entities/user.dart
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

  @override
  String toString() =>
      'User(id: $id, email: $email, status: $status)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────
abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<User?> findById(UserId id);
  Future<void> save(User user);
  Future<void> update(User user);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your InMemoryUserRepository, unchanged
// ─────────────────────────────────────────────────────────────
class InMemoryUserRepository implements UserRepository {
  final Map<String, User> _byEmail = {};

  @override
  Future<User?> findByEmail(Email email) async => _byEmail[email.value];

  @override
  Future<User?> findById(UserId id) async {
    for (final u in _byEmail.values) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  Future<void> save(User user) async {
    _byEmail[user.email.value] = user;
  }

  @override
  Future<void> update(User user) async {
    _byEmail[user.email.value] = user;
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise all four methods
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final repo = InMemoryUserRepository();

  final ali = User(
    id: UserId('u-1'),
    name: FullName('Ali Hassan'),
    email: Email('ali@test.com'),
    passwordHash: HashedPassword('hash_alice_1234567890'),
    status: UserStatus.unverified,
    createdAt: DateTime.utc(2025, 1, 1, 12, 0),
  );

  final sara = User(
    id: UserId('u-2'),
    name: FullName('Sara Adel'),
    email: Email('sara@test.com'),
    passwordHash: HashedPassword('hash_sara_0987654321'),
    status: UserStatus.active,
    createdAt: DateTime.utc(2025, 1, 2, 12, 0),
  );

  // Test 1: find before save → null
  print('findByEmail (empty)   → ${await repo.findByEmail(ali.email)}');
  print('findById    (empty)   → ${await repo.findById(ali.id)}');

  // Test 2: save + find by email
  await repo.save(ali);
  print('findByEmail (ali)     → ${await repo.findByEmail(ali.email)}');

  // Test 3: find by id
  print('findById    (u-1)     → ${await repo.findById(UserId('u-1'))}');

  // Test 4: unknown email → null
  print('findByEmail (unknown) → ${await repo.findByEmail(Email('x@y.com'))}');

  // Test 5: unknown id → null
  print('findById    (unknown) → ${await repo.findById(UserId('nope'))}');

  // Test 6: save second user
  await repo.save(sara);
  print('findById    (u-2)     → ${await repo.findById(UserId('u-2'))}');

  // Test 7: update — verify user status changed
  final verified = ali.copyWith(status: UserStatus.active);
  await repo.update(verified);
  final reloaded = await repo.findByEmail(ali.email);
  print('after update (status) → ${reloaded?.status}');

  // Test 8: ⚠️ save/update semantics — silent data loss scenario
  final movedUser = User(
    id: ali.id,                          // same id
    name: ali.name,
    email: Email('new-email@test.com'),  // DIFFERENT email
    passwordHash: ali.passwordHash,
    status: ali.status,
    createdAt: ali.createdAt,
  );
  await repo.update(movedUser);
  print('\n─── After "update" with changed email ───');
  print('findByEmail (old)     → ${await repo.findByEmail(ali.email)}');
  print('findByEmail (new)     → ${await repo.findByEmail(movedUser.email)}');
  print('findById    (u-1)     → ${await repo.findById(ali.id)}');
}