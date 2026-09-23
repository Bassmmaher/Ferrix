// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/email.dart
// ─────────────────────────────────────────────────────────────
class Email {
  final String value;
  Email(this.value) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value)) {
      throw ArgumentError('Invalid email: $value');
    }
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/otp_code.dart
// ─────────────────────────────────────────────────────────────
class OtpCode {
  final String value;
  const OtpCode._(this.value);

  factory OtpCode.fromRaw(String raw) {
    if (raw.length != 6 || int.tryParse(raw) == null) {
      throw ArgumentError('OTP must be 6 digits');
    }
    return OtpCode._(raw);
  }

  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  String toString() => 'OtpCode($value)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/email_sender.dart
// ─────────────────────────────────────────────────────────────
abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your ConsoleEmailSender, unchanged
// ─────────────────────────────────────────────────────────────
class ConsoleEmailSender implements EmailSender {
  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📧 DEV EMAIL → ${to.value}');
    print('🔐 OTP CODE : ${code.value}');
    print('⏱  Expires  : 10 minutes');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final sender = ConsoleEmailSender();

  // Test 1: send a generated OTP
  await sender.sendOtp(
    Email('ali@test.com'),
    OtpCode.generated('483920'),
  );

  // Test 2: send a user-provided OTP (validated via fromRaw)
  await sender.sendOtp(
    Email('sara@example.org'),
    OtpCode.fromRaw('123456'),
  );

  // Test 3: confirm the invalid-input guard works
  try {
    OtpCode.fromRaw('abc');
  } catch (e) {
    print('guard → $e');
  }
}