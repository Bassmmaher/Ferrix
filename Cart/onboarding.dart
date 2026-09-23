// ═══════════════════════════════════════════════════════════════
//   TECH STORE — ONBOARDING FLOW
//   A self-contained onboarding system with:
//   - Splash screen
//   - Welcome slides (paginated)
//   - User preference collection (interests, notifications)
//   - Account setup (register / login / guest)
//   - Completion summary
// ═══════════════════════════════════════════════════════════════

// ============================================================
// SECTION 1 — MODELS
// ============================================================

/// A single onboarding slide.
class OnboardingSlide {
  final String title;
  final String description;
  final String emoji;
  final String accentColor;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
  });
}

/// User preference collected during onboarding.
class UserPreferences {
  final Set<String> interests = {};
  bool notificationsEnabled = false;
  bool newsletterSubscribed = false;
  bool darkMode = false;
  String preferredCurrency = 'USD';
  String preferredLanguage = 'en';

  @override
  String toString() =>
      'Interests: ${interests.join(", ")}\n'
      '  Notifications: $notificationsEnabled\n'
      '  Newsletter: $newsletterSubscribed\n'
      '  Dark Mode: $darkMode\n'
      '  Currency: $preferredCurrency\n'
      '  Language: $preferredLanguage';
}

/// Onboarding state machine stages.
enum OnboardingStep {
  splash,
  welcome,
  interests,
  preferences,
  accountSetup,
  completed,
}

/// Final result returned after onboarding completes.
class OnboardingResult {
  final String userId;
  final String username;
  final String email;
  final UserPreferences preferences;
  final bool isGuest;
  final DateTime completedAt;

  OnboardingResult({
    required this.userId,
    required this.username,
    required this.email,
    required this.preferences,
    required this.isGuest,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  void printSummary() {
    print('\n╔══════════════════════════════════════════════════════════╗');
    print('║              🎉  ONBOARDING COMPLETE  🎉                 ║');
    print('╚══════════════════════════════════════════════════════════╝');
    print('  User ID    : $userId');
    print('  Username   : $username');
    print('  Email      : $email');
    print('  Account    : ${isGuest ? "Guest" : "Registered"}');
    print('  Completed  : ${completedAt.toString().split(".").first}');
    print('  ──────────────────────────────────────────────────────');
    print('  PREFERENCES:');
    print('    $preferences');
    print('  ──────────────────────────────────────────────────────');
    print('  ✅ You\'re all set! Enjoy shopping at Tech Store.');
    print('╚══════════════════════════════════════════════════════════╝\n');
  }
}

// ============================================================
// SECTION 2 — ONBOARDING MANAGER
// ============================================================

class OnboardingManager {
  OnboardingStep _step = OnboardingStep.splash;
  final UserPreferences _prefs = UserPreferences();

  // Session data collected as we progress
  String _username = '';
  String _email = '';
  // ignore: unused_field
  String _password = '';
  bool _isGuest = false;
  String _userId = '';

  OnboardingStep get currentStep => _step;
  UserPreferences get preferences => _prefs;
  bool get isComplete => _step == OnboardingStep.completed;

  // Predefined slides
  static final List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Welcome to Tech Store',
      description:
          'Your one-stop shop for the latest smartphones, laptops, '
          'headphones, and gadgets — all in one place.',
      emoji: '💻',
      accentColor: 'Blue',
    ),
    OnboardingSlide(
      title: 'Wide Selection',
      description:
          'Browse hundreds of products from top brands like Apple, '
          'Samsung, Sony, and Dell — always at competitive prices.',
      emoji: '🛍️',
      accentColor: 'Purple',
    ),
    OnboardingSlide(
      title: 'Fast & Secure Checkout',
      description:
          'Pay with credit card, PayPal, or cash on delivery. '
          'Your data is encrypted and safe.',
      emoji: '🔒',
      accentColor: 'Green',
    ),
    OnboardingSlide(
      title: 'Exclusive Deals',
      description:
          'Get access to members-only coupons and personalized '
          'recommendations based on your interests.',
      emoji: '🎁',
      accentColor: 'Orange',
    ),
  ];

