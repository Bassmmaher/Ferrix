// ─────────────────────────────────────────────────────────────
// Stub: package:shelf
// ─────────────────────────────────────────────────────────────
typedef Handler = Future<Response> Function(Request req);
typedef Middleware = Handler Function(Handler inner);

class Request {
  final String method;
  final String path;
  Request({this.method = 'GET', this.path = '/'});

  @override
  String toString() => '$method $path';
}

class Response {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  Response(this.statusCode, {this.body = '', this.headers = const {}});

  /// Mirrors shelf.Response.ok
  static Response ok(String body, {Map<String, String> headers = const {}}) =>
      Response(200, body: body, headers: headers);

  /// shelf.Response.change() → replaces status/body/headers as supplied.
  Response change({
    int? statusCode,
    String? body,
    Map<String, String>? headers,
  }) =>
      Response(
        statusCode ?? this.statusCode,
        body: body ?? this.body,
        headers: headers ?? this.headers,
      );

  @override
  String toString() =>
      'Response($statusCode, headers: $headers, body: "$body")';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your corsMiddleware, unchanged
// ─────────────────────────────────────────────────────────────
Middleware corsMiddleware() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
  return (Handler inner) => (Request req) async {
        if (req.method == 'OPTIONS') return Response.ok('', headers: headers);
        final res = await inner(req);
        return res.change(headers: headers);
      };
}

// ─────────────────────────────────────────────────────────────
// Entry point — test both branches
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final cors = corsMiddleware();

  final Handler inner = (Request req) async => Response(
        200,
        body: '{"ok":true}',
        headers: {'content-type': 'application/json'},
      );

  final guarded = cors(inner);

  // Test 1: OPTIONS preflight → short-circuits with CORS headers
  final r1 = await guarded(Request(method: 'OPTIONS', path: '/login'));
  print('OPTIONS → ${r1.statusCode}');
  print('          headers: ${r1.headers}');

  // Test 2: GET → goes through inner, then CORS headers applied
  final r2 = await guarded(Request(method: 'GET', path: '/login'));
  print('GET     → ${r2.statusCode}');
  print('          headers: ${r2.headers}');
  print('          body:    ${r2.body}');

  // Test 3: POST
  final r3 = await guarded(Request(method: 'POST', path: '/login'));
  print('POST    → ${r3.statusCode}');
  print('          headers: ${r3.headers}');
}