import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// Stub: package:dart_jsonwebtoken (mimics its API for DartPad)
// ─────────────────────────────────────────────────────────────
class SecretKey {
  final String secret;
  const SecretKey(this.secret);
}

class JWTException implements Exception {
  final String message;
  const JWTException(this.message);
  @override
  String toString() => 'JWTException: $message';
}

class JWT {
  final Map<String, dynamic> payload;
  JWT(this.payload);

  /// Signs and produces a fake "JWT"-shaped string.
  /// Real JWT is header.payload.signature — this mimics the shape.
  String sign(SecretKey key, {Duration? expiresIn}) {
    final header = {'alg': 'FAKEHS256', 'typ': 'JWT'};
    final claims = <String, dynamic>{...payload};
    if (expiresIn != null) {
      final exp = DateTime.now()
          .add(expiresIn)
          .millisecondsSinceEpoch ~/ 1000;
      claims['exp'] = exp;
    }
    final h = _b64(jsonEncode(header));
    final p = _b64(jsonEncode(claims));
    final sig = _sign('$h.$p', key.secret);
    return '$h.$p.$sig';
  }

  /// Verifies the token and returns a JWT (with decoded payload).
  /// Throws [JWTException] on any failure.
  static JWT verify(String token, SecretKey key) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const JWTException('Malformed token');
    }
    final [h, p, sig] = parts;
    final expected = _sign('$h.$p', key.secret);
    if (expected != sig) {
      throw const JWTException('Invalid signature');
    }
    final claims = jsonDecode(_unb64(p)) as Map<String, dynamic>;
    final exp = claims['exp'];
    if (exp is int) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now > exp) {
        throw const JWTException('Token expired');
      }
    }
    return JWT(claims);
  }

  // ─── internals (toy crypto, NOT secure — for demo only) ───
  static String _sign(String data, String secret) {
    var h = 2166136261; // FNV-1a 32-bit
    final bytes = utf8.encode('$data|$secret');
    for (final b in bytes) {
      h ^= b;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h.toRadixString(16).padLeft(8, '0');
  }

  static String _b64(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');

  static String _unb64(String s) {
    final pad = s.length % 4 == 0 ? '' : '=' * (4 - s.length % 4);
    return utf8.decode(base64Url.decode(s + pad));
  }
}

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
// Stub: lib/domain/repositories/token_service.dart
// ─────────────────────────────────────────────────────────────
class TokenPair {
  final String accessToken;
  final String refreshToken;
  const TokenPair({required this.accessToken, required this.refreshToken});
}

abstract class TokenService {
  TokenPair issue(UserId userId);
  UserId? verifyAccess(String token);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your JwtTokenService, unchanged
// ─────────────────────────────────────────────────────────────
class JwtTokenService implements TokenService {
  final String accessSecret;
  final String refreshSecret;

  JwtTokenService({
    required this.accessSecret,
    required this.refreshSecret,
  });

  @override
  TokenPair issue(UserId userId) {
    final access = JWT({'sub': userId.value, 'type': 'access'}).sign(
      SecretKey(accessSecret),
      expiresIn: const Duration(minutes: 15),
    );
    final refresh = JWT({'sub': userId.value, 'type': 'refresh'}).sign(
      SecretKey(refreshSecret),
      expiresIn: const Duration(days: 7),
    );
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  @override
  UserId? verifyAccess(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(accessSecret));
      final sub = jwt.payload['sub'] as String?;
      if (sub == null) return null;
      return UserId(sub);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
void main() {
  final svc = JwtTokenService(
    accessSecret: 'access-secret-very-secret',
    refreshSecret: 'refresh-secret-also-secret',
  );

  final userId = UserId('u-42');

  // Test 1: issue tokens
  final pair = svc.issue(userId);
  print('access  → ${pair.accessToken.substring(0, 40)}...');
  print('refresh → ${pair.refreshToken.substring(0, 40)}...');

  // Test 2: verify access token → userId
  final verified = svc.verifyAccess(pair.accessToken);
  print('verify valid access → $verified');

  // Test 3: verify with wrong secret → null
  final otherSvc = JwtTokenService(
    accessSecret: 'WRONG',
    refreshSecret: 'WRONG',
  );
  print('verify wrong secret → ${otherSvc.verifyAccess(pair.accessToken)}');

  // Test 4: garbage token → null
  print('verify garbage      → ${svc.verifyAccess('not.a.jwt')}');

  // Test 5: empty token → null
  print('verify empty        → ${svc.verifyAccess('')}');

  // Test 6: ⚠️ refresh token accepted by verifyAccess? Check now.
  print('verify REFRESH tok  → ${svc.verifyAccess(pair.refreshToken)}');

  // Test 7: tampered payload → null
  final parts = pair.accessToken.split('.');
  final tampered = '${parts[0]}.${parts[1]}.deadbeef';
  print('verify tampered sig → ${svc.verifyAccess(tampered)}');
}