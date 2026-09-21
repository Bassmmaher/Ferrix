import 'dart:convert';

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
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/email_sender.dart
// ─────────────────────────────────────────────────────────────
abstract class EmailSender {
  Future<void> sendOtp(Email to, OtpCode code);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your ResendEmailSender, unchanged
// ─────────────────────────────────────────────────────────────
/// Replace ConsoleEmailSender with this once you have a real API key.
class ResendEmailSender implements EmailSender {
  final String apiKey;
  ResendEmailSender({required this.apiKey});

  @override
  Future<void> sendOtp(Email to, OtpCode code) async {
    // TODO: POST to https://api.resend.com/emails
    throw UnimplementedError('Configure Resend before using in production');
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the class
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  // Test 1: construction requires a non-null apiKey
  try {
    // ignore: unused_local_variable
    final sender = ResendEmailSender(apiKey: '');
    print('construction → ok (empty key accepted at construction time)');
  } catch (e) {
    print('construction → $e');
  }

  // Test 2: implements the EmailSender port
  final EmailSender sender = ResendEmailSender(apiKey: 're_test_key_123');

  // Test 3: sendOtp throws UnimplementedError
  try {
    await sender.sendOtp(
      Email('ali@test.com'),
      OtpCode.generated('483920'),
    );
    print('sendOtp → no throw (unexpected!)');
  } on UnimplementedError catch (e) {
    print('sendOtp → ${e.runtimeType}: ${e.message}');
  }

  // Test 4: still usable as EmailSender (substitutable)
  print('is EmailSender → ${sender is EmailSender}');
}