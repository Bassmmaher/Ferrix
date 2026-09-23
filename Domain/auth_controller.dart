import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// Stub for package:shelf (DartPad doesn't support it)
// ─────────────────────────────────────────────────────────────
class Request {
  final String _body;
  Request(this._body);
  Future<String> readAsString() async => _body;
}

class Response {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  Response(this.statusCode, {required this.body, this.headers = const {}});

  @override
  String toString() => 'Response($statusCode) $body';
}

// ─────────────────────────────────────────────────────────────
// Error hierarchy
// ─────────────────────────────────────────────────────────────
class AuthError implements Exception {
  final String message;
  const AuthError(this.message);
}

class ValidationError extends AuthError {
  const ValidationError(super.message);
}
class EmailAlreadyExistsError extends AuthError {
  const EmailAlreadyExistsError(super.message);
}
class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError(super.message);
}
class UserNotVerifiedError extends AuthError {
  const UserNotVerifiedError(super.message);
}
class OtpExpiredError extends AuthError {
  const OtpExpiredError(super.message);
}
class OtpInvalidError extends AuthError {
  const OtpInvalidError(super.message);
}
class OtpTooManyAttemptsError extends AuthError {
  const OtpTooManyAttemptsError(super.message);
}
class OtpNotFoundError extends AuthError {
  const OtpNotFoundError(super.message);
}
class UserNotFoundError extends AuthError {
  const UserNotFoundError(super.message);
}

// ─────────────────────────────────────────────────────────────
// Stub use cases (replace with your real ones in your project)
// ─────────────────────────────────────────────────────────────
class SignUpUseCase {
  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) async {}
}

class VerifyEmailUseCase {
  Future<void> call({required String email, required String otp}) async {}
}

class ResendOtpUseCase {
  Future<void> call({required String email}) async {}
}

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;
  LoginResult(this.accessToken, this.refreshToken, this.user);
}

class AppUser {
  final String id, name, email, status;
  AppUser(this.id, this.name, this.email, this.status);
}

class LoginUseCase {
  Future<LoginResult> call({
    required String email,
    required String password,
  }) async {
    return LoginResult(
      'access-token-demo',
      'refresh-token-demo',
      AppUser('1', 'Demo', email, 'active'),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// The controller — your original logic, corrected
// ─────────────────────────────────────────────────────────────
class AuthController {
  final SignUpUseCase _signUp;
  final VerifyEmailUseCase _verify;
  final ResendOtpUseCase _resend;
  final LoginUseCase _login;

  AuthController({
    required SignUpUseCase signUp,
    required VerifyEmailUseCase verify,
    required ResendOtpUseCase resend,
    required LoginUseCase login,
  })  : _signUp = signUp,
        _verify = verify,
        _resend = resend,
        _login = login;

  Future<Response> signup(Request req) => _handle(() async {
        final b = await _body(req);
        final name = _requireString(b, 'name');
        final email = _requireString(b, 'email');
        final password = _requireString(b, 'password');

        await _signUp(name: name, email: email, password: password);
        return _json(200, {'message': 'Signup successful. Check your email.'});
      });

  Future<Response> verify(Request req) => _handle(() async {
        final b = await _body(req);
        final email = _requireString(b, 'email');
        final otp = _requireString(b, 'otp');

        await _verify(email: email, otp: otp);
        return _json(200, {'message': 'Email verified. You can log in now.'});
      });

  Future<Response> resend(Request req) => _handle(() async {
        final b = await _body(req);
        final email = _requireString(b, 'email');

        await _resend(email: email);
        return _json(200, {'message': 'New OTP sent.'});
      });

  Future<Response> login(Request req) => _handle(() async {
        final b = await _body(req);
        final email = _requireString(b, 'email');
        final password = _requireString(b, 'password');

        final result = await _login(email: email, password: password);
        return _json(200, {
          'message': 'Login successful',
          'accessToken': result.accessToken,
          'refreshToken': result.refreshToken,
          'user': {
            'id': result.user.id,
            'name': result.user.name,
            'email': result.user.email,
            'status': result.user.status,
          },
        });
      });

  // ─────────── Helpers ───────────

  Future<Map<String, dynamic>> _body(Request req) async {
    final raw = await req.readAsString();

    if (raw.trim().isEmpty) {
      throw ValidationError('Empty request body');
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationError('Request body must be a JSON object');
      }
      return decoded;
    } on FormatException {
      throw ValidationError('Invalid JSON body');
    }
  }

  String _requireString(Map<String, dynamic> body, String field) {
    final value = body[field];
    if (value is! String || value.trim().isEmpty) {
      throw ValidationError('$field is required');
    }
    return value;
  }

  Future<Response> _handle(Future<Response> Function() fn) async {
    try {
      return await fn();
    } on ValidationError catch (e) {
      return _json(400, {'error': e.message});
    } on EmailAlreadyExistsError catch (e) {
      return _json(409, {'error': e.message});
    } on InvalidCredentialsError catch (e) {
      return _json(401, {'error': e.message});
    } on UserNotVerifiedError catch (e) {
      return _json(403, {'error': e.message, 'needsVerification': true});
    } on OtpExpiredError catch (e) {
      return _json(400, {'error': e.message});
    } on OtpInvalidError catch (e) {
      return _json(400, {'error': e.message});
    } on OtpTooManyAttemptsError catch (e) {
      return _json(429, {'error': e.message});
    } on OtpNotFoundError catch (e) {
      return _json(400, {'error': e.message});
    } on UserNotFoundError catch (e) {
      return _json(404, {'error': e.message});
    } on AuthError catch (e) {
      return _json(400, {'error': e.message});
    } catch (e, st) {
      // ignore: avoid_print
      print('❌ Unhandled: $e\n$st');
      return _json(500, {'error': 'Internal server error'});
    }
  }

  Response _json(int status, Map<String, dynamic> body) => Response(
        status,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'},
      );
}

// ─────────────────────────────────────────────────────────────
// Entry point (fixes "Method not found: 'main'")
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  final controller = AuthController(
    signUp: SignUpUseCase(),
    verify: VerifyEmailUseCase(),
    resend: ResendOtpUseCase(),
    login: LoginUseCase(),
  );

  // Test 1: valid signup
  final r1 = await controller.signup(
    Request('{"name":"Ali","email":"ali@test.com","password":"123456"}'),
  );
  print('signup  → ${r1.statusCode} ${r1.body}');

  // Test 2: missing field
  final r2 = await controller.signup(Request('{"email":"x@test.com"}'));
  print('signup  → ${r2.statusCode} ${r2.body}');

  // Test 3: invalid JSON
  final r3 = await controller.signup(Request('{not-json'));
  print('signup  → ${r3.statusCode} ${r3.body}');

  // Test 4: login
  final r4 = await controller.login(
    Request('{"email":"ali@test.com","password":"123456"}'),
  );
  print('login   → ${r4.statusCode} ${r4.body}');

  // Test 5: empty body
  final r5 = await controller.login(Request(''));
  print('login   → ${r5.statusCode} ${r5.body}');
}