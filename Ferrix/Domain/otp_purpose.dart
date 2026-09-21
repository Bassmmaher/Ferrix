// ─────────────────────────────────────────────────────────────
// The real thing — your OtpPurpose enum, unchanged
// ─────────────────────────────────────────────────────────────
enum OtpPurpose { emailVerification, passwordReset }

// ─────────────────────────────────────────────────────────────
// Entry point — demonstrate usage
// ─────────────────────────────────────────────────────────────
void main() {
  // ─── Values ───
  print('─── Values ───');
  for (final p in OtpPurpose.values) {
    print('  $p  (name="${p.name}", index=${p.index})');
  }

  // ─── Lookup by name (for persistence / API boundaries) ───
  print('\n─── Lookup by name ───');
  final fromDb = OtpPurpose.values.byName('passwordReset');
  print('  byName("passwordReset") → $fromDb');

  // ─── Safe lookup (returns null if not found) ───
  print('\n─── Safe lookup ───');
  final maybe = OtpPurpose.values.asNameMap()['emailVerification'];
  print('  asNameMap()["emailVerification"] → $maybe');
  final missing = OtpPurpose.values.asNameMap()['signup'];
  print('  asNameMap()["signup"]            → $missing');

  // ─── exhaustive switch (Dart 3) ───
  print('\n─── Exhaustive switch ───');
  for (final p in OtpPurpose.values) {
    final description = switch (p) {
      OtpPurpose.emailVerification => 'Sent when a new user signs up',
      OtpPurpose.passwordReset => 'Sent when a user forgets their password',
    };
    print('  $p → $description');
  }

  // ─── Grouping in maps (e.g., OTP repository keys) ───
  print('\n─── Map keys ───');
  final otpsByPurpose = <OtpPurpose, String>{
    OtpPurpose.emailVerification: '483920',
    OtpPurpose.passwordReset: '112233',
  };
  print('  emailVerification: ${otpsByPurpose[OtpPurpose.emailVerification]}');
  print('  passwordReset:     ${otpsByPurpose[OtpPurpose.passwordReset]}');

  // ─── Records as composite keys ───
  print('\n─── Record keys (email + purpose) ───');
  final store = <(String, OtpPurpose), String>{
    ('ali@test.com', OtpPurpose.emailVerification): '111111',
    ('ali@test.com', OtpPurpose.passwordReset): '222222',
  };
  print('  ali signup: ${store[('ali@test.com', OtpPurpose.emailVerification)]}');
  print('  ali reset:  ${store[('ali@test.com', OtpPurpose.passwordReset)]}');
}

// ─── A tiny extension to show how to store an explicit code ───
// Useful when persisting to a DB where you want a stable string
// that won't change if the Dart identifier is ever renamed.
extension OtpPurposeCode on OtpPurpose {
  String get code => switch (this) {
        OtpPurpose.emailVerification => 'email_verification',
        OtpPurpose.passwordReset => 'password_reset',
      };
}