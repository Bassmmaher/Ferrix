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
// Entry point — exercise the factory
// ─────────────────────────────────────────────────────────────
void main() {
  final valid = [
    'ali@test.com',
    'ALI@TEST.COM',            // upper → lowercased
    '  ali@test.com  ',        // whitespace trimmed
    'a.b-c_d@sub.example.co',  // dots, hyphen, underscore
    'user+tag@example.org',    // '+' not allowed by this regex — see below
  ];

  final invalid = [
    '',
    '   ',
    'not-an-email',
    'missing@tld',
    '@example.com',
    'a@b',
    'a@b.c',
    'a b@c.com',               // space
    'a@b@c.com',               // double @
    '${'a' * 250}@x.com',      // length > 254
  ];

  print('─── VALID ───');
  for (final raw in valid) {
    try {
      final e = Email(raw);
      print('  ✅ ${raw.padRight(28)} → $e');
    } on ValidationError catch (e) {
      print('  ❌ ${raw.padRight(28)} → ${e.message}');
    }
  }

  print('\n─── INVALID ───');
  for (final raw in invalid) {
    try {
      final e = Email(raw);
      print('  ✅ ${raw.padRight(28)} → $e (unexpected!)');
    } on ValidationError catch (e) {
      print('  ❌ ${_short(raw).padRight(28)} → ${e.message}');
    }
  }

  // Equality
  final a = Email('Ali@Test.com');
  final b = Email('ali@test.com');
  print('\nequality: $a == $b → ${a == b}');
  print('hashCode equal → ${a.hashCode == b.hashCode}');

  // Repr
  print('toString → "$a"');
}

String _short(String s) => s.length > 24 ? '${s.substring(0, 21)}...' : s;