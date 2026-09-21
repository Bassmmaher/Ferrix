import 'dart:convert';
import 'dart:math';

// ─────────────────────────────────────────────────────────────
// Stub: package:crypto (fake sha256 for DartPad)
// ─────────────────────────────────────────────────────────────
class _FakeSha256 {
  String convert(List<int> bytes) {
    var h = 2166136261;
    for (final b in bytes) {
      h ^= b;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h.toRadixString(16).padLeft(64, '0');
  }
}
final sha256 = _FakeSha256();

// ─────────────────────────────────────────────────────────────
// Stub: errors
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
class UserNotFoundError extends AuthError {
  const UserNotFoundError() : super('User not found');
}
class OtpNotFoundError extends AuthError {
  const OtpNotFoundError() : super('No OTP found');
}
class OtpExpiredError extends AuthError {
  const OtpExpiredError() : super('OTP expired');
}
class OtpTooManyAttemptsError extends AuthError {
  const OtpTooManyAttemptsError() : super('Too many attempts');
}
class OtpInvalidError extends AuthError {
  const OtpInvalidError() : super('Invalid OTP');
}

// ─────────────────────────────────────────────────────────────
// Stub: enums
// ─────────────────────────────────────────────────────────────
enum UserStatus { pending, active, locked }
enum OtpPurpose { emailVerification, passwordReset }

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

class OtpCode {
  final String value;
  OtpCode._(this.value);

  factory OtpCode(String raw) {
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
      throw const ValidationError('OTP must be exactly 6 digits');
    }
    return OtpCode._(raw);
  }

  factory OtpCode.generated(String raw) => OtpCode._(raw);
  @override
  String toString() => value;
}

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

class FullName {
  final String value;
  FullName(this.value);
  @override
  String toString() => value;
}

class HashedPassword {
  final String value;
  HashedPassword(this.value);
}

class RawPassword {
  final String value;
  RawPassword(this.value);
  @override
  String toString() => '********';
}

// ─────────────────────────────────────────────────────────────
// Stub: entities
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
  String toString() => 'User($email, ${status.name})';
}

/// OTP entity.
///
/// `attempts` is deliberately `final` — mutations must go through
/// [copyWith] so that persistence is always explicit. This keeps
/// in-memory and DB-backed repositories behaving identically.
class Otp {
  final Email email;
  final String hashedCode;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  final int attempts;

  Otp({
    required this.email,
    required this.hashedCode,
    required this.purpose,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  Otp copyWith({int? attempts}) => Otp(
        email: email,
        hashedCode: hashedCode,
        purpose: purpose,
        expiresAt: expiresAt,
        attempts: attempts ?? this.attempts,
      );

  @override
  String toString() =>
      'Otp($email, ${purpose.name}, attempts=$attempts, '
      'expired=$isExpired)';
}

// ─────────────────────────────────────────────────────────────
// Stub: repositories
// ─────────────────────────────────────────────────────────────
abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<void> save(User user);
  Future<void> update(User user);
}

abstract class OtpRepository {
  Future<void> save(Otp otp);
  Future<Otp?> find(Email email, OtpPurpose purpose);
  Future<void> delete(Email email, OtpPurpose purpose);
}

// ─────────────────────────────────────────────────────────────
// Concrete fakes
// ─────────────────────────────────────────────────────────────
class FakeUserRepository implements UserRepository {
  final List<User> _users = [];

  @override
  Future<User?> findByEmail(Email email) async {
    for (final u in _users) {
      if (u.email == email) return u;
    }
    return null;
  }

  @override
  Future<void> save(User user) async => _users.add(user);

  @override
  Future<void> update(User user) async {
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i >= 0) _users[i] = user;
  }
}

class FakeOtpRepository implements OtpRepository {
  final Map<(String, OtpPurpose), Otp> _store = {};

  @override
  Future<void> save(Otp otp) async =>
      _store[(otp.email.value, otp.purpose)] = otp;

  @override
  Future<Otp?> find(Email email, OtpPurpose purpose) async =>
      _store[(email.value, purpose)];

  @override
  Future<void> delete(Email email, OtpPurpose purpose) async =>
      _store.remove((email.value, purpose));

  int get size => _store.length;
}

// ─────────────────────────────────────────────────────────────
// The real thing — your VerifyEmailUseCase, with fixes applied
// ─────────────────────────────────────────────────────────────
class VerifyEmailUseCase {
  static const _maxAttempts = 5;

  final UserRepository _users;
  final OtpRepository _otps;

  VerifyEmailUseCase({
    required UserRepository users,
    required OtpRepository otps,
  })  : _users = users,
        _otps = otps;

