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
// The real thing — your OtpCode value object, unchanged
// ─────────────────────────────────────────────────────────────
class OtpCode {
  final String value;
  OtpCode._(this.value);

  factory OtpCode(String raw) {
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
      throw ValidationError('OTP must be exactly 6 digits');
    }
    return OtpCode._(raw);
  }

  /// Used by the OTP generator — does not validate input format.
  factory OtpCode.generated(String raw) => OtpCode._(raw);

  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Entry point — stress-test the factory
// ─────────────────────────────────────────────────────────────
void main() {
  final valid = [
    '000000',
    '123456',
    '999999',
  ];

  final invalid = [
    '',
    '1',
    '12345',        // 5 digits
    '1234567',      // 7 digits
    'abcdef',       // letters
    '12345a',       // letter mixed in
    ' 123456',      // leading space
    '123456 ',      // trailing space
    '12 456',       // internal space
    '-12345',       // sign
    '１２３４５６',   // full-width digits (Unicode)
  ];

  print('─── VALID (expected to pass) ───');
  for (final raw in valid) {
    try {
      final c = OtpCode(raw);
      print('  ✅ "${raw}" → $c');
    } on ValidationError catch (e) {
      print('  ❌ "${raw}" → ${e.message}');
    }
  }

  print('\n─── INVALID (expected to fail) ───');
  for (final raw in invalid) {
    try {
      final c = OtpCode(raw);
      print('  ⚠️  "${raw}" → $c (UNEXPECTED PASS)');
    } on ValidationError catch (e) {
      print('  ✅ ${_disp(raw).padRight(16)} → ${e.message}');
    }
  }

  // ─── generated() trusts caller ───
  print('\n─── OtpCode.generated (bypasses validation) ───');
  final genValid = OtpCode.generated('483920');
  print('  generated("483920")    → $genValid');
  final genBad = OtpCode.generated('abc');
  print('  generated("abc")       → $genBad  ← unvalidated!');

  // ─── Equality — will this work? ───
  print('\n─── Equality ───');
  final a = OtpCode('123456');
  final b = OtpCode('123456');
  print('  a == b      → ${a == b}');            // ← false (BUG)
  print('  a.hashCode == b.hashCode → ${a.hashCode == b.hashCode}');
  print('  identical(a, b)          → ${identical(a, b)}');

  // ─── OTP as a hash-set key ───
  final set = {OtpCode('111111'), OtpCode('111111')};
  print('  set size after adding duplicate → ${set.length}  ← should be 1');
}

String _disp(String s) => s.length > 14 ? '${s.substring(0, 11)}...' : s;