  /// Advance the state machine.
  void nextStep() {
    switch (_step) {
      case OnboardingStep.splash:
        _step = OnboardingStep.welcome;
        break;
      case OnboardingStep.welcome:
        _step = OnboardingStep.interests;
        break;
      case OnboardingStep.interests:
        _step = OnboardingStep.preferences;
        break;
      case OnboardingStep.preferences:
        _step = OnboardingStep.accountSetup;
        break;
      case OnboardingStep.accountSetup:
        _step = OnboardingStep.completed;
        break;
      case OnboardingStep.completed:
        break;
    }
  }

  /// Go back to the previous step.
  bool previousStep() {
    switch (_step) {
      case OnboardingStep.interests:
        _step = OnboardingStep.welcome;
        return true;
      case OnboardingStep.preferences:
        _step = OnboardingStep.interests;
        return true;
      case OnboardingStep.accountSetup:
        _step = OnboardingStep.preferences;
        return true;
      default:
        return false;
    }
  }

  /// Toggle an interest.
  void toggleInterest(String interest) {
    if (_prefs.interests.contains(interest)) {
      _prefs.interests.remove(interest);
    } else {
      _prefs.interests.add(interest);
    }
  }

  /// Update preferences.
  void setNotifications(bool v) => _prefs.notificationsEnabled = v;
  void setNewsletter(bool v) => _prefs.newsletterSubscribed = v;
  void setDarkMode(bool v) => _prefs.darkMode = v;
  void setCurrency(String c) => _prefs.preferredCurrency = c;
  void setLanguage(String l) => _prefs.preferredLanguage = l;

  /// Register a new account.
  OnboardingResult register({
    required String username,
    required String email,
    required String password,
  }) {
    if (username.trim().isEmpty) throw Exception('Username required.');
    if (!email.contains('@')) throw Exception('Invalid email.');
    if (password.length < 3) throw Exception('Password too short.');

    _username = username;
    _email = email;
    _password = password;
    _isGuest = false;
    _userId = 'USR-${DateTime.now().millisecondsSinceEpoch % 100000}';
    _step = OnboardingStep.completed;

    return _buildResult();
  }

  /// Continue as guest.
  OnboardingResult continueAsGuest() {
    _username = 'Guest';
    _email = 'guest@techstore.com';
    _password = '';
    _isGuest = true;
    _userId = 'USR-GUEST-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _step = OnboardingStep.completed;

    return _buildResult();
  }

  /// Cancel onboarding (reset).
  void reset() {
    _step = OnboardingStep.splash;
    _prefs.interests.clear();
    _prefs.notificationsEnabled = false;
    _prefs.newsletterSubscribed = false;
    _prefs.darkMode = false;
    _prefs.preferredCurrency = 'USD';
    _prefs.preferredLanguage = 'en';
    _username = '';
    _email = '';
    _password = '';
    _isGuest = false;
    _userId = '';
  }

  OnboardingResult _buildResult() => OnboardingResult(
        userId: _userId,
        username: _username,
        email: _email,
        preferences: _prefs,
        isGuest: _isGuest,
      );

  // ─── Available options ────────────────────────────────────
  static const List<String> interestOptions = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'Headphones',
    'Earbuds',
    'Monitors',
    'Accessories',
    'Gaming',
  ];

  static const List<String> currencyOptions = ['USD', 'EUR', 'EGP', 'GBP'];
  static const List<String> languageOptions = ['en', 'ar', 'fr', 'es'];
}

// ============================================================
// SECTION 3 — UI RENDERERS (console)
// ============================================================

