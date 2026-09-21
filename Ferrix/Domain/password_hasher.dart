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

  static String _truncate(String s, [int n = 8]) =>
      s.length <= n ? s : '${s.substring(0, n)}...';

  @override
  bool operator ==(Object other) =>
      other is HashedPassword && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'HashedPassword(${_truncate(value)})';
}

// ─────────────────────────────────────────────────────────────
// The real thing — your PasswordHasher port, unchanged
// ─────────────────────────────────────────────────────────────
abstract class PasswordHasher {
  HashedPassword hash(RawPassword password);
  bool verify(RawPassword password, HashedPassword hash);
}

// ─────────────────────────────────────────────────────────────
// Fake implementations for the demo
// ─────────────────────────────────────────────────────────────
class FakePasswordHasher implements PasswordHasher {
  @override
  HashedPassword hash(RawPassword password) =>
      HashedPassword('hash:${password.value}');

  @override
  bool verify(RawPassword password, HashedPassword hash) =>
      hash.value == 'hash:${password.value}';
}

class AlwaysFailingHasher implements PasswordHasher {
  @override
  HashedPassword hash(RawPassword password) =>
      throw StateError('hasher unavailable');

  @override
  bool verify(RawPassword password, HashedPassword hash) =>
      throw StateError('hasher unavailable');
}

// ─────────────────────────────────────────────────────────────
// Entry point — exercise the port contract
// ─────────────────────────────────────────────────────────────
void main() {
  final hasher = FakePasswordHasher();
  final raw = RawPassword('correct-horse-battery-staple');

  // Test 1: hash produces a hashed value
  final hashed = hasher.hash(raw);
  print('raw            → $raw');
  print('hashed         → $hashed');
  print('contains raw?  → ${hashed.value.contains(raw.value)}');

  // Test 2: verify with correct password → true
  print('verify correct → ${hasher.verify(raw, hashed)}');

  // Test 3: verify with wrong password → false
  print('verify wrong   → ${hasher.verify(RawPassword('wrong'), hashed)}');

  // Test 4: two hashes of the same password
  final hashed2 = hasher.hash(raw);
  print('hash1 == hash2 → ${hashed.value == hashed2.value}');
  print('  (real bcrypt: false — this fake is NOT production-safe)');

  // Test 5: different passwords produce different hashes
  final hashedOther = hasher.hash(RawPassword('different'));
  print('different pw   → hash differs? '
      '${hashed.value != hashedOther.value}');

  // Test 6: port is substitutable — failing impl propagates
  final PasswordHasher failing = AlwaysFailingHasher();
  try {
    failing.hash(raw);
  } catch (e) {
    print('failing impl   → $e');
  }

  // Test 7: empty password behavior (the case that crashed before)
  final emptyHash = hasher.hash(RawPassword(''));
  print('empty password → hash=$emptyHash, verify='
      '${hasher.verify(RawPassword(''), emptyHash)}');
}