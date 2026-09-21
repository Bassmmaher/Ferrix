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
// Stub: lib/domain/value_objects/user_id.dart
// ─────────────────────────────────────────────────────────────
class UserId {
  final String value;
  UserId(this.value) {
    if (value.trim().isEmpty) {
      throw const ValidationError('UserId cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => value;
}

// ─────────────────────────────────────────────────────────────
// The real thing — your TokenPair + TokenService port, unchanged
// ─────────────────────────────────────────────────────────────
class TokenPair {
  final String accessToken;
  final String refreshToken;
  TokenPair({required this.accessToken, required this.refreshToken});
}

abstract class TokenService {
  TokenPair issue(UserId userId);
  UserId? verifyAccess(String token);
}

// ─────────────────────────────────────────────────────────────
// Fake implementation for the demo
// ─────────────────────────────────────────────────────────────
class FakeTokenService implements TokenService {
  @override
  TokenPair issue(UserId userId) => TokenPair(
        accessToken: 'access:${userId.value}',
        refreshToken: 'refresh:${userId.value}',
      );

  @override
  UserId? verifyAccess(String token) {
    if (!token.startsWith('access:')) return null;
    final id = token.substring(7);
    if (id.isEmpty) return null;
    return UserId(id);
  }
}

/// A failing implementation — for testing error propagation.
class FailingTokenService implements TokenService {
  @override
  TokenPair issue(UserId userId) => throw StateError('token service down');

  @override
  UserId? verifyAccess(String token) =>
      throw StateError('token service down');
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the port contract
// ─────────────────────────────────────────────────────────────
void main() {
  final svc = FakeTokenService();
  final userId = UserId('u-42');

  // Test 1: issue tokens
  final pair = svc.issue(userId);
  print('accessToken   → ${pair.accessToken}');
  print('refreshToken  → ${pair.refreshToken}');

  // Test 2: verify valid access token
  final verified = svc.verifyAccess(pair.accessToken);
  print('verify valid  → $verified');
  print('  equals original? ${verified == userId}');

  // Test 3: verify refresh token (should fail — wrong prefix)
  print('verify refresh→ ${svc.verifyAccess(pair.refreshToken)}');

  // Test 4: verify garbage
  print('verify garbage→ ${svc.verifyAccess('not-a-token')}');

  // Test 5: verify empty
  print('verify empty  → ${svc.verifyAccess('')}');

  // Test 6: failing impl propagates
  final TokenService failing = FailingTokenService();
  try {
    failing.issue(userId);
  } catch (e) {
    print('failing impl  → $e');
  }

  // Test 7: TokenPair is immutable (fields are final)
  // pair.accessToken = 'x';   // ← would not compile
  print('TokenPair     → immutable ✅');
}