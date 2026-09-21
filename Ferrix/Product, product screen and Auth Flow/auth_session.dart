// ─────────────────────────────────────────────────────────────
// Stub: lib/auth/models/user.dart
// ─────────────────────────────────────────────────────────────
class User {
  final String id;
  final String name;
  final String email;
  final String status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  @override
  String toString() => 'User(id: $id, email: $email, status: $status)';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your AuthSession, unchanged
// ─────────────────────────────────────────────────────────────
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final User user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the model
// ─────────────────────────────────────────────────────────────
void main() {
  const user = User(
    id: 'u-1',
    name: 'Ali Hassan',
    email: 'ali@test.com',
    status: 'active',
  );

  // Test 1: valid session
  final live = AuthSession(
    accessToken: 'eyJhbGciOiJIUzI1NiIs...',
    refreshToken: 'eyJhbGciOiJIUzI1NiIs...',
    expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    user: user,
  );
  print('live       → isExpired=${live.isExpired}, user=${live.user.name}');

  // Test 2: expired session
  final dead = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
    user: user,
  );
  print('expired    → isExpired=${dead.isExpired}');

  // Test 3: boundary — expires exactly at "now"
  final boundary = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime.now(),
    user: user,
  );
  print('boundary   → isExpired=${boundary.isExpired} '
      '(should be true since now > expiresAt)');

  // Test 4: ⚠️ two sessions with identical data compare unequal
  final a = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime.utc(2030, 1, 1),
    user: user,
  );
  final b = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime.utc(2030, 1, 1),
    user: user,
  );
  print('a == b     → ${a == b}   (should be true)');

  // Test 5: ⚠️ toString leaks tokens
  print('toString   → $a');

  // Test 6: time zone — local vs UTC
  final utcSession = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime.utc(2030, 1, 1),
    user: user,
  );
  final localSession = AuthSession(
    accessToken: 'x',
    refreshToken: 'y',
    expiresAt: DateTime(2030, 1, 1),
    user: user,
  );
  print('utc vs local  → both isExpired=${utcSession.isExpired} / '
      '${localSession.isExpired} (same)');
  print('utc vs local DateTime equal? → '
      '${utcSession.expiresAt == localSession.expiresAt}  ← differ by TZ');
}