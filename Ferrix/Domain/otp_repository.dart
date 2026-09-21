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
  static final _regex = RegExp(r'^\d{6}$');
  final String value;
  OtpCode._(this.value);

  factory OtpCode(String raw) {
    if (!_regex.hasMatch(raw)) {
      throw const ValidationError('OTP must be exactly 6 digits');
    }
    return OtpCode._(raw);
  }

  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  bool operator ==(Object other) => other is OtpCode && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/enums/otp_purpose.dart
// ─────────────────────────────────────────────────────────────
enum OtpPurpose { emailVerification, passwordReset }

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/entities/otp.dart
// ─────────────────────────────────────────────────────────────
class Otp {
  final Email email;
  final OtpCode code;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  final int attempts;

  Otp({
    required this.email,
    required this.code,
    required this.purpose,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Otp copyWith({int? attempts}) => Otp(
        email: email,
        code: code,
        purpose: purpose,
        expiresAt: expiresAt,
        attempts: attempts ?? this.attempts,
      );

  @override
  String toString() =>
      'Otp(email: $email, purpose: $purpose, code: $code, '
      'attempts: $attempts, expired: $isExpired)';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your OtpRepository port, unchanged
// ─────────────────────────────────────────────────────────────
abstract class OtpRepository {
  Future<void> save(Otp otp);
  Future<Otp?> find(Email email, OtpPurpose purpose);
  Future<void> delete(Email email, OtpPurpose purpose);
}

// ─────────────────────────────────────────────────────────────
// A simple in-memory test implementation (for demonstration)
// ─────────────────────────────────────────────────────────────
class InMemoryOtpRepository implements OtpRepository {
  final Map<(String, OtpPurpose), Otp> _store = {};

  (String, OtpPurpose) _key(Email e, OtpPurpose p) => (e.value, p);

  @override
  Future<void> save(Otp otp) async {
    _store[_key(otp.email, otp.purpose)] = otp;
  }

  @override
  Future<Otp?> find(Email email, OtpPurpose purpose) async =>
      _store[_key(email, purpose)];

  @override
  Future<void> delete(Email email, OtpPurpose purpose) async {
    _store.remove(_key(email, purpose));
  }

  int get size => _store.length;
}

// ─────────────────────────────────────────────────────────────
// A fake that lets us test failing behavior
// ─────────────────────────────────────────────────────────────
class FailingOtpRepository implements OtpRepository {
  final String reason;
  FailingOtpRepository(this.reason);

  @override
  Future<void> save(Otp otp) async => throw Exception(reason);

  @override
  Future<Otp?> find(Email email, OtpPurpose purpose) async =>
      throw Exception(reason);

  @override
  Future<void> delete(Email email, OtpPurpose purpose) async =>
      throw Exception(reason);
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the port contract
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final repo = InMemoryOtpRepository();
  final ali = Email('ali@test.com');
  final sara = Email('sara@test.com');

  // Test 1: empty repository
  print('find (empty)             → ${await repo.find(ali, OtpPurpose.emailVerification)}');

  // Test 2: save + find
  final otp = Otp(
    email: ali,
    code: OtpCode.generated('483920'),
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
  await repo.save(otp);
  print('find (after save)        → ${await repo.find(ali, OtpPurpose.emailVerification)}');
  print('repository size          → ${repo.size}');

  // Test 3: purpose isolation
  print('different purpose        → ${await repo.find(ali, OtpPurpose.passwordReset)}');

  // Test 4: email isolation
  print('different email          → ${await repo.find(sara, OtpPurpose.emailVerification)}');

  // Test 5: multiple OTPs coexist
  await repo.save(Otp(
    email: ali,
    code: OtpCode.generated('112233'),
    purpose: OtpPurpose.passwordReset,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  ));
  print('after adding reset       → size=${repo.size}');
  print('  verification code      → ${(await repo.find(ali, OtpPurpose.emailVerification))?.code}');
  print('  reset code             → ${(await repo.find(ali, OtpPurpose.passwordReset))?.code}');

  // Test 6: save overwrites (same email + purpose)
  await repo.save(Otp(
    email: ali,
    code: OtpCode.generated('999999'),
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  ));
  print('after overwrite          → ${(await repo.find(ali, OtpPurpose.emailVerification))?.code}');
  print('repository size          → ${repo.size} (unchanged)');

  // Test 7: delete
  await repo.delete(ali, OtpPurpose.emailVerification);
  print('after delete             → ${await repo.find(ali, OtpPurpose.emailVerification)}');

  // Test 8: delete missing → no-op (doesn't throw)
  await repo.delete(sara, OtpPurpose.emailVerification);
  print('delete missing           → no error');

  // Test 9: port is substitutable
  final OtpRepository failing = FailingOtpRepository('DB unavailable');
  try {
    await failing.find(ali, OtpPurpose.passwordReset);
  } catch (e) {
    print('failing impl propagates  → $e');
  }
}