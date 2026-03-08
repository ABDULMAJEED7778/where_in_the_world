import 'dart:io';

/// API Configuration for Google AI
///
/// To get your API key:
/// 1. Go to https://makersuite.google.com/app/apikey
/// 2. Create a new API key
/// 3. Either:
///    a) Pass it via --dart-define=GOOGLE_AI_API_KEY=your-key (compile-time, recommended for CI)
///    b) Set it as an environment variable: GOOGLE_AI_API_KEY (runtime, for local dev)
///    c) Use the updateApiKey method from GameProvider
class APIConfig {
  // Fallback API key for local development only
  // In CI/production, always use --dart-define=GOOGLE_AI_API_KEY=your-key
  static const String _defaultApiKey =
      'AIzaSyBtBCHB2irTBmFmCjg49SpH910EfHkjpS0';

  /// Get the API key from compile-time define, environment variable, or default
  static String getApiKey() {
    print('\n=== API KEY DETECTION ===');

    // Try compile-time define first (for CI/production builds)
    const String compileTimeKey = String.fromEnvironment('GOOGLE_AI_API_KEY');
    if (compileTimeKey.isNotEmpty && compileTimeKey != 'YOUR_API_KEY_HERE') {
      print('✓ Using compile-time API key (--dart-define)');
      print('===========================\n');
      return compileTimeKey;
    }

    // Try runtime environment variable (for local development)
    try {
      final runtimeKey = Platform.environment['GOOGLE_AI_API_KEY'];
      if (runtimeKey != null &&
          runtimeKey.isNotEmpty &&
          runtimeKey != 'YOUR_API_KEY_HERE') {
        print('✓ Using runtime environment variable API key');
        print('===========================\n');
        return runtimeKey;
      }
    } catch (e) {
      print('Platform.environment not available: $e');
    }

    // Fall back to default (for local development convenience)
    print('⚠ Using default API key (local dev fallback)');
    print('===========================\n');
    return _defaultApiKey;
  }

  /// Check if API key is configured
  static bool isApiKeyConfigured() {
    final key = getApiKey();
    return key.isNotEmpty && key != 'YOUR_API_KEY_HERE';
  }
}
