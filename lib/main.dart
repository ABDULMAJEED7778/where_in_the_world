import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_provider.dart';
import 'screens/launching_screen.dart';
import 'screens/game_lobby_screen.dart';
import 'screens/main_game_screen.dart';

void main() {
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
            tertiary: const Color(0xFFF3D42B), // Yellow
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
                  textStyle: const TextStyle(letterSpacing: 2.0),
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
          '/lobby': (context) => const GameLobbyScreen(),
          '/game': (context) => const MainGameScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
