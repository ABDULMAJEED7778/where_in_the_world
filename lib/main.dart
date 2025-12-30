import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/game_provider.dart';
import 'services/photos_service.dart';
import 'services/audio_service.dart';
import 'screens/launching_screen.dart';
import 'screens/main_game_screen.dart';
import 'screens/online_lobby_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (for web, it needs to be in assets)
  try {
    // For web, try assets/.env first (works for web and mobile)
    await dotenv.load(fileName: "assets/.env");
    print('✓ .env file loaded successfully from assets/.env');
  } catch (e) {
    // If that fails, try root .env (works for desktop/mobile)
    try {
      await dotenv.load(fileName: ".env");
      print('✓ .env file loaded successfully from root');
    } catch (e2) {
      print('⚠ Warning: Could not load .env file');
      print('⚠ Error from assets/.env: $e');
      print('⚠ Error from .env: $e2');
      print(
        '⚠ Continuing without .env file. You can set API key via environment variable or programmatically.',
      );
    }
  }

  // Preload photos data on app startup
  try {
    await PhotosService().loadLandmarks();
    print('✓ Photos data preloaded successfully');
  } catch (e) {
    print('⚠ Warning: Could not preload photos data: $e');
  }

  // Initialize Firebase for online multiplayer
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('⚠ Warning: Firebase initialization failed: $e');
    print('⚠ Online multiplayer features will be unavailable');
  }

  // Initialize audio service in background (fire and forget)
  // We don't await this so the app launches immediately
  try {
    AudioService().initialize();
    print('✓ Audio service initialization started');
  } catch (e) {
    print('⚠ Warning: Could not initialize audio service: $e');
  }

  runApp(const WhereInTheWorldApp());
}

class WhereInTheWorldApp extends StatelessWidget {
  const WhereInTheWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Where in the World?',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D1B69), // Primary
            primary: const Color(0xFF2D1B69),
            secondary: const Color(0xFF74E67C), // Green
            tertiary: const Color(0xFFFFEA00), // Yellow
            error: const Color(0xFFE63C3D), // Red
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF2D1B69),
          textTheme:
              GoogleFonts.hanaleiFillTextTheme(
                Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white, // optional
                  displayColor: Colors.white,
                ),
              ).copyWith(
                bodyMedium: GoogleFonts.hanaleiFill(
                  textStyle: const TextStyle(letterSpacing: 1.0),
                ),
                bodySmall: GoogleFonts.hanaleiFill(
                  textStyle: const TextStyle(letterSpacing: 1.5),
                ),
                labelSmall: GoogleFonts.hanaleiFill(
                  textStyle: const TextStyle(letterSpacing: 10.0),
                ),
              ),
        ),
        home: const LaunchingScreen(),
        routes: {
          '/game': (context) => const MainGameScreen(),
          '/online': (context) => const OnlineLobbyScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
