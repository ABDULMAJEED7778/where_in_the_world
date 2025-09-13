// This is a basic Flutter widget test for the Where in the World game.

import 'package:flutter_test/flutter_test.dart';

import 'package:where_in_the_world/providers/game_provider.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  testWidgets('Game provider works correctly', (WidgetTester tester) async {
    // Test the game provider functionality
    final gameProvider = GameProvider();

    // Test adding players
    gameProvider.addPlayer('Player 1');
    gameProvider.addPlayer('Player 2');

    expect(gameProvider.gameState.players.length, 2);
    expect(gameProvider.gameState.players[0].name, 'Player 1');
    expect(gameProvider.gameState.players[1].name, 'Player 2');

    // Test game settings
    final settings = GameSettings(
      gameMode: GameMode.multiplayer,
      difficulty: Difficulty.easy,
      numberOfRounds: 5,
      questionsPerPlayer: 2,
    );

    gameProvider.updateSettings(settings);
    expect(gameProvider.gameState.settings.numberOfRounds, 5);
    expect(gameProvider.gameState.settings.difficulty, Difficulty.easy);
  });
}
