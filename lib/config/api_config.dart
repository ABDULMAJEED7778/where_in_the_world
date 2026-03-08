import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration for Google AI
///
/// To get your API key:
/// 1. Go to https://makersuite.google.com/app/apikey
/// 2. Create a new API key
/// 3. Either:
///    a) Add it to .env file: GOOGLE_AI_API_KEY=your-key (recommended)
///    b) Set it as an environment variable: GOOGLE_AI_API_KEY (runtime)
///    c) Pass it via --dart-define=GOOGLE_AI_API_KEY=your-key (compile-time)
///    d) Use the updateApiKey method from GameProvider
class APIConfig {
  // API key - also configurable via .env file or --dart-define at build time
  static const String _defaultApiKey =
      'AIzaSyBtBCHB2irTBmFmCjg49SpH910EfHkjpS0';

  /// Get the API key from .env file, environment variable, or default
  static String getApiKey() {
    print('\n=== API KEY DETECTION ===');

    // Try .env file first (recommended method)
    try {
      final envKey = dotenv.env['GOOGLE_AI_API_KEY'];
      print('.env file key found: ${envKey != null}');
      if (envKey != null) {
        print('.env key length: ${envKey.length}');
        print(
          '.env key preview: ${envKey.length > 10 ? "${envKey.substring(0, 10)}..." : envKey}',
        );

        if (envKey.isNotEmpty && envKey != 'YOUR_API_KEY_HERE') {
          print('✓ Using API key from .env file');
          print('===========================\n');
          return envKey;
        }
      }
    } catch (e) {
      print('Error reading .env file: $e');
    }

    // Try compile-time define (for production builds)
    const String compileTimeKey = String.fromEnvironment('GOOGLE_AI_API_KEY');
    print(
      'Compile-time key: ${compileTimeKey.isEmpty ? "(empty)" : "${compileTimeKey.substring(0, compileTimeKey.length > 10 ? 10 : compileTimeKey.length)}..."}',
    );

    if (compileTimeKey.isNotEmpty && compileTimeKey != 'YOUR_API_KEY_HERE') {
      print('Using compile-time API key');
      print('===========================\n');
      return compileTimeKey;
    }

    // Try runtime environment variable (for development)
    try {
      final runtimeKey = Platform.environment['GOOGLE_AI_API_KEY'];
      print('Runtime key found: ${runtimeKey != null}');
      if (runtimeKey != null) {
        print('Runtime key length: ${runtimeKey.length}');
        print(
          'Runtime key preview: ${runtimeKey.length > 10 ? "${runtimeKey.substring(0, 10)}..." : runtimeKey}',
        );
      }

      if (runtimeKey != null &&
          runtimeKey.isNotEmpty &&
          runtimeKey != 'YOUR_API_KEY_HERE') {
        print('Using runtime environment variable API key');
        print('===========================\n');
        return runtimeKey;
      }
    } catch (e) {
      print('Error accessing Platform.environment: $e');
      // Platform.environment might not be available in all contexts
      // (e.g., web), so we catch and continue
    }

    // Fall back to default (which should be replaced)
    print('WARNING: No API key found! Using default placeholder.');
    print(
      'Please create a .env file with GOOGLE_AI_API_KEY=your-key or use GameProvider.updateAIApiKey()',
    );
    print('===========================\n');
    return _defaultApiKey;
  }

  /// Check if API key is configured
  static bool isApiKeyConfigured() {
    final key = getApiKey();
    return key.isNotEmpty && key != 'YOUR_API_KEY_HERE';
  }
}
