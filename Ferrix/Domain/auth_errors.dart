// ─────────────────────────────────────────────────────────────
// The real thing — your AuthError hierarchy, unchanged
// ─────────────────────────────────────────────────────────────
sealed class AuthError implements Exception {
  final String message;
  AuthError(this.message);

  @override
  String toString() => message;
}

class ValidationError extends AuthError {
  ValidationError(super.message);
}

class EmailAlreadyExistsError extends AuthError {
  EmailAlreadyExistsError() : super('Email already registered');
}

class UserNotFoundError extends AuthError {
  UserNotFoundError() : super('User not found');
}

class InvalidCredentialsError extends AuthError {
  InvalidCredentialsError() : super('Invalid email or password');
}

class UserNotVerifiedError extends AuthError {
  UserNotVerifiedError() : super('Email not verified');
}

class OtpExpiredError extends AuthError {
  OtpExpiredError() : super('OTP expired');
}

class OtpInvalidError extends AuthError {
  OtpInvalidError() : super('Invalid OTP');
}

class OtpTooManyAttemptsError extends AuthError {
  OtpTooManyAttemptsError() : super('Too many attempts');
}

class OtpNotFoundError extends AuthError {
  OtpNotFoundError() : super('No OTP found. Request a new one.');
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise every branch + exhaustiveness check
// ─────────────────────────────────────────────────────────────
void main() {
  final errors = <AuthError>[
    ValidationError('email is required'),
    EmailAlreadyExistsError(),
    UserNotFoundError(),
    InvalidCredentialsError(),
    UserNotVerifiedError(),
    OtpExpiredError(),
    OtpInvalidError(),
    OtpTooManyAttemptsError(),
    OtpNotFoundError(),
  ];

  // Test 1: every error prints its message
  for (final e in errors) {
    print('${e.runtimeType.toString().padRight(24)} → $e');
  }

  // Test 2: exhaustive switch (only works because `sealed`)
  for (final e in errors) {
    final httpStatus = switch (e) {
      ValidationError() => 400,
      EmailAlreadyExistsError() => 409,
      InvalidCredentialsError() => 401,
      UserNotVerifiedError() => 403,
      OtpExpiredError() => 400,
      OtpInvalidError() => 400,
      OtpTooManyAttemptsError() => 429,
      OtpNotFoundError() => 400,
      UserNotFoundError() => 404,
    };
    print('${e.runtimeType.toString().padRight(24)} → HTTP $httpStatus');
  }

  // Test 3: catch as base type still works
  try {
    throw OtpInvalidError();
  } on AuthError catch (e) {
    print('caught as AuthError      → $e');
  }
}