void renderSplash() {
  print('\n\n');
  print('  ╔══════════════════════════════════════════════════════╗');
  print('  ║                                                      ║');
  print('  ║              💻  T E C H   S T O R E  💻             ║');
  print('  ║                                                      ║');
  print('  ║           Your Electronic Devices Destination        ║');
  print('  ║                                                      ║');
  print('  ║                      v1.0.0                          ║');
  print('  ║                                                      ║');
  print('  ╚══════════════════════════════════════════════════════╝');
  print('\n');
  for (int i = 5; i > 0; i--) {
    print('  ⏳ Loading... $i');
  }
  print('  ✅ Ready!\n');
}

void renderSlide(int index, int total) {
  final s = OnboardingManager.slides[index];
  print('\n  ${s.emoji}  ${s.title}');
  print('  ${"─" * 56}');
  _wrap(s.description, 54, '  ');
  print('');
  _renderDots(index, total);
}

void renderInterests(OnboardingManager mgr) {
  print('\n  🎯 Select your interests');
  print('  ${"─" * 56}');
  print('  (Tap to toggle. Multiple choices allowed.)\n');
  final opts = OnboardingManager.interestOptions;
  for (int i = 0; i < opts.length; i++) {
    final selected = mgr.preferences.interests.contains(opts[i]);
    final mark = selected ? '✅' : '⬜';
    print('  ${(i + 1).toString().padLeft(2)}. $mark  ${opts[i]}');
  }
  print('');
}

void renderPreferences(OnboardingManager mgr) {
  final p = mgr.preferences;
  print('\n  ⚙️  App Preferences');
  print('  ${"─" * 56}');
  print('  Notifications       : ${p.notificationsEnabled ? "ON  ✅" : "OFF ❌"}');
  print('  Newsletter          : ${p.newsletterSubscribed ? "ON  ✅" : "OFF ❌"}');
  print('  Dark Mode           : ${p.darkMode ? "ON  ✅" : "OFF ❌"}');
  print('  Preferred Currency  : ${p.preferredCurrency}');
  print('  Preferred Language  : ${p.preferredLanguage}');
  print('');
}

void renderAccountSetup({bool isGuest = false}) {
  print('\n  👤 Account Setup');
  print('  ${"─" * 56}');
  if (isGuest) {
    print('  You have chosen to continue as a Guest.');
    print('  Some features (order history, coupons) may be limited.');
  } else {
    print('  Create your Tech Store account.');
  }
  print('');
}

void _renderDots(int active, int total) {
  final buf = StringBuffer('  ');
  for (int i = 0; i < total; i++) {
    buf.write(i == active ? '● ' : '○ ');
  }
  print(buf.toString());
}

void _wrap(String text, int width, String indent) {
  final words = text.split(' ');
  var line = StringBuffer(indent);
  var len = 0;
  for (final w in words) {
    if (len + w.length + 1 > width) {
      print(line.toString());
      line = StringBuffer(indent);
      len = 0;
    }
    line.write('$w ');
    len += w.length + 1;
  }
  if (line.isNotEmpty) print(line.toString());
}

// ============================================================
// SECTION 4 — DEMO MAIN
// ============================================================

