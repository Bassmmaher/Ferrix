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
// The real thing — your FullName value object, unchanged
// ─────────────────────────────────────────────────────────────
class FullName {
  final String value;
  FullName._(this.value);

  factory FullName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw ValidationError('Name must be 1–100 characters');
    }
    return FullName._(trimmed);
  }

  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// Entry point — stress-test the factory
// ─────────────────────────────────────────────────────────────
void main() {
  final valid = [
    'Ali',
    'Ali Hassan',
    '  Ali Hassan  ',
    'علي حسن',
    'Ægir Þórsson',
    'Mary-Jane O\'Connor',
    '李雷',
    'A' * 100,                       // exactly 100 chars
  ];

  final invalid = [
    '',
    '   ',
    'A' * 101,                       // 101 chars
  ];

  print('─── VALID (expected to pass) ───');
  for (final raw in valid) {
    try {
      final n = FullName(raw);
      print('  ✅ ${_disp(raw).padRight(30)} → "$n" (len=${n.value.length})');
    } on ValidationError catch (e) {
      print('  ❌ ${_disp(raw).padRight(30)} → ${e.message}');
    }
  }

  print('\n─── INVALID (expected to fail) ───');
  for (final raw in invalid) {
    try {
      final n = FullName(raw);
      print('  ⚠️  ${_disp(raw).padRight(30)} → "$n" (UNEXPECTED PASS)');
    } on ValidationError catch (e) {
      print('  ✅ ${_disp(raw).padRight(30)} → ${e.message}');
    }
  }

  print('\n─── Equality ───');
  final a = FullName('  Ali Hassan ');
  final b = FullName('Ali Hassan');
  print('  "$a" == "$b" → ${a == b}');           // ← will be false!
  print('  identical?  → ${identical(a, b)}');    // ← false
}

String _disp(String s) => s.length > 26 ? '${s.substring(0, 23)}...' : s;