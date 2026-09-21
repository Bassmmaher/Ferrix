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
// The real thing — your Email value object, unchanged
// ─────────────────────────────────────────────────────────────
class Email {
  final String value;

  Email._(this.value);

  factory Email(String raw) {
    final trimmed = raw.trim().toLowerCase();
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (trimmed.isEmpty || trimmed.length > 254 || !regex.hasMatch(trimmed)) {
      throw ValidationError('Invalid email address');
    }
    return Email._(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Entry point — stress-test the factory
// ─────────────────────────────────────────────────────────────
void main() {
  final valid = [
    'ali@test.com',
    'ALI@TEST.COM',
    '  ali@test.com  ',
    'a.b-c_d@sub.example.co',
    'user@my-domain.com',
    'x@y.co',
    'ali+tag@test.com',      // ← will FAIL with this regex
    "o'brien@test.com",      // ← will FAIL with this regex
  ];

  final invalid = [
    '',
    '   ',
    'not-an-email',
    'missing@tld',
    '@example.com',
    'a@b',
    'a@b.c',
    'a b@c.com',
    'a@b@c.com',
    '${'a' * 250}@x.com',
  ];

  print('─── VALID (expected to pass) ───');
  for (final raw in valid) {
    try {
      final e = Email(raw);
      print('  ✅ ${_disp(raw).padRight(28)} → $e');
    } on ValidationError catch (e) {
      print('  ❌ ${_disp(raw).padRight(28)} → ${e.message}');
    }
  }

  print('\n─── INVALID (expected to fail) ───');
  for (final raw in invalid) {
    try {
      final e = Email(raw);
      print('  ⚠️  ${_disp(raw).padRight(28)} → $e (UNEXPECTED PASS)');
    } on ValidationError catch (e) {
      print('  ✅ ${_disp(raw).padRight(28)} → ${e.message}');
    }
  }

  print('\n─── Equality ───');
  final a = Email('Ali@Test.com');
  final b = Email('ali@test.com');
  print('  ${a} == ${b}  → ${a == b}');
  print('  hashCode equal → ${a.hashCode == b.hashCode}');

  print('\n─── toString ───');
  print('  "$a"');
}

String _disp(String s) => s.length > 26 ? '${s.substring(0, 23)}...' : s;