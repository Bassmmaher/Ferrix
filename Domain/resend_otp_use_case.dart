import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

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
// Stub: lib/domain/value_objects/otp_code.dart
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// Stub: enums
// ─────────────────────────────────────────────────────────────
enum OtpPurpose { emailVerification, passwordReset }
enum UserStatus { unverified, active, disabled }

// ─────────────────────────────────────────────────────────────
// Stub: value objects
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

class FullName {
  final String value;
  FullName._(this.value);
  factory FullName(String raw) => FullName._(raw.trim());
  @override
  String toString() => value;
}

class HashedPassword {
  final String value;
  HashedPassword(this.value);
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

  @override
  String toString() =>
      'Otp($email, ${purpose.name}, hash=${hashedCode.substring(0, 8)}...)';
}

// ─────────────────────────────────────────────────────────────
// Stub: repositories
// ─────────────────────────────────────────────────────────────
abstract class UserRepository {
  Future<User?> findByEmail(Email email);
  Future<User?> findById(UserId id);
  Future<void> save(User user);
  Future<void> update(User user);
}

abstract class OtpRepository {
  Future<void> save(Otp otp);
  Future<Otp?> find(Email email, OtpPurpose purpose);
  Future<void> delete(Email email, OtpPurpose purpose);
}

abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/services/auth_domain_service.dart
// ─────────────────────────────────────────────────────────────
class AuthDomainService {
  final Random _rng = Random.secure();

  OtpCode generateOtp() {
    final code = List.generate(6, (_) => _rng.nextInt(10)).join();
    return OtpCode.generated(code);
  }
}

// ─────────────────────────────────────────────────────────────
// Concrete fakes for the test
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
  Future<User?> findById(UserId id) async {
    for (final u in _users) {
      if (u.id == id) return u;
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

class RecordingEmailSender implements EmailSender {
  final List<({Email to, OtpCode code})> sent = [];

  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    sent.add((to: to, code: code));
  }
}

// ─────────────────────────────────────────────────────────────
// The real thing — your ResendOtpUseCase, unchanged
// ─────────────────────────────────────────────────────────────
class ResendOtpUseCase {
  final UserRepository _users;
  final OtpRepository _otps;
  final EmailSender _emails;
  final AuthDomainService _domain;

  ResendOtpUseCase({
    required UserRepository users,
    required OtpRepository otps,
    required EmailSender emails,
    required AuthDomainService domain,
  })  : _users = users,
        _otps = otps,
        _emails = emails,
        _domain = domain;

  Future<void> call({required String email}) async {
    final voEmail = Email(email);

    final user = await _users.findByEmail(voEmail);
    if (user == null) throw const UserNotFoundError();
    if (user.status == UserStatus.active) {
      throw const ValidationError('Account already verified');
    }

    // Delete old + create new
    await _otps.delete(voEmail, OtpPurpose.emailVerification);
    final code = _domain.generateOtp();
    final hashed = sha256.convert(utf8.encode(code.value)).toString();

    await _otps.save(Otp(
      email: voEmail,
      hashedCode: hashed,
      purpose: OtpPurpose.emailVerification,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    ));

    await _emails.sendOtp(voEmail, code);
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final users = FakeUserRepository();
  final otps = FakeOtpRepository();
  final emails = RecordingEmailSender();
  final domain = AuthDomainService();

  final useCase = ResendOtpUseCase(
    users: users,
    otps: otps,
    emails: emails,
    domain: domain,
  );

  // Seed an unverified user
  final ali = User(
    id: UserId('u-1'),
    name: FullName('Ali Hassan'),
    email: Email('ali@test.com'),
    passwordHash: HashedPassword('hash'),
    status: UserStatus.unverified,
    createdAt: DateTime.utc(2025, 1, 1),
  );
  await users.save(ali);

  // Seed an ACTIVE (already verified) user
  final sara = User(
    id: UserId('u-2'),
    name: FullName('Sara Adel'),
    email: Email('sara@test.com'),
    passwordHash: HashedPassword('hash'),
    status: UserStatus.active,
    createdAt: DateTime.utc(2025, 1, 2),
  );
  await users.save(sara);

  // Test 1: valid resend for unverified user
  await _tryAsync('valid resend', () async {
    await useCase.call(email: 'ali@test.com');
    print('  ✅ OTPs stored=${otps.size}, emails sent=${emails.sent.length}');
    print('  ✅ sent code=${emails.sent.last.code}');
  });

  // Test 2: resend overwrites old OTP
  await _tryAsync('resend overwrites', () async {
    final first = emails.sent.last.code.value;
    await useCase.call(email: 'ali@test.com');
    final second = emails.sent.last.code.value;
    print('  ✅ OTP count still ${otps.size}');
    print('  ✅ codes differ? ${first != second}');
  });

  // Test 3: unknown email
  await _tryAsync('unknown email', () async {
    await useCase.call(email: 'nobody@test.com');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 4: already-active user
  await _tryAsync('already verified', () async {
    await useCase.call(email: 'sara@test.com');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 5: invalid email format
  await _tryAsync('invalid email', () async {
    await useCase.call(email: 'not-an-email');
    print('  ⚠️  UNEXPECTED SUCCESS');
  });

  // Test 6: email is normalized (uppercase/whitespace)
  await _tryAsync('normalized email', () async {
    await useCase.call(email: '  ALI@TEST.COM  ');
    print('  ✅ normalized sent to ${emails.sent.last.to}');
  });

  // Test 7: OTP is hashed in the store
  await _tryAsync('OTP stored hashed', () async {
    final stored = await otps.find(
      Email('ali@test.com'),
      OtpPurpose.emailVerification,
    );
    final lastCode = emails.sent.last.code.value;
    print('  ✅ stored hash = ${stored!.hashedCode.substring(0, 16)}...');
    print('  ✅ hash != plaintext code: ${stored.hashedCode != lastCode}');
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