void main() {
  print('\n╔══════════════════════════════════════════════════════════╗');
  print('║       🚀  TECH STORE ONBOARDING — DEMO RUN               ║');
  print('╚══════════════════════════════════════════════════════════╝');

  final mgr = OnboardingManager();

  // ─── STEP 1: Splash ─────────────────────────────────────
  print('\n▶  STEP 1 — SPLASH SCREEN\n');
  renderSplash();
  mgr.nextStep(); // splash → welcome

  // ─── STEP 2: Welcome slides ─────────────────────────────
  print('\n▶  STEP 2 — WELCOME SLIDES\n');
  for (int i = 0; i < OnboardingManager.slides.length; i++) {
    renderSlide(i, OnboardingManager.slides.length);
    print('  [Next ▶]\n');
  }
  mgr.nextStep(); // welcome → interests

  // ─── STEP 3: Interests ──────────────────────────────────
  print('\n▶  STEP 3 — INTEREST SELECTION\n');
  // Simulate taps
  mgr.toggleInterest('Smartphones');
  mgr.toggleInterest('Laptops');
  mgr.toggleInterest('Headphones');
  renderInterests(mgr);
  print('  ✅ Selected 3 interests.\n');
  mgr.nextStep(); // interests → preferences

  // ─── STEP 4: Preferences ────────────────────────────────
  print('\n▶  STEP 4 — APP PREFERENCES\n');
  mgr.setNotifications(true);
  mgr.setNewsletter(true);
  mgr.setDarkMode(true);
  mgr.setCurrency('EGP');
  mgr.setLanguage('en');
  renderPreferences(mgr);
  mgr.nextStep(); // preferences → accountSetup

  // ─── STEP 5: Account Setup ──────────────────────────────
  print('\n▶  STEP 5 — ACCOUNT SETUP\n');
  renderAccountSetup();

  // Show both paths (guest + register) as an example
  print('  Demo A → Continue as Guest:');
  final guestResult = mgr.continueAsGuest();
  guestResult.printSummary();

  // Reset and show full register flow
  print('  🔄 Resetting onboarding to demonstrate register flow...\n');
  mgr.reset();

  // Fast-forward through the same steps
  mgr.nextStep(); // splash → welcome
  mgr.nextStep(); // welcome → interests
  mgr.toggleInterest('Smartphones');
  mgr.toggleInterest('Gaming');
  mgr.nextStep(); // interests → preferences
  mgr.setNotifications(true);
  mgr.setDarkMode(true);
  mgr.setCurrency('USD');
  mgr.nextStep(); // preferences → accountSetup

  print('  Demo B → Register new account:');
  final regResult = mgr.register(
    username: 'ahmed_dev',
    email: 'ahmed@example.com',
    password: 'securePass123',
  );
  regResult.printSummary();

  // ─── STEP 6: Verify state ───────────────────────────────
  print('▶  STEP 6 — VERIFY FINAL STATE\n');
  print('  isComplete       : ${mgr.isComplete}');
  print('  Current step     : ${mgr.currentStep.name}');
  print('  Interests count  : ${mgr.preferences.interests.length}');
  print('  Dark mode        : ${mgr.preferences.darkMode}');
  print('  Currency         : ${mgr.preferences.preferredCurrency}');

  // ─── STEP 7: Error handling demos ───────────────────────
  print('\n▶  STEP 7 — ERROR HANDLING DEMOS\n');
  final mgr2 = OnboardingManager();
  mgr2.nextStep(); // splash → welcome
  mgr2.nextStep(); // welcome → interests
  mgr2.nextStep(); // interests → preferences
  mgr2.nextStep(); // preferences → accountSetup

  try {
    mgr2.register(username: '', email: 'a@b.com', password: '123');
  } catch (e) {
    print('  ⚠️  Caught: $e');
  }
  try {
    mgr2.register(username: 'user', email: 'invalid-email', password: '123');
  } catch (e) {
    print('  ⚠️  Caught: $e');
  }
  try {
    mgr2.register(username: 'user', email: 'u@e.com', password: '1');
  } catch (e) {
    print('  ⚠️  Caught: $e');
  }

  // ─── STEP 8: Navigation (back) ──────────────────────────
  print('\n▶  STEP 8 — NAVIGATION (BACK BUTTON)\n');
  print('  Current step: ${mgr2.currentStep.name}');
  print('  Going back → ${mgr2.previousStep()}, '
      'now at: ${mgr2.currentStep.name}');
  print('  Going back → ${mgr2.previousStep()}, '
      'now at: ${mgr2.currentStep.name}');
  print('  Going back → ${mgr2.previousStep()}, '
      'now at: ${mgr2.currentStep.name}');
  print('  Going back → ${mgr2.previousStep()} '
      '(false = cannot go further back)');

  print('\n╔══════════════════════════════════════════════════════════╗');
  print('║               ✅  DEMO COMPLETE                          ║');
  print('╚══════════════════════════════════════════════════════════╝\n');
}