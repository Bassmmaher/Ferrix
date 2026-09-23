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
// The real thing — your UserId value object, unchanged
// ─────────────────────────────────────────────────────────────
class UserId {
  final String value;
  UserId._(this.value);

  factory UserId(String raw) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (!regex.hasMatch(raw)) {
      throw ValidationError('Invalid user id');
    }
    return UserId._(raw);
  }

  @override
  bool operator ==(Object other) =>
      other is UserId && other.value == value;

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
    '00000000-0000-0000-0000-000000000000',
    '12345678-1234-1234-1234-123456789abc',
    'ABCDEF01-2345-6789-ABCD-EF0123456789',   // uppercase hex
    'aBcDeF01-2345-6789-abcd-ef0123456789',   // mixed case
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
  ];

  final invalid = [
    '',
    '   ',
    'not-a-uuid',
    '12345678123412341234123456789abc',        // no hyphens
    '12345678-1234-1234-1234-123456789ab',     // too short
    '12345678-1234-1234-1234-123456789abcd',   // too long
    '12345678-1234-1234-1234-123456789xyz',    // non-hex char
    'gggggggg-gggg-gggg-gggg-gggggggggggg',    // non-hex letters
    '12345678_1234_1234_1234_123456789abc',    // wrong separator
    '12345678-1234-1234-1234-123456789abc ',   // trailing space
    ' 12345678-1234-1234-1234-123456789abc',   // leading space
  ];

  print('─── VALID (expected to pass) ───');
  for (final raw in valid) {
    try {
      final id = UserId(raw);
      print('  ✅ ${_disp(raw).padRight(40)} → $id');
    } on ValidationError catch (e) {
      print('  ❌ ${_disp(raw).padRight(40)} → ${e.message}');
    }
  }

  print('\n─── INVALID (expected to fail) ───');
  for (final raw in invalid) {
    try {
      final id = UserId(raw);
      print('  ⚠️  ${_disp(raw).padRight(40)} → $id (UNEXPECTED PASS)');
    } on ValidationError catch (e) {
      print('  ✅ ${_disp(raw).padRight(40)} → ${e.message}');
    }
  }

  print('\n─── Equality ───');
  final a = UserId('12345678-1234-1234-1234-123456789abc');
  final b = UserId('12345678-1234-1234-1234-123456789abc');
  final c = UserId('ABCDEF01-2345-6789-ABCD-EF0123456789');
  print('  a == b            → ${a == b}');
  print('  a == c            → ${a == c}');
  print('  a.hashCode == b.hc→ ${a.hashCode == b.hashCode}');

  print('\n─── Case sensitivity ───');
  final lower = UserId('12345678-1234-1234-1234-123456789abc');
  final upper = UserId('12345678-1234-1234-1234-123456789ABC');
  print('  lower == upper    → ${lower == upper}  ← different!');
  print('  ⚠️  UUIDs are case-insensitive but this class treats them as case-sensitive');

  print('\n─── Set / Map behavior ───');
  final set = {
    UserId('12345678-1234-1234-1234-123456789abc'),
    UserId('12345678-1234-1234-1234-123456789abc'),
  };
  print('  set size after duplicate → ${set.length}');
}

String _disp(String s) => s.length > 38 ? '${s.substring(0, 35)}...' : s;