import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/question_dialog.dart';
import '../widgets/guess_dialog.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late MediaQuery mediaQuery;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final gameState = gameProvider.gameState;

          if (gameState.isGameOver) {
            return _buildGameEndScreen(gameState);
          }

          return Row(
            children: [
              // Left Column: Logo, Photo, and Last Questions
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Photo section
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildLandmarkImage(gameState),
                      ),
                    ),
                    // Last Questions section
                    Expanded(
                      flex: 1,
                      child: _buildLastQuestionsSection(gameState),
                    ),
                  ],
                ),
              ),
              // Right Column: Leaderboard, Current Turn, and Action Buttons
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTopBar(gameState),
                      _buildLeaderboard(gameState),
                      const SizedBox(height: 16),
                      _buildCurrentPlayer(gameState),
                      const SizedBox(height: 16),
                      _buildActionButtons(gameState),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '${gameState.currentRound}/${gameState.settings.numberOfRounds}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.settings, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Icon(Icons.bar_chart, color: Colors.white, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 240,
          height: 240,
          padding: EdgeInsets.all(40),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              color: Colors.white.withAlpha(200),
              colorBlendMode: BlendMode.modulate,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2D1B69),
                        Color(0xFF74E67C),
                      ], // Primary/Green
                    ),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLandmarkImage(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Image content
              if (gameState.currentLandmark != null)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(
                      20,
                    ), // Adjust margin to fit within frame
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/landmarks/india.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/frame_ar169.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _buildLogoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastQuestionsSection(GameState gameState) {
    return Container(
      alignment: AlignmentDirectional.topStart,
      margin: const EdgeInsets.all(16),
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
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.contact_support_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                question.text.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  Widget _buildLeaderboard(GameState gameState) {
    // Create a mutable copy of the players list to sort it.
    final sortedPlayers = gameState.players.toList();

    // Sort the players by score in descending order.
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));

    return Container(
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
            'LEADERBOARD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            // Get appropriate icon for ranking
            IconData rankIcon;
            Color rankColor;
            if (index == 0) {
              rankIcon = Icons.emoji_events; // Gold crown
              rankColor = const Color(0xFFF3D42B);
            } else if (index == 1) {
              rankIcon = Icons.emoji_events; // Silver crown
              rankColor = const Color(0xFFC0C0C0);
            } else {
              rankIcon = Icons.emoji_events; // Bronze medal
              rankColor = const Color(0xFFCD7F32);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(rankIcon, color: rankColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    '${player.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayer(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B69), // Primary purple
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2D1B69).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '${(gameState.currentPlayer?.name ?? 'UNKNOWN').toUpperCase()}\'S TURN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GameState gameState) {
    return Column(
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
