import 'dart:math';

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/enums/user_status.dart
// ─────────────────────────────────────────────────────────────
enum UserStatus { active, unverified, disabled }

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/entities/user.dart
// ─────────────────────────────────────────────────────────────
class User {
  final String id;
  final String name;
  final String email;
  final UserStatus status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  @override
  String toString() => 'User($name, $email, $status)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/errors/auth_errors.dart
// ─────────────────────────────────────────────────────────────
class AuthError implements Exception {
  final String message;
  const AuthError(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError() : super('Invalid email or password');
}

class UserNotVerifiedError extends AuthError {
  const UserNotVerifiedError() : super('User account is not verified');
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/password.dart
// ─────────────────────────────────────────────────────────────
class RawPassword {
  final String value;
  const RawPassword(this.value);

  @override
  String toString() => 'RawPassword(***)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/otp_code.dart
// ─────────────────────────────────────────────────────────────
class OtpCode {
  final String value;
  const OtpCode._(this.value);

  /// Used when the user provides a code (validated elsewhere).
  factory OtpCode.fromRaw(String raw) {
    if (raw.length != 6 || int.tryParse(raw) == null) {
      throw ArgumentError('OTP must be 6 digits');
    }
    return OtpCode._(raw);
  }

  /// Used when the domain generates a fresh code.
  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  String toString() => 'OtpCode($value)';

  @override
  bool operator ==(Object other) =>
      other is OtpCode && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

// ─────────────────────────────────────────────────────────────
// The real thing — your AuthDomainService, unchanged
// ─────────────────────────────────────────────────────────────
class AuthDomainService {
  final Random _random = Random.secure();

  /// Throws [InvalidCredentialsError] if login is not allowed.
  void assertCanLogin(User user, RawPassword password, bool passwordMatches) {
    if (!passwordMatches) throw InvalidCredentialsError();
    if (user.status != UserStatus.active) throw UserNotVerifiedError();
  }

  /// Generates a 6-digit OTP.
  OtpCode generateOtp() {
    final code = List.generate(6, (_) => _random.nextInt(10)).join();
    return OtpCode.generated(code);
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise every branch
// ─────────────────────────────────────────────────────────────
void main() {
  final service = AuthDomainService();

  final activeUser = User(
    id: '1',
    name: 'Ali',
    email: 'ali@test.com',
    status: UserStatus.active,
  );
  final unverifiedUser = User(
    id: '2',
    name: 'Sara',
    email: 'sara@test.com',
    status: UserStatus.unverified,
  );
  const password = RawPassword('123456');

  // Test 1: password mismatch → InvalidCredentialsError
  _try('mismatch password', () {
    service.assertCanLogin(activeUser, password, false);
    print('  ✅ login allowed (unexpected)');
  });

  // Test 2: correct password + unverified → UserNotVerifiedError
  _try('unverified user', () {
    service.assertCanLogin(unverifiedUser, password, true);
    print('  ✅ login allowed (unexpected)');
  });

  // Test 3: correct password + active → no throw
  _try('valid login', () {
    service.assertCanLogin(activeUser, password, true);
    print('  ✅ login allowed');
  });

  // Test 4: OTP generation
  final otp = service.generateOtp();
  print('generateOtp        → $otp   (length=${otp.value.length})');

  // Test 5: OTP uniqueness / randomness sanity check
  final codes = <String>{};
  for (var i = 0; i < 1000; i++) {
    codes.add(service.generateOtp().value);
  }
  print('1000 OTPs unique   → ${codes.length} distinct');
}

void _try(String label, void Function() fn) {
  try {
    fn();
  } on AuthError catch (e) {
    print('$label → ${e.runtimeType}: ${e.message}');
  } catch (e) {
    print('$label → unexpected: $e');
  }
}