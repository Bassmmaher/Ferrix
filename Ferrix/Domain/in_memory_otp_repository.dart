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
// Stub: lib/domain/enums/otp_purpose.dart
// ─────────────────────────────────────────────────────────────
enum OtpPurpose { signup, passwordReset, login }

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/otp_code.dart
// ─────────────────────────────────────────────────────────────
class OtpCode {
  final String value;
  const OtpCode._(this.value);

  factory OtpCode.fromRaw(String raw) {
    if (raw.length != 6 || int.tryParse(raw) == null) {
      throw const ValidationError('OTP must be 6 digits');
    }
    return OtpCode._(raw);
  }

  @override
  bool operator ==(Object other) => other is OtpCode && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'OtpCode($value)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/entities/otp.dart
// ─────────────────────────────────────────────────────────────
class Otp {
  final Email email;
  final OtpCode code;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  int attempts;

  Otp({
    required this.email,
    required this.code,
    required this.purpose,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() =>
      'Otp(email: $email, purpose: $purpose, code: $code, '
      'attempts: $attempts, expired: $isExpired)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/otp_repository.dart
// ─────────────────────────────────────────────────────────────
abstract class OtpRepository {
  Future<void> save(Otp otp);
  Future<Otp?> find(Email email, OtpPurpose purpose);
  Future<void> delete(Email email, OtpPurpose purpose);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your InMemoryOtpRepository, unchanged
// ─────────────────────────────────────────────────────────────
class InMemoryOtpRepository implements OtpRepository {
  final Map<String, Otp> _store = {};

  String _key(Email e, OtpPurpose p) => '${e.value}::${p.name}';

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
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise save / find / delete
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final repo = InMemoryOtpRepository();

  final email = Email('ali@test.com');
  final other = Email('sara@test.com');

  final signupOtp = Otp(
    email: email,
    code: OtpCode.fromRaw('111111'),
    purpose: OtpPurpose.signup,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );

  // Test 1: find on empty store → null
  print('find before save → ${await repo.find(email, OtpPurpose.signup)}');

  // Test 2: save + find
  await repo.save(signupOtp);
  final found = await repo.find(email, OtpPurpose.signup);
  print('find after save  → $found');

  // Test 3: different purpose → not found (key isolation)
  print('different purpose→ ${await repo.find(email, OtpPurpose.passwordReset)}');

  // Test 4: different email → not found
  print('different email  → ${await repo.find(other, OtpPurpose.signup)}');

  // Test 5: overwrite (same email + purpose)
  final newOtp = Otp(
    email: email,
    code: OtpCode.fromRaw('222222'),
    purpose: OtpPurpose.signup,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
  await repo.save(newOtp);
  final overwritten = await repo.find(email, OtpPurpose.signup);
  print('after overwrite  → ${overwritten?.code}');

  // Test 6: multiple purposes coexist
  await repo.save(Otp(
    email: email,
    code: OtpCode.fromRaw('333333'),
    purpose: OtpPurpose.passwordReset,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  ));
  print('signup still     → ${(await repo.find(email, OtpPurpose.signup))?.code}');
  print('reset now        → ${(await repo.find(email, OtpPurpose.passwordReset))?.code}');

  // Test 7: delete
  await repo.delete(email, OtpPurpose.signup);
  print('after delete     → ${await repo.find(email, OtpPurpose.signup)}');
  print('other purpose    → ${await repo.find(email, OtpPurpose.passwordReset)}');

  // Test 8: delete nonexistent → no error
  await repo.delete(other, OtpPurpose.signup);
  print('delete missing   → no error');
}