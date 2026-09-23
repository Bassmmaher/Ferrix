import 'dart:convert';
import 'dart:math';

// ─────────────────────────────────────────────────────────────
// Top-level random source (not const, but shared across all Uuid instances)
// ─────────────────────────────────────────────────────────────
final _random = Random.secure();

// ─────────────────────────────────────────────────────────────
// Stub: package:uuid
// ─────────────────────────────────────────────────────────────
class Uuid {
  const Uuid();

  String v4() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant
    final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

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

class EmailAlreadyExistsError extends AuthError {
  const EmailAlreadyExistsError() : super('Email already registered');
}

// ─────────────────────────────────────────────────────────────
// Stub: enums
// ─────────────────────────────────────────────────────────────
enum OtpPurpose { emailVerification, passwordReset }
enum UserStatus { unverified, active, disabled }

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

class RawPassword {
  final String value;
  RawPassword._(this.value);

  factory RawPassword(String raw) {
    if (raw.length < 8) {
      throw const ValidationError('Password must be at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(raw)) {
      throw const ValidationError('Password must contain an uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(raw)) {
      throw const ValidationError('Password must contain a lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(raw)) {
      throw const ValidationError('Password must contain a digit');
    }
    return RawPassword._(raw);
  }

  @override
  String toString() => '********';
}

class HashedPassword {
  final String value;
  HashedPassword(this.value);
  @override
  String toString() => 'HashedPassword(***)';
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

class OtpCode {
  final String value;
  OtpCode._(this.value);
  factory OtpCode.generated(String raw) => OtpCode._(raw);
  @override
  String toString() => value;
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

  @override
  String toString() => 'User($email, ${status.name})';
}

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
}

// ─────────────────────────────────────────────────────────────
// Stub: repositories & services
// ─────────────────────────────────────────────────────────────
abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<void> save(User user);
}

abstract class OtpRepository {
  Future<void> save(Otp otp);
}

abstract class PasswordHasher {
  HashedPassword hash(RawPassword password);
}

abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}

class AuthDomainService {
  OtpCode generateOtp() =>
      OtpCode.generated(List.generate(6, (_) => _random.nextInt(10)).join());
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

  int get count => _users.length;
}

class FakeOtpRepository implements OtpRepository {
  final Map<String, Otp> _store = {};

  @override
  Future<void> save(Otp otp) async =>
      _store['${otp.email.value}::${otp.purpose.name}'] = otp;

  int get size => _store.length;
}

class FakePasswordHasher implements PasswordHasher {
  @override
  HashedPassword hash(RawPassword p) => HashedPassword('hashed:${p.value}');
}

class RecordingEmailSender implements EmailSender {
  final List<({Email to, OtpCode code})> sent = [];

  @override
  Future<void> sendOtp(Email to, OtpCode code) async =>
      sent.add((to: to, code: code));
}

// ─────────────────────────────────────────────────────────────
// The real use case
// ─────────────────────────────────────────────────────────────
class SignUpUseCase {
  static const _uuid = Uuid();

  final UserRepository _users;
  final OtpRepository _otps;
  final PasswordHasher _hasher;
  final EmailSender _emails;
  final AuthDomainService _domain;

  SignUpUseCase({
    required UserRepository users,
    required OtpRepository otps,
    required PasswordHasher hasher,
    required EmailSender emails,
    required AuthDomainService domain,
  })  : _users = users,
        _otps = otps,
        _hasher = hasher,
        _emails = emails,
        _domain = domain;

  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Validate value objects (throws ValidationError)
    final voName = FullName(name);
    final voEmail = Email(email);
    final voPassword = RawPassword(password);

    // 2. Uniqueness
    final existing = await _users.findByEmail(voEmail);
    if (existing != null) throw const EmailAlreadyExistsError();

    // 3. Build user
    final now = DateTime.now().toUtc();
    final user = User(
      id: UserId(_uuid.v4()),
      name: voName,
      email: voEmail,
      passwordHash: _hasher.hash(voPassword),
      status: UserStatus.unverified,
      createdAt: now,
    );
    await _users.save(user);

    // 4. OTP
    final code = _domain.generateOtp();
    final hashed = sha256.convert(utf8.encode(code.value)).toString();

    await _otps.save(Otp(
      email: voEmail,
      hashedCode: hashed,
      purpose: OtpPurpose.emailVerification,
      expiresAt: now.add(const Duration(minutes: 10)),
    ));

    // 5. Send
    await _emails.sendOtp(voEmail, code);
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final users = FakeUserRepository();
  final otps = FakeOtpRepository();
  final hasher = FakePasswordHasher();
  final emails = RecordingEmailSender();
  final domain = AuthDomainService();

  final useCase = SignUpUseCase(
    users: users,
    otps: otps,
    hasher: hasher,
    emails: emails,
    domain: domain,
  );

  Future<void> tryAsync(String label, Future<void> Function() fn) async {
    try {
      await fn();
    } on AuthError catch (e) {
      print('$label → ${e.runtimeType}: ${e.message}');
    } catch (e, st) {
      print('$label → UNEXPECTED: $e\n$st');
    }
  }

  await tryAsync('valid signup', () async {
    await useCase.call(
      name: 'Ali Hassan',
      email: 'ali@test.com',
      password: 'Password1',
    );
    print('  ✅ users=${users.count}, otps=${otps.size}, '
        'emails=${emails.sent.length}');
    print('  ✅ sent code=${emails.sent.last.code}');
  });

  await tryAsync('duplicate email', () async {
    await useCase.call(
      name: 'Other',
      email: 'ali@test.com',
      password: 'Password1',
    );
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  await tryAsync('weak password', () async {
    await useCase.call(
      name: 'New User',
      email: 'new@test.com',
      password: 'short',
    );
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  await tryAsync('invalid email', () async {
    await useCase.call(
      name: 'New User',
      email: 'not-an-email',
      password: 'Password1',
    );
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  await tryAsync('empty name', () async {
    await useCase.call(
      name: '   ',
      email: 'new@test.com',
      password: 'Password1',
    );
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  await tryAsync('normalized email', () async {
    await useCase.call(
      name: 'Sara',
      email: '  SARA@TEST.COM  ',
      password: 'Password1',
    );
    print('  ✅ stored email=${emails.sent.last.to}');
  });
}