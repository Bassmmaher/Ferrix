// ─────────────────────────────────────────────────────────────
// The real thing — your UserStatus enum, unchanged
// ─────────────────────────────────────────────────────────────
enum UserStatus { pending, active, locked }

// ─────────────────────────────────────────────────────────────
// Entry point — demonstrate usage
// ─────────────────────────────────────────────────────────────
void main() {
  // ─── Values ───
  print('─── Values ───');
  for (final s in UserStatus.values) {
    print('  $s  (name="${s.name}", index=${s.index})');
  }

  // ─── Lookup by name (for persistence / API boundaries) ───
  print('\n─── Lookup by name ───');
  print('  byName("active") → ${UserStatus.values.byName('active')}');
  print('  byName("pending") → ${UserStatus.values.byName('pending')}');
  print('  byName("locked") → ${UserStatus.values.byName('locked')}');

  // ─── Safe lookup ───
  print('\n─── Safe lookup ───');
  final map = UserStatus.values.asNameMap();
  print('  map["active"]  → ${map['active']}');
  print('  map["deleted"] → ${map['deleted']}');

  // ─── Exhaustive switch (Dart 3) ───
  print('\n─── Exhaustive switch ───');
  for (final s in UserStatus.values) {
    final description = switch (s) {
      UserStatus.pending => 'Signed up, awaiting email verification',
      UserStatus.active => 'Verified and able to log in',
      UserStatus.locked => 'Administratively locked — cannot log in',
    };
    print('  $s → $description');
  }

  // ─── Can this user log in? (policy helper) ───
  print('\n─── canLogIn helper ───');
  for (final s in UserStatus.values) {
    print('  $s → canLogIn=${s.canLogIn}');
  }

  // ─── Storage round-trip ───
  print('\n─── Storage round-trip ───');
  const stored = 'pending';
  final restored = UserStatus.values.byName(stored);
  print('  "$stored" → $restored (== ${UserStatus.pending}: '
      '${restored == UserStatus.pending})');
}

// ─────────────────────────────────────────────────────────────
// Extension — helper for "can this user log in?"
// ─────────────────────────────────────────────────────────────
extension UserStatusPolicy on UserStatus {
  /// Only active users can complete a login.
  bool get canLogIn => this == UserStatus.active;

  /// Only pending users can complete email verification.
  bool get canVerify => this == UserStatus.pending;

  /// Whether the user needs a fresh OTP to be sent.
  bool get needsVerification => this == UserStatus.pending;
}