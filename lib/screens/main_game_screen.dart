import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/question_dialog.dart';
import '../widgets/guess_dialog.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final gameState = gameProvider.gameState;

          if (gameState.isGameOver) {
            return _buildGameEndScreen(gameState);
          }

          return SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(gameState),
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image section
                      _buildLandmarkImage(gameState, screenWidth, screenHeight),
                      // Player turn indicator
                      _buildCurrentPlayer(gameState),
                      const SizedBox(height: 16),
                      // Last Questions section
                      _buildLastQuestionsSection(gameState),
                      const SizedBox(height: 24),
                      // Action buttons
                      _buildActionButtons(gameState),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkImage(
    GameState gameState,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      width: screenWidth / 1.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            spreadRadius: 4,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9, // ✅ Always keep 16:9 ratio
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/landmarks/taj_mahal.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: RainbowEdgeLighting(
                glowEnabled: false, // Enable outer glow halo
                radius: 20, // corner radius
                thickness: 12.0, // stroke width
                enabled: true, // fade in/out when toggled
                speed: 0.1, // rotations per second (rps)
                clip: false, // clip the child with the same radius
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastQuestionsSection(GameState gameState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B69), // Primary purple
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2D1B69).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST QUESTIONS ASKED:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          if (gameState.questionsAsked.isEmpty)
            const Text(
              'No questions asked yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            )
          else
            ...gameState.questionsAsked
                .take(2)
                .map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            question.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          question.answer ? 'YES' : 'NO',
                          style: TextStyle(
                            color: question.answer
                                ? const Color(0xFF74E67C)
                                : const Color(0xFFE63C3D), // Green/Red
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayer(GameState gameState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3D42B), // Dark purple background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(gameState.currentPlayer?.name ?? 'UNKNOWN').toUpperCase()}\'S TURN',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const QuestionDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74E67C), // Green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'ASK A QUESTION!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const GuessDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE63C3D), // Red
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'GUESS!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEndScreen(GameState gameState) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(
            0xFF2D1B69,
          ).withOpacity(0.9), // Primary with opacity
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 80,
              color: Color(0xFFF3D42B),
            ), // Yellow
            const SizedBox(height: 20),
            Text(
              'Game Over!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Winner: ${gameState.winner}',
              style: const TextStyle(
                color: Color(0xFFF3D42B), // Yellow
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<GameProvider>().resetGame();
                Navigator.of(context).pushReplacementNamed('/lobby');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3D42B), // Yellow
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
