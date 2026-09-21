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
  final String value;
  const OtpCode._(this.value);

  factory OtpCode.fromRaw(String raw) {
    if (raw.length != 6 || int.tryParse(raw) == null) {
      throw const ValidationError('OTP must be 6 digits');
    }
    return OtpCode._(raw);
  }

  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  bool operator ==(Object other) => other is OtpCode && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'OtpCode($value)';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your EmailSender port, unchanged
// ─────────────────────────────────────────────────────────────
abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}

// ─────────────────────────────────────────────────────────────
// A test implementation — captures calls instead of sending
// ─────────────────────────────────────────────────────────────
class FakeEmailSender implements EmailSender {
  final List<({Email to, OtpCode code})> sent = [];

  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    sent.add((to: to, code: code));
  }
}

// ─────────────────────────────────────────────────────────────
// A failing implementation — for testing error handling
// ─────────────────────────────────────────────────────────────
class FailingEmailSender implements EmailSender {
  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    throw Exception('SMTP connection refused');
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the port contract
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  // Test 1: fake sender records the call
  final fake = FakeEmailSender();
  await fake.sendOtp(Email('ali@test.com'), OtpCode.generated('483920'));
  print('sent count    → ${fake.sent.length}');
  print('sent to       → ${fake.sent.first.to}');
  print('sent code     → ${fake.sent.first.code}');

  // Test 2: verify Email is normalized before reaching the port
  await fake.sendOtp(Email('  ALI@TEST.COM  '), OtpCode.generated('111111'));
  print('normalized    → ${fake.sent.last.to}');

  // Test 3: async — caller must await
  final future = fake.sendOtp(
    Email('sara@example.org'),
    OtpCode.generated('222222'),
  );
  // ignore: unnecessary_type_check
  print('is Future?    → ${future is Future<void>}');
  await future;
  print('after await   → sent count = ${fake.sent.length}');

  // Test 4: failures propagate to the caller
  final failing = FailingEmailSender();
  try {
    await failing.sendOtp(Email('x@y.com'), OtpCode.generated('000000'));
  } catch (e) {
    print('failure       → $e');
  }
}