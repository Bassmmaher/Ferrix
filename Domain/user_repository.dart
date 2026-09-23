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
// Stub: value objects
// ─────────────────────────────────────────────────────────────
class Email {
  static final _regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final String value;
  Email._(this.value);

  factory Email(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty || t.length > 254 || !_regex.hasMatch(t)) {
      throw const ValidationError('Invalid email address');
    }
    return Email._(t);
  }

  @override
  bool operator ==(Object other) => other is Email && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

class UserId {
  static final _regex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  final String value;
  UserId._(this.value);

  factory UserId(String raw) {
    final t = raw.trim().toLowerCase();
    if (!_regex.hasMatch(t)) {
      throw const ValidationError('Invalid user id');
    }
    return UserId._(t);
  }

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

class FullName {
  final String value;
  FullName._(this.value);

  factory FullName(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t.length > 100) {
      throw const ValidationError('Name must be 1–100 characters');
    }
    return FullName._(t);
  }

  @override
  String toString() => value;
}

class HashedPassword {
  final String value;
  HashedPassword(this.value);
  @override
  String toString() => 'HashedPassword(***)';
}

// ─────────────────────────────────────────────────────────────
// Stub: enums
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
      'User(id: $id, email: $email, status: ${status.name})';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your UserRepository port, unchanged
// ─────────────────────────────────────────────────────────────
abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<User?> findById(UserId id);
  Future<void> save(User user);
  Future<void> update(User user);
}

// ─────────────────────────────────────────────────────────────
// Fake implementation with two indexes (by id, by email)
// ─────────────────────────────────────────────────────────────
class FakeUserRepository implements UserRepository {
  final Map<String, User> _byId = {};
  final Map<String, String> _emailToId = {};

  @override
  Future<User?> findByEmail(Email email) async {
    final id = _emailToId[email.value];
    return id == null ? null : _byId[id];
  }

  @override
  Future<User?> findById(UserId id) async => _byId[id.value];

  @override
  Future<void> save(User user) async {
    _byId[user.id.value] = user;
    _emailToId[user.email.value] = user.id.value;
  }

  @override
  Future<void> update(User user) async {
    // If the email changed for the same user, remove the old mapping.
    final existing = _byId[user.id.value];
    if (existing != null && existing.email != user.email) {
      _emailToId.remove(existing.email.value);
    }
    _byId[user.id.value] = user;
    _emailToId[user.email.value] = user.id.value;
  }

  int get count => _byId.length;
}

/// A repository that always throws — for testing error propagation.
class FailingUserRepository implements UserRepository {
  @override
  Future<User?> findByEmail(Email email) async =>
      throw StateError('user repo unavailable');

  @override
  Future<User?> findById(UserId id) async =>
      throw StateError('user repo unavailable');

  @override
  Future<void> save(User user) async =>
      throw StateError('user repo unavailable');

  @override
  Future<void> update(User user) async =>
      throw StateError('user repo unavailable');
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the port contract
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final repo = FakeUserRepository();

  final ali = User(
    id: UserId('11111111-1111-1111-1111-111111111111'),
    name: FullName('Ali Hassan'),
    email: Email('ali@test.com'),
    passwordHash: HashedPassword('hash_ali'),
    status: UserStatus.unverified,
    createdAt: DateTime.utc(2025, 1, 1),
  );

  final sara = User(
    id: UserId('22222222-2222-2222-2222-222222222222'),
    name: FullName('Sara Adel'),
    email: Email('sara@test.com'),
    passwordHash: HashedPassword('hash_sara'),
    status: UserStatus.active,
    createdAt: DateTime.utc(2025, 1, 2),
  );

  // Test 1: empty repo
  print('findByEmail (empty) → ${await repo.findByEmail(ali.email)}');
  print('findById    (empty) → ${await repo.findById(ali.id)}');

  // Test 2: save + find by email
  await repo.save(ali);
  print('findByEmail (ali)   → ${await repo.findByEmail(ali.email)}');

  // Test 3: find by id
  print('findById    (ali)   → ${await repo.findById(ali.id)}');

  // Test 4: unknown email / id
  print('findByEmail (none)  → ${await repo.findByEmail(Email('x@y.com'))}');
  print('findById    (none)  → '
      '${await repo.findById(UserId('33333333-3333-3333-3333-333333333333'))}');

  // Test 5: save second user
  await repo.save(sara);
  print('count after 2 saves → ${repo.count}');

  // Test 6: update — change status
  final activated = ali.copyWith(status: UserStatus.active);
  await repo.update(activated);
  final reloaded = await repo.findByEmail(ali.email);
  print('after update status → ${reloaded?.status}');

  // Test 7: failing impl propagates
  final UserRepository failing = FailingUserRepository();
  try {
    await failing.findByEmail(ali.email);
  } catch (e) {
    print('failing impl        → $e');
  }

  // Test 8: overwriting save (same id, same email)
  final updated = ali.copyWith(status: UserStatus.disabled);
  await repo.save(updated);
  print('after overwrite     → ${(await repo.findById(ali.id))?.status}');
  print('count unchanged     → ${repo.count}');
}