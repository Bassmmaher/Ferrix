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
// The real thing — your password value objects, unchanged
// ─────────────────────────────────────────────────────────────
class RawPassword {
  final String value;
  RawPassword._(this.value);

  factory RawPassword(String raw) {
    if (raw.length < 8) {
      throw ValidationError('Password must be at least 8 characters');
    }
    if (!raw.contains(RegExp(r'[A-Z]'))) {
      throw ValidationError('Password must contain an uppercase letter');
    }
    if (!raw.contains(RegExp(r'[a-z]'))) {
      throw ValidationError('Password must contain a lowercase letter');
    }
    if (!raw.contains(RegExp(r'[0-9]'))) {
      throw ValidationError('Password must contain a digit');
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
  bool operator ==(Object other) =>
      other is HashedPassword && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

// ─────────────────────────────────────────────────────────────
// Entry point — stress-test the rules
// ─────────────────────────────────────────────────────────────
void main() {
  final valid = [
    'Password1',
    'Abcd1234',
    'MyP@ssw0rd',
    'aB3aaaaa',
    'Zz0zzzzzzz',
  ];

  final invalid = [
    '',                    // empty
    'Short1',              // too short (6)
    'Short1!',             // still too short (7)
    'password1',           // no uppercase
    'PASSWORD1',           // no lowercase
    'Password',            // no digit
    'PASSWORD',            // no lowercase, no digit
    'password',            // no uppercase, no digit
    '12345678',            // no letters
    '       1A',           // space + digits, no lowercase letter... actually has 'A' uppercase and 1 digit; missing lowercase
    'Passw0rd ',           // has trailing space — allowed (only checks needed classes)
  ];

  print('─── VALID (expected to pass) ───');
  for (final raw in valid) {
    try {
      final p = RawPassword(raw);
      print('  ✅ "${raw}" → ${p.toString()}');
    } on ValidationError catch (e) {
      print('  ❌ "${raw}" → ${e.message}');
    }
  }

  print('\n─── INVALID (expected to fail) ───');
  for (final raw in invalid) {
    try {
      RawPassword(raw);
      print('  ⚠️  "${raw}" → ACCEPTED (unexpected!)');
    } on ValidationError catch (e) {
      print('  ✅ "${raw.padRight(12)}" → ${e.message}');
    }
  }

  // ─── RawPassword.toString() must not leak the value ───
  print('\n─── RawPassword.toString() ───');
  final secret = RawPassword('MySecret123');
  print('  toString()           → $secret');
  print('  contains original?   → ${secret.toString().contains('MySecret')}');
  print('  JSON-encodable?      → (no toJson — will need explicit mapping)');

  // ─── HashedPassword equality ───
  print('\n─── HashedPassword equality ───');
  final h1 = HashedPassword(r'$2a$12$abc');
  final h2 = HashedPassword(r'$2a$12$abc');
  final h3 = HashedPassword(r'$2a$12$xyz');
  print('  h1 == h2 → ${h1 == h2}');
  print('  h1 == h3 → ${h1 == h3}');
  print('  h1.hashCode == h2.hashCode → ${h1.hashCode == h2.hashCode}');

  // ─── HashedPassword.toString() — DEFAULT is unsafe! ───
  print('\n─── HashedPassword.toString() (default) ───');
  print('  $h1');
  print('  ⚠️  Leaks the hash to logs by default — see review below');
}