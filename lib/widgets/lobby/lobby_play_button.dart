import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_models.dart';
import '../../providers/game_provider.dart';
import '../../screens/main_game_screen.dart';

/// Gradient play button with glow effect.
/// Checks player count via Consumer<GameProvider> and navigates to game.
class LobbyPlayButton extends StatelessWidget {
  final GameMode gameMode;
  final Difficulty difficulty;
  final int numberOfRounds;
  final int questionsPerPlayer;
  final bool isTimerEnabled;
  final int timerDuration;

  const LobbyPlayButton({
    super.key,
    required this.gameMode,
    required this.difficulty,
    required this.numberOfRounds,
    required this.questionsPerPlayer,
    required this.isTimerEnabled,
    required this.timerDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final canPlay = gameMode == GameMode.singlePlayer
            ? gameProvider.gameState.players.length >= 1
            : gameProvider.gameState.players.length >= 2;

        final glowColor = const Color(0xFFEB7A36);

        return Container(
          width: 220,
          height: 55,
          decoration: BoxDecoration(
            gradient: canPlay
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFE63C3D),
                      Color(0xFFEB7A36),
                      Color(0xFFF3D42B),
                      Color(0xFFEB7A36),
                      Color(0xFFE63C3D),
                    ],
                  )
                : null,
            color: canPlay ? null : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: canPlay ? glowColor : Colors.grey.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: canPlay
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFE63C3D).withOpacity(0.4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: canPlay
                ? () async {
                    gameProvider.updateSettings(
                      GameSettings(
                        gameMode: gameMode,
                        difficulty: difficulty,
                        numberOfRounds: numberOfRounds,
                        questionsPerPlayer: questionsPerPlayer,
                        isTimerEnabled: isTimerEnabled,
                        turnDurationSeconds: timerDuration,
                      ),
                    );
                    await gameProvider.startGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainGameScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: canPlay ? Colors.white : Colors.white38,
                  size: 28,
                ),
                const SizedBox(width: 4),
                Stack(
                  children: [
                    Text(
                      "PLAY!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 3
                          ..color = Colors.black.withOpacity(
                            canPlay ? 0.5 : 0.2,
                          ),
                      ),
                    ),
                    Text(
                      'PLAY!',
                      style: TextStyle(
                        color: canPlay ? Colors.white : Colors.white38,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
