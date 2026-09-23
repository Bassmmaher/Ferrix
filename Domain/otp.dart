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
enum OtpPurpose { emailVerification, passwordReset }

// ─────────────────────────────────────────────────────────────
// The real thing — your Otp entity, unchanged
// ─────────────────────────────────────────────────────────────
class Otp {
  final Email email;
  final String hashedCode;
  final OtpPurpose purpose;
  final DateTime expiresAt;
  int attempts;

  Otp({
    required this.email,
    required this.hashedCode,
    required this.purpose,
    required this.expiresAt,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the entity
// ─────────────────────────────────────────────────────────────
void main() {
  final email = Email('ali@test.com');

  // Test 1: basic construction
  final otp = Otp(
    email: email,
    hashedCode: r'$2a$12$abcdefghijklmnopqrstuv',
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
  print('otp          → email=$email, purpose=${otp.purpose}, '
      'attempts=${otp.attempts}, expired=${otp.isExpired}');

  // Test 2: mutation of attempts
  otp.attempts++;
  otp.attempts++;
  print('after 2x++   → attempts=${otp.attempts}');

  // Test 3: expired OTP
  final expiredOtp = Otp(
    email: email,
    hashedCode: 'xyz',
    purpose: OtpPurpose.passwordReset,
    expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
  );
  print('expired otp  → isExpired=${expiredOtp.isExpired}');

  // Test 4: boundary — expires exactly at "now"
  final boundary = Otp(
    email: email,
    hashedCode: 'xyz',
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.now(),
  );
  // Allow a moment for the clock to tick
  print('boundary     → isExpired=${boundary.isExpired} '
      '(should be true since now > expiresAt)');

  // Test 5: ⚠️ mutation leak — the same object in two places
  final shared = Otp(
    email: email,
    hashedCode: 'shared',
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
  final copy1 = shared;
  final copy2 = shared;
  copy1.attempts = 5;
  print('mutation leak→ copy2.attempts=${copy2.attempts} '
      '(expected 5 — SAME INSTANCE)');

  // Test 6: no equality → two logically equal OTPs compare unequal
  final a = Otp(
    email: email,
    hashedCode: 'aaa',
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.utc(2030),
  );
  final b = Otp(
    email: email,
    hashedCode: 'aaa',
    purpose: OtpPurpose.emailVerification,
    expiresAt: DateTime.utc(2030),
  );
  print('a == b       → ${a == b}   (should be true)');
}