  Future<void> call({required String email, required String otp}) async {
    final voEmail = Email(email);
    final voOtp = OtpCode(otp);

    final user = await _users.findByEmail(voEmail);
    if (user == null) throw const UserNotFoundError();

    // Idempotent for already-active users.
    if (user.status == UserStatus.active) return;

    // Only pending users may verify. Locked users must NOT be able
    // to un-lock themselves by completing email verification.
    if (user.status != UserStatus.pending) {
      throw const UserNotFoundError();
    }

    final entry = await _otps.find(voEmail, OtpPurpose.emailVerification);
    if (entry == null) throw const OtpNotFoundError();

    if (entry.isExpired) {
      await _otps.delete(voEmail, OtpPurpose.emailVerification);
      throw const OtpExpiredError();
    }

    if (entry.attempts >= _maxAttempts) {
      await _otps.delete(voEmail, OtpPurpose.emailVerification);
      throw const OtpTooManyAttemptsError();
    }

    final hashed = sha256.convert(utf8.encode(voOtp.value)).toString();
    if (hashed != entry.hashedCode) {
      // Immutable update — safe across in-memory and DB repos.
      final updated = entry.copyWith(attempts: entry.attempts + 1);
      await _otps.save(updated);
      throw const OtpInvalidError();
    }

    // Success — order matters: activate user first, then delete OTP.
    // If the delete fails, the early-return on `active` prevents reuse.
    await _users.update(user.copyWith(status: UserStatus.active));
    await _otps.delete(voEmail, OtpPurpose.emailVerification);
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise every branch
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  Future<void> tryAsync(String label, Future<void> Function() fn) async {
    try {
      await fn();
      print('$label → ok');
    } on AuthError catch (e) {
      print('$label → ${e.runtimeType}: ${e.message}');
    } catch (e, st) {
      print('$label → UNEXPECTED: $e\n$st');
    }
  }

  Future<(FakeUserRepository, FakeOtpRepository)> seed({
    required String code,
    UserStatus status = UserStatus.pending,
    Duration ttl = const Duration(minutes: 10),
    int attempts = 0,
    bool storeOtp = true,
  }) async {
    final users = FakeUserRepository();
    final otps = FakeOtpRepository();
    final email = Email('ali@test.com');

    await users.save(User(
      id: UserId('u-1'),
      name: FullName('Ali Hassan'),
      email: email,
      passwordHash: HashedPassword('hash'),
      status: status,
      createdAt: DateTime.utc(2025, 1, 1),
    ));

    if (storeOtp) {
      await otps.save(Otp(
        email: email,
        hashedCode: sha256.convert(utf8.encode(code)).toString(),
        purpose: OtpPurpose.emailVerification,
        expiresAt: DateTime.now().toUtc().add(ttl),
        attempts: attempts,
      ));
    }
    return (users, otps);
  }

  // Test 1: valid verification
  {
    final (users, otps) = await seed(code: '483920');
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('valid verify', () async {
      await useCase.call(email: 'ali@test.com', otp: '483920');
      final u = await users.findByEmail(Email('ali@test.com'));
      print('  ✅ status=${u!.status}, otps left=${otps.size}');
    });
  }

  // Test 2: wrong OTP — attempts increments
  {
    final (users, otps) = await seed(code: '483920');
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('wrong OTP', () => useCase.call(
        email: 'ali@test.com', otp: '000000'));
    final stored = await otps.find(
        Email('ali@test.com'), OtpPurpose.emailVerification);
    print('  attempts after failure=${stored?.attempts}');
  }

  // Test 3: already verified → idempotent
  {
    final (users, otps) =
        await seed(code: '483920', status: UserStatus.active);
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('already verified',
        () => useCase.call(email: 'ali@test.com', otp: '483920'));
    print('  ✅ idempotent — no error thrown');
  }

  // Test 4: locked user cannot verify their way to active
  {
    final (users, otps) =
        await seed(code: '483920', status: UserStatus.locked);
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('locked user',
        () => useCase.call(email: 'ali@test.com', otp: '483920'));
    final u = await users.findByEmail(Email('ali@test.com'));
    print('  status still=${u!.status}');
  }

  // Test 5: unknown user
  {
    final users = FakeUserRepository();
    final otps = FakeOtpRepository();
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('unknown user',
        () => useCase.call(email: 'nobody@test.com', otp: '123456'));
  }

  // Test 6: no OTP stored
  {
    final (users, otps) = await seed(code: '483920', storeOtp: false);
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('no OTP',
        () => useCase.call(email: 'ali@test.com', otp: '483920'));
  }

  // Test 7: expired OTP
  {
    final (users, otps) = await seed(
        code: '483920', ttl: const Duration(seconds: -1));
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('expired OTP',
        () => useCase.call(email: 'ali@test.com', otp: '483920'));
    print('  OTPs left after expiry delete=${otps.size}');
  }

  // Test 8: too many attempts
  {
    final (users, otps) = await seed(code: '483920', attempts: 5);
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('too many attempts',
        () => useCase.call(email: 'ali@test.com', otp: '483920'));
    print('  OTPs left after lockout=${otps.size}');
  }

  // Test 9: invalid OTP format
  {
    final (users, otps) = await seed(code: '483920');
    final useCase = VerifyEmailUseCase(users: users, otps: otps);
    await tryAsync('bad format',
        () => useCase.call(email: 'ali@test.com', otp: 'abc'));
  }
}