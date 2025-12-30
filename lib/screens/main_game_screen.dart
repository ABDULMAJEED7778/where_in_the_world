import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:where_in_the_world/widgets/animated_background.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/visual_feedback_overlay.dart';
import '../models/game_models.dart';
import '../widgets/question_dialog.dart';
import '../widgets/guess_dialog.dart';
import '../widgets/leaderboard_dialog.dart';
import '../widgets/game_settings_dialog.dart';
import '../widgets/round_end_dialog.dart';
import '../utils/responsive.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';
import 'package:lottie/lottie.dart';

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

          // ✅ Ensure the game has actually started before showing the main screen
          if (!gameState.gameStarted || gameState.currentPlayer == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return VisualFeedbackOverlay(
            child: Stack(
              children: [
                const AnimatedBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      _buildTopBar(gameState),
                      // Main Content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Image section
                            _buildLandmarkImage(
                              gameState,
                              screenWidth,
                              screenHeight,
                            ),
                            SizedBox(height: screenHeight * .05),
                            // Combined turn panel (badge + questions + buttons)
                            // Only show turn panel if multiplayer, otherwise just show the buttons for single player
                            if (gameState.settings.gameMode ==
                                GameMode.partyMode)
                              LayoutBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) {
                                      return Flexible(
                                        child: _buildTurnPanel(
                                          gameState,
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      );
                                    },
                              )
                            else
                              Flexible(
                                child: _buildSinglePlayerPanel(
                                  gameState,
                                  screenWidth,
                                  screenHeight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Round End Dialog Overlay
                if (gameState.status == GameStatus.roundOver)
                  RoundEndDialog(
                    gameState: gameState,
                    onNextRound: () {
                      context.read<GameProvider>().proceedToNextRound();
                    },
                    onViewScores: () {
                      showDialog(
                        context: context,
                        builder: (context) => LeaderboardDialog(
                          players: gameState.players,
                          showAfterRound: true,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTurnPanel(
    GameState gameState,
    double screenWidth,
    double screenHeight,
  ) {
    // Get the state for the player whose turn it currently is.
    final currentPlayer = gameState.currentPlayer!;
    final questionsAskedByCurrentPlayer =
        gameState.playerQuestionCounts[currentPlayer.id] ?? 0;

    // Rule: Can ask if questions remaining is > 0.
    final canAsk =
        questionsAskedByCurrentPlayer < gameState.settings.questionsPerPlayer;

    // Debug info (remove in production if desired)
    if (!canAsk) {
      debugPrint(
        'ASK button disabled: Player ${currentPlayer.name} has asked '
        '$questionsAskedByCurrentPlayer/${gameState.settings.questionsPerPlayer} questions',
      );
    }

    // Responsive widths
    final panelWidthFactor = Responsive.value<double>(
      context,
      phone: 0.92,
      tablet: 0.75,
      laptop: 0.55,
      desktop: 0.50,
    );
    final panelWidth = screenWidth * panelWidthFactor;

    final cardPadding = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 16,
      laptop: 20,
      desktop: 24,
    );

    final fontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 18,
      desktop: 20,
    );

    return Container(
      width: panelWidth,
      alignment: AlignmentDirectional.center,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main card
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: cardPadding + 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A34A3).withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(18.0),
                      bottomRight: Radius.circular(18.0),
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFEA00),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Last questions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Text(
                              'LAST QUESTIONS ASKED:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: cardPadding),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (gameState.currentRoundQuestions.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.white.withOpacity(
                                                0.4,
                                              ),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'No questions asked yet',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.4,
                                                ),
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ...gameState.currentRoundQuestions
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final q = entry.value;
                                            final answerColor = q.answer
                                                ? const Color(0xFF74E67C)
                                                : const Color(0xFFE63C3D);

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    answerColor.withOpacity(
                                                      0.15,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: answerColor
                                                      .withOpacity(0.4),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Question number badge
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: answerColor
                                                          .withOpacity(0.3),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: answerColor,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: TextStyle(
                                                          color: answerColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Question text
                                                  Expanded(
                                                    child: Text(
                                                      q.text,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Answer badge
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: answerColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      q.answer ? 'YES' : 'NO',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right: Buttons
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 150,
                          maxWidth: 220,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.02,
                          child: Tooltip(
                            message: canAsk
                                ? 'Ask a question about the landmark'
                                : 'You have used all your questions for this round',
                            child: ElevatedButton(
                              onPressed: canAsk
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const QuestionDialog(),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF74E67C),
                                disabledBackgroundColor: Colors.grey
                                    .withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                elevation: 2,
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Text(
                                    'ASK',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 2
                                        ..color = Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'ASK',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge in top-left
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 240, 0),
                        width: 3,
                      ),
                      color: const Color.fromARGB(255, 255, 240, 0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        // Black stroke
                        Text(
                          "${(gameState.currentPlayer?.name ?? 'UNKNOWN').toUpperCase()}'S TURN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Colors.black,
                          ),
                        ),
                        // White fill
                        Text(
                          "${(gameState.currentPlayer?.name ?? 'UNKNOWN').toUpperCase()}'S TURN",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.01),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Anyone can guess',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.035,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.31), // 0%
                        Colors.white.withOpacity(0.14), // 18%
                        Colors.white.withOpacity(0.0), // 50%
                        Colors.white.withOpacity(0.12), // 82%
                        Colors.white.withOpacity(0.27), // 100%
                      ],
                      stops: [0.0, 0.18, 0.5, 0.82, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: EdgeInsets.all(2),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const GuessDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(232, 255, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Text(
                          'GUESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 26,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          'GUESS',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.01),
        ],
      ),
    );
  }

  Widget _buildSinglePlayerPanel(
    GameState gameState,
    double screenWidth,
    double screenHeight,
  ) {
    final currentPlayer = gameState.currentPlayer!;
    final questionsAskedByCurrentPlayer =
        gameState.playerQuestionCounts[currentPlayer.id] ?? 0;

    final canAsk =
        questionsAskedByCurrentPlayer < gameState.settings.questionsPerPlayer;

    // Responsive values
    final panelWidthFactor = Responsive.value<double>(
      context,
      phone: 0.92,
      tablet: 0.75,
      laptop: 0.55,
      desktop: 0.50,
    );
    final panelWidth = screenWidth * panelWidthFactor;

    final cardPadding = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 16,
      laptop: 20,
      desktop: 24,
    );

    final fontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 18,
      desktop: 20,
    );

    return Container(
      width: panelWidth,
      alignment: AlignmentDirectional.topCenter,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              constraints: BoxConstraints(minHeight: screenHeight * 0.12),
              padding: EdgeInsets.symmetric(
                horizontal: cardPadding,
                vertical: cardPadding + 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A34A3).withOpacity(0.6),
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: const Color(0xFFFFEA00), width: 5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'QUESTIONS ASKED:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: cardPadding),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (gameState.currentRoundQuestions.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No questions asked yet',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...gameState.currentRoundQuestions
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final q = entry.value;
                                  final answerColor = q.answer
                                      ? const Color(0xFF74E67C)
                                      : const Color(0xFFE63C3D);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          answerColor.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: answerColor.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Question number badge
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: answerColor.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: answerColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: answerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Question text
                                        Expanded(
                                          child: Text(
                                            q.text,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Answer badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: answerColor,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            q.answer ? 'YES' : 'NO',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.03,
                  child: Tooltip(
                    message: canAsk
                        ? 'Ask a question about the landmark'
                        : 'You have used all your questions for this round',
                    child: ElevatedButton(
                      onPressed: canAsk
                          ? () {
                              AudioService().playSecondaryButtonClick();
                              showDialog(
                                context: context,
                                builder: (context) => const QuestionDialog(),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74E67C),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 2,
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Text(
                            'ASK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          const Text(
                            'ASK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.03,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.31),
                        Colors.white.withOpacity(0.14),
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.27),
                      ],
                      stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ElevatedButton(
                    onPressed: () {
                      AudioService().playButtonClick();
                      showDialog(
                        context: context,
                        builder: (context) => const GuessDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(232, 255, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Text(
                          'GUESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 22,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        const Text(
                          'GUESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ --- ROUND END DIALOG REMOVED - Now using RoundEndDialog widget overlay ---

  Widget _buildTopBar(GameState gameState) {
    final iconSize = Responsive.value<double>(
      context,
      phone: 22,
      tablet: 24,
      laptop: 26,
      desktop: 28,
    );

    final padding = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 16,
      laptop: 20,
      desktop: 24,
    );

    final iconSpacing = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 16,
      laptop: 20,
      desktop: 24,
    );

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  AudioService().playSecondaryButtonClick();
                  showDialog(
                    context: context,
                    builder: (context) =>
                        LeaderboardDialog(players: gameState.players),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: 'View Leaderboard',
                    child: Icon(
                      Icons.leaderboard_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              SizedBox(width: iconSpacing),
              GestureDetector(
                onTap: () {
                  AudioService().playSecondaryButtonClick();
                  showDialog(
                    context: context,
                    builder: (context) => GameSettingsDialog(
                      onQuitToMenu: () {
                        AudioService().stopMusic();
                        this.context.read<GameProvider>().resetGame();
                        Navigator.of(this.context).pushReplacementNamed('/');
                      },
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: 'Settings',
                    child: Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              SizedBox(width: iconSpacing),
              Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // (Helper class moved to top level below)

  Widget _buildLandmarkImage(
    GameState gameState,
    double screenWidth,
    double screenHeight,
  ) {
    // Responsive image width - takes more space on phones, less on larger screens
    final imageWidthFactor = Responsive.value<double>(
      context,
      phone: 0.92, // 92% of screen width on phones
      tablet: 0.75, // 75% on tablets
      laptop: 0.55, // 55% on laptops
      desktop: 0.50, // 50% on desktops
    );
    final imageWidth = screenWidth * imageWidthFactor;

    final borderRadius = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 20,
      laptop: 24,
      desktop: 28,
    );

    return Container(
      width: imageWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
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
        aspectRatio: 16 / 9,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: RainbowEdgeLighting(
              radius: 20,
              thickness: 12.0,
              enabled: true,
              speed: 0.1,
              clip: true, // clip the child to match rounded corners
              // IMPORTANT: put the image as RainbowEdgeLighting's child so the lighting has the right size
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // The image (or a placeholder)
                  if (gameState.currentLandmark != null)
                    Image.network(
                      gameState.currentLandmark!.imagePath,
                      fit: BoxFit.cover,
                      cacheHeight: (screenHeight * 0.6).toInt(),
                      cacheWidth: (imageWidth).toInt(),
                      // frameBuilder works better for showing a loading overlay even if cached
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            final bool isLoaded =
                                frame != null || wasSynchronouslyLoaded;
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                child, // the image
                                // Loading overlay (visible while image not yet rendered)
                                if (!isLoaded)
                                  Container(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Lottie.asset(
                                            'assets/lotties/Camera.json',
                                            key: const ValueKey('loading_anim'),
                                            width: imageWidth / 4,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                      // Show an error UI (and don't immediately navigate away)
                      errorBuilder: (context, error, stackTrace) {
                        // Log for devs
                        debugPrint('Error loading image: $error');
                        debugPrint(stackTrace.toString());

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            context.read<GameProvider>().switchToNextLandmark();
                          }
                        });

                        return Container(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lotties/Camera.json',
                                  key: const ValueKey('loading_anim'),
                                  width: imageWidth / 4,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    // fallback when currentLandmark is null
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lotties/hot_air_ballon_anim.json',
                              key: const ValueKey('loading_anim'),
                              width: imageWidth / 4,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Removed legacy separate sections in favor of combined panel
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
