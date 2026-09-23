// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/errors/auth_errors.dart
// ─────────────────────────────────────────────────────────────
sealed class AuthError implements Exception {
  final String message;
  const AuthError(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class ValidationError extends AuthError {
  const ValidationError(super.message);
}

class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError() : super('Invalid email or password');
}

class UserNotVerifiedError extends AuthError {
  const UserNotVerifiedError() : super('Email not verified');
}

class UserNotFoundError extends AuthError {
  const UserNotFoundError() : super('User not found');
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
class RawPassword {
  final String value;
  RawPassword(this.value);
  @override
  String toString() => 'RawPassword(***)';
}

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
// Stub: lib/domain/value_objects/user_id.dart
// ─────────────────────────────────────────────────────────────
class UserId {
  final String value;
  UserId(this.value);
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
// Stub: lib/domain/repositories/password_hasher.dart
// ─────────────────────────────────────────────────────────────
abstract class PasswordHasher {
  HashedPassword hash(RawPassword password);
  bool verify(RawPassword password, HashedPassword hash);
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/token_service.dart
// ─────────────────────────────────────────────────────────────
class TokenPair {
  final String accessToken;
  final String refreshToken;
  const TokenPair({required this.accessToken, required this.refreshToken});
}

abstract class TokenService {
  TokenPair issue(UserId userId);
  UserId? verifyAccess(String token);
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/services/auth_domain_service.dart
// ─────────────────────────────────────────────────────────────
class AuthDomainService {
  void assertCanLogin(User user, RawPassword password, bool passwordMatches) {
    if (!passwordMatches) throw const InvalidCredentialsError();
    if (user.status != UserStatus.active) throw const UserNotVerifiedError();
  }
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/application/dto/auth_dtos.dart
// ─────────────────────────────────────────────────────────────
class UserDto {
  final String id;
  final String name;
  final String email;
  final String status;
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  @override
  String toString() =>
      'UserDto(id: $id, name: $name, email: $email, status: $status)';
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final UserDto user;
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

// ─────────────────────────────────────────────────────────────
// Concrete stubs for the test
// ─────────────────────────────────────────────────────────────
class FakeUserRepository implements UserRepository {
  final Map<String, User> _byEmail = {};

  @override
  Future<User?> findByEmail(Email email) async => _byEmail[email.value];

  @override
  Future<User?> findById(UserId id) async =>
      _byEmail.values.where((u) => u.id == id).firstOrNull;

  @override
  Future<void> save(User user) async => _byEmail[user.email.value] = user;

  @override
  Future<void> update(User user) async => _byEmail[user.email.value] = user;
}

class FakePasswordHasher implements PasswordHasher {
  final Map<String, String> _plaintextToHash = {};

  @override
  HashedPassword hash(RawPassword password) {
    final h = 'hash_${password.value}';
    _plaintextToHash[h] = password.value;
    return HashedPassword(h);
  }

  @override
  bool verify(RawPassword password, HashedPassword hash) =>
      _plaintextToHash[hash.value] == password.value;
}

class FakeTokenService implements TokenService {
  @override
  TokenPair issue(UserId userId) => TokenPair(
        accessToken: 'access-${userId.value}',
        refreshToken: 'refresh-${userId.value}',
      );

  @override
  UserId? verifyAccess(String token) =>
      token.startsWith('access-')
          ? UserId(token.substring(7))
          : null;
}

// ─────────────────────────────────────────────────────────────
// The real thing — your LoginUseCase, unchanged
// ─────────────────────────────────────────────────────────────
class LoginUseCase {
  final UserRepository _users;
  final PasswordHasher _hasher;
  final TokenService _tokens;
  final AuthDomainService _domain;

  LoginUseCase({
    required UserRepository users,
    required PasswordHasher hasher,
    required TokenService tokens,
    required AuthDomainService domain,
  })  : _users = users,
        _hasher = hasher,
        _tokens = tokens,
        _domain = domain;

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    final voEmail = Email(email);
    final voPassword = RawPassword(password);

    final user = await _users.findByEmail(voEmail);
    // Do not reveal whether email exists → same error for both
    if (user == null) throw const InvalidCredentialsError();

    final matches = _hasher.verify(voPassword, user.passwordHash);
    // Enforces both "password correct" AND "status == active"
    _domain.assertCanLogin(user, voPassword, matches);

    final pair = _tokens.issue(user.id);

    return AuthResult(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
      user: UserDto(
        id: user.id.value,
        name: user.name.value,
        email: user.email.value,
        status: user.status.name,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise every branch
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final users = FakeUserRepository();
  final hasher = FakePasswordHasher();
  final tokens = FakeTokenService();
  final domain = AuthDomainService();

  final useCase = LoginUseCase(
    users: users,
    hasher: hasher,
    tokens: tokens,
    domain: domain,
  );

  // Seed a verified user
  final ali = User(
    id: UserId('u-1'),
    name: FullName('Ali Hassan'),
    email: Email('ali@test.com'),
    passwordHash: hasher.hash(RawPassword('correct-horse')),
    status: UserStatus.active,
    createdAt: DateTime.utc(2025, 1, 1),
  );
  await users.save(ali);

  // Seed an unverified user
  final sara = User(
    id: UserId('u-2'),
    name: FullName('Sara Adel'),
    email: Email('sara@test.com'),
    passwordHash: hasher.hash(RawPassword('correct-horse')),
    status: UserStatus.unverified,
    createdAt: DateTime.utc(2025, 1, 2),
  );
  await users.save(sara);

  // Test 1: valid login
  await _tryAsync('valid login', () async {
    final res = await useCase.call(
      email: 'ali@test.com',
      password: 'correct-horse',
    );
    print('  ✅ access=${res.accessToken}, refresh=${res.refreshToken}');
    print('  ✅ user=${res.user}');
  });

  // Test 2: wrong password
  await _tryAsync('wrong password', () async {
    await useCase.call(email: 'ali@test.com', password: 'wrong');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 3: unknown email (same error as wrong password — good)
  await _tryAsync('unknown email', () async {
    await useCase.call(email: 'nobody@test.com', password: 'x');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 4: unverified user
  await _tryAsync('unverified user', () async {
    await useCase.call(email: 'sara@test.com', password: 'correct-horse');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 5: invalid email format → ValidationError
  await _tryAsync('invalid email', () async {
    await useCase.call(email: 'not-an-email', password: 'x');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 6: email normalization (uppercase, whitespace)
  await _tryAsync('normalized email', () async {
    final res = await useCase.call(
      email: '  ALI@TEST.COM  ',
      password: 'correct-horse',
    );
    print('  ✅ normalized → user=${res.user.email}');
  });
}

Future<void> _tryAsync(String label, Future<void> Function() fn) async {
  try {
    await fn();
  } on AuthError catch (e) {
    print('$label → ${e.runtimeType}: ${e.message}');
  } catch (e, st) {
    print('$label → UNEXPECTED: $e\n$st');
  }
}