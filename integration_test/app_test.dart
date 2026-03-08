import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_in_the_world/providers/game_provider.dart';
import 'package:where_in_the_world/screens/launching_screen.dart';
import 'package:where_in_the_world/screens/main_game_screen.dart';
import 'package:where_in_the_world/services/photos_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Full Game Flow — Single Player', () {
    late GameProvider gameProvider;

    setUp(() async {
      // Pre-load landmark data so startGame() can pick a random landmark
      await PhotosService().loadLandmarks();
      gameProvider = GameProvider();
    });

    testWidgets('Launch → Mode → Lobby → Game → End', (tester) async {
      // ─── Build the app ────────────────────────────────────────────
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: MaterialApp(
            home: const LaunchingScreen(),
            routes: {'/game': (context) => const MainGameScreen()},
          ),
        ),
      );

      // ─── Step 1: Launch Screen ────────────────────────────────────
      // Wait for the 2-second entrance animation + button reveal
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(); // process setState from animation listener

      expect(find.text('START GAME'), findsOneWidget);

      // Tap START GAME → navigates to ModeSelectionScreen
      await tester.tap(find.text('START GAME'));
      await tester.pump(); // start navigation
      await tester.pump(const Duration(milliseconds: 500)); // route transition
      await tester.pump(const Duration(milliseconds: 500)); // animation settle

      // ─── Step 2: Mode Selection Screen ────────────────────────────
      expect(find.text('SELECT GAME MODE'), findsOneWidget);
      expect(find.text('SINGLE PLAYER'), findsOneWidget);
      expect(find.text('PARTY MODE'), findsOneWidget);
      expect(find.text('ONLINE ROOMS'), findsOneWidget);

      // Tap SINGLE PLAYER → navigates to GameLobbyScreen
      await tester.tap(find.text('SINGLE PLAYER'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // ─── Step 3: Game Lobby Screen (Single Player) ────────────────
      expect(find.text('ENTER YOUR NAME:'), findsOneWidget);
      expect(find.text('CHOOSE YOUR GAME SETTINGS'), findsOneWidget);

      // Enter player name
      final nameField = find.widgetWithText(TextField, 'Your name');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Tester');
      await tester.pump();

      // Tap SET button
      await tester.tap(find.text('SET'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify player was added - name appears in the confirmation container
      expect(find.text('Tester'), findsOneWidget);

      // ─── Step 4: Tap PLAY! ────────────────────────────────────────
      // PLAY! text appears twice (stroke + fill) in a Stack, find the ancestor
      final playButton = find
          .ancestor(
            of: find.text('PLAY!').first,
            matching: find.byType(ElevatedButton),
          )
          .first;
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      // startGame() is async — it loads a landmark from PhotosService
      await tester.pump(); // start
      await tester.pump(const Duration(seconds: 1)); // let async complete
      await tester.pump(const Duration(milliseconds: 500)); // route transition
      await tester.pump(const Duration(milliseconds: 500)); // settle

      // ─── Step 5: Main Game Screen ─────────────────────────────────
      // Single-player mode shows "QUESTIONS ASKED:" in the game panel
      expect(find.textContaining('QUESTIONS'), findsAtLeastNWidgets(1));

      // ─── Step 6: Force game end via provider ──────────────────────
      gameProvider.forceEndGame();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // GameEndScreen animations

      // ─── Step 7: Game End Screen ──────────────────────────────────
      expect(find.text('GAME COMPLETE!'), findsOneWidget);
      expect(find.text('Your Score'), findsOneWidget);
      expect(find.text('Rounds'), findsOneWidget);
      expect(find.text('Players'), findsOneWidget);

      // ─── Step 8: Tap PLAY to return to lobby ──────────────────────
      // On phone layout, button text is 'PLAY'; on larger, 'PLAY AGAIN'
      final playAgainFinder = find.text('PLAY').evaluate().isNotEmpty
          ? find.text('PLAY')
          : find.text('PLAY AGAIN');
      await tester.tap(playAgainFinder.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be back at the lobby screen
      expect(find.text('CHOOSE YOUR GAME SETTINGS'), findsOneWidget);
    });
  });
}
