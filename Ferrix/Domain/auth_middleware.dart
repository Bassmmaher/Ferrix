// ─────────────────────────────────────────────────────────────
// Stub: package:shelf
// ─────────────────────────────────────────────────────────────
typedef Handler = Future<Response> Function(Request req);

class Request {
  final Map<String, String> headers;
  final Map<String, Object> context;
  final String body;

  Request({
    this.headers = const {},
    this.context = const {},
    this.body = '',
  });

  Request change({Map<String, Object>? context, Map<String, String>? headers}) =>
      Request(
        headers: headers ?? this.headers,
        context: context ?? this.context,
        body: body,
      );

  @override
  String toString() => 'Request(headers: $headers, context: $context)';
}

class Response {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  Response(this.statusCode, {this.body = '', this.headers = const {}});

  @override
  String toString() => 'Response($statusCode) $body';
}

typedef Middleware = Handler Function(Handler inner);

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/token_service.dart
// ─────────────────────────────────────────────────────────────
class UserId {
  final String value;
  const UserId(this.value);
  @override
  String toString() => value;
}

abstract class TokenService {
  /// Returns the [UserId] if the access token is valid, else `null`.
  UserId? verifyAccess(String token);
}

/// A trivial in-memory implementation for the demo.
class FakeTokenService implements TokenService {
  static const _valid = 'good-token';
  @override
  UserId? verifyAccess(String token) =>
      token == _valid ? const UserId('user-42') : null;
}

// ─────────────────────────────────────────────────────────────
// The real thing — your authMiddleware, unchanged
// ─────────────────────────────────────────────────────────────
Middleware authMiddleware(TokenService tokens) {
  return (Handler inner) => (Request req) async {
        final header = req.headers['authorization'];
        if (header == null || !header.startsWith('Bearer ')) {
          return Response(401,
              body: '{"error":"Missing token"}',
              headers: {'content-type': 'application/json'});
        }
        final userId = tokens.verifyAccess(header.substring(7));
        if (userId == null) {
          return Response(401,
              body: '{"error":"Invalid token"}',
              headers: {'content-type': 'application/json'});
        }
        return inner(req.change(context: {'userId': userId.value}));
      };
}

// ─────────────────────────────────────────────────────────────
// Entry point — test every branch
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final tokens = FakeTokenService();
  final mw = authMiddleware(tokens);

  // A protected handler that echoes the userId from context.
  final Handler protected = (Request req) async {
    final uid = req.context['userId'];
    return Response(200, body: '{"userId":"$uid"}');
  };

  final guarded = mw(protected);

  // Test 1: no Authorization header
  final r1 = await guarded(Request());
  print('no header        → ${r1.statusCode} ${r1.body}');

  // Test 2: wrong scheme
  final r2 = await guarded(Request(headers: {'authorization': 'Basic abc'}));
  print('wrong scheme     → ${r2.statusCode} ${r2.body}');

  // Test 3: Bearer but invalid token
  final r3 = await guarded(Request(headers: {'authorization': 'Bearer bad'}));
  print('invalid token    → ${r3.statusCode} ${r3.body}');

  // Test 4: valid token → passes through to inner handler
  final r4 = await guarded(
    Request(headers: {'authorization': 'Bearer good-token'}),
  );
  print('valid token      → ${r4.statusCode} ${r4.body}');
}