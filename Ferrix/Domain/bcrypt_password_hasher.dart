import 'dart:convert';
import 'dart:math';

// ─────────────────────────────────────────────────────────────
// Stub: package:bcrypt
// Pure-Dart fake that mimics BCrypt.hashpw / gensalt / checkpw.
// NOT suitable for production — real bcrypt uses Blowfish.
// Uses 32-bit arithmetic so it also runs on DartPad (JS).
// ─────────────────────────────────────────────────────────────
class BCrypt {
  static final Random _rng = Random.secure();

  static String gensalt({int rounds = 10}) {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    return 'fake\$2a\$$rounds\$${base64Url.encode(bytes)}';
  }

  static String hashpw(String password, String salt) {
    final combined = '$salt::$password';
    final bytes = utf8.encode(combined);

    // FNV-1a 32-bit — safe on both VM and JS.
    var h = 0x811c9dc5;
    for (final b in bytes) {
      h ^= b;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return '$salt\$${h.toRadixString(16).padLeft(8, '0')}';
  }

  static bool checkpw(String password, String hashed) {
    final idx = hashed.lastIndexOf(r'$');
    if (idx < 0) return false;
    final salt = hashed.substring(0, idx);
    return hashpw(password, salt) == hashed;
  }
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/value_objects/password.dart
// ─────────────────────────────────────────────────────────────
class RawPassword {
  final String value;
  RawPassword(this.value);

  @override
  String toString() => 'RawPassword(***)';
}

class HashedPassword {
  final String value;
  HashedPassword(this.value);

  @override
  String toString() => 'HashedPassword(${value.substring(0, 20)}...)';
}

// ─────────────────────────────────────────────────────────────
// Stub: lib/domain/repositories/password_hasher.dart
// ─────────────────────────────────────────────────────────────
abstract class PasswordHasher {
  HashedPassword hash(RawPassword password);
  bool verify(RawPassword password, HashedPassword hash);
}

// ─────────────────────────────────────────────────────────────
// The real thing — your BcryptPasswordHasher, unchanged
// ─────────────────────────────────────────────────────────────
class BcryptPasswordHasher implements PasswordHasher {
  @override
  HashedPassword hash(RawPassword password) {
    final hashed = BCrypt.hashpw(password.value, BCrypt.gensalt());
    return HashedPassword(hashed);
  }

  @override
  bool verify(RawPassword password, HashedPassword hash) {
    return BCrypt.checkpw(password.value, hash.value);
  }
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise hash & verify
// ─────────────────────────────────────────────────────────────
void main() {
  final hasher = BcryptPasswordHasher();
  final raw = RawPassword('hunter2');

  // Test 1: hash produces a non-plaintext string
  final hashed = hasher.hash(raw);
  print('raw              → ${raw.value}');
  print('hashed           → $hashed');
  print('is plaintext?    → ${hashed.value.contains('hunter2')}');

  // Test 2: verify with the correct password → true
  print('verify correct   → ${hasher.verify(raw, hashed)}');

  // Test 3: verify with the wrong password → false
  print('verify wrong     → ${hasher.verify(RawPassword('wrong'), hashed)}');

  // Test 4: same password, different salt → different hash
  final hashed2 = hasher.hash(raw);
  print('two hashes equal?→ ${hashed.value == hashed2.value}');
  print('both verify?     → '
      '${hasher.verify(raw, hashed)} / ${hasher.verify(raw, hashed2)}');
}