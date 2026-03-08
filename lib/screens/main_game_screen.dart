import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'game_end_screen.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';
import 'package:lottie/lottie.dart';
import '../widgets/turn_timer_widget.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _askButtonFlashController;
  String? _lastPlayerTurnId;
  int _lastFlashedTime = -1;

  @override
  void initState() {
    super.initState();
    _askButtonFlashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _askButtonFlashController.dispose();
    super.dispose();
  }

  void _updateFlashLogic(GameProvider provider) {
    if (!mounted) return;

    final currentId = provider.gameState.currentPlayer?.id;
    final timeRemaining = provider.timeRemaining;
    bool shouldFlash = false;

    // 1. Flash when a new player's turn starts
    if (currentId != null && currentId != _lastPlayerTurnId) {
      _lastPlayerTurnId = currentId;
      shouldFlash = true;
    }

    // 2. Flash at specific intervals (e.g. 45, 30, 15 seconds remaining)
    // Only if we haven't already flashed for this exact second
    if (!shouldFlash &&
        timeRemaining > 0 &&
        timeRemaining < provider.gameState.settings.turnDurationSeconds &&
        timeRemaining % 15 == 0 &&
        _lastFlashedTime != timeRemaining) {
      shouldFlash = true;
    }

    if (shouldFlash) {
      _lastFlashedTime = timeRemaining;

      // Reset any ongoing flash
      _askButtonFlashController.stop();
      _askButtonFlashController.reset();

      // Start flash animation (looping for 3 seconds)
      _askButtonFlashController.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _askButtonFlashController.stop();
          _askButtonFlashController.reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final gameState = gameProvider.gameState;

          _updateFlashLogic(gameProvider);

          if (gameState.isGameOver) {
            return GameEndScreen(gameState: gameState);
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
                              Flexible(
                                child: LayoutBuilder(
                                  builder:
                                      (
                                        BuildContext context,
                                        BoxConstraints constraints,
                                      ) {
                                        return _buildTurnPanel(
                                          gameProvider,
                                          screenWidth,
                                          screenHeight,
                                        );
                                      },
                                ),
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
    GameProvider gameProvider,
    double screenWidth,
    double screenHeight,
  ) {
    final gameState = gameProvider.gameState;
    // Get the state for the player whose turn it currently is.
    final currentPlayer = gameState.currentPlayer!;
    final questionsAskedByCurrentPlayer =
        gameState.playerQuestionCounts[currentPlayer.id] ?? 0;

    final canAsk =
        questionsAskedByCurrentPlayer < gameState.settings.questionsPerPlayer;
    final questionsRemaining =
        (gameState.settings.questionsPerPlayer - questionsAskedByCurrentPlayer)
            .clamp(0, 99);

    // Debug info (remove in production if desired)
    if (!canAsk) {
      debugPrint(
        'ASK button disabled: Player ${currentPlayer.name} has asked '
        '$questionsAskedByCurrentPlayer/${gameState.settings.questionsPerPlayer} questions',
      );
    }

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

    final buttonHeight = Responsive.value<double>(
      context,
      phone: 44,
      tablet: 50,
      laptop: 56,
      desktop: 60,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 18,
      laptop: 20,
      desktop: 22,
    );

    final isPhone = Responsive.isPhone(context);

    final bool allQuestionsUsed = gameProvider.allQuestionsUsed;

    // Build the player turn badge
    Widget playerBadge = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 6),
      decoration: BoxDecoration(
        color: allQuestionsUsed
            ? const Color(0xFFFF3D00)
            : const Color(0xFFFFEA00),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      child: allQuestionsUsed
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "ALL QUESTIONS DONE! GUESSING TIME",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${currentPlayer.name.toUpperCase()}'S TURN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                TurnTimerWidget(
                  timeRemaining: gameProvider.timeRemaining,
                  totalTime: gameState.settings.turnDurationSeconds,
                  size: fontSize * 1.5,
                  isPaused:
                      !gameProvider.isImageLoaded || gameProvider.isTimerPaused,
                  isEnabled: gameState.settings.isTimerEnabled,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: fontSize * 0.9,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$questionsRemaining',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: fontSize * 0.9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );

    // Build the questions card
    final hasScrollableContent = gameState.currentRoundQuestions.length > 2;

    // Dynamic height based on screen height and aspect ratio
    // Reduce heights on wide screens (aspect ratio >= 2:1) to prevent overflow
    final aspectRatio = screenWidth / screenHeight;
    final heightMultiplier = aspectRatio >= 2.0
        ? 1.0
        : (aspectRatio >= 1.5 ? 1.9 : 1.0);

    final minListHeight = (screenHeight * 0.08 * heightMultiplier).clamp(
      50.0,
      100.0,
    );
    final maxListHeight = (screenHeight * 0.20 * heightMultiplier).clamp(
      80.0,
      250.0,
    );

    Widget questionsCard = Container(
      constraints: BoxConstraints(
        minHeight: minListHeight,
        maxHeight: maxListHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: cardPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4A34A3).withOpacity(0.6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.0),
          bottomRight: Radius.circular(18.0),
        ),
        border: Border.all(color: const Color(0xFFFFEA00), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'LAST QUESTIONS ASKED:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize * 0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasScrollableContent) ...[
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.5),
                  size: fontSize,
                ),
                Text(
                  'scroll',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: fontSize * 0.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: cardPadding * 0.5),
          Flexible(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: hasScrollableContent
                      ? [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ]
                      : [Colors.white, Colors.white],
                  stops: hasScrollableContent
                      ? [0.0, 0.7, 0.9, 1.0]
                      : [0.0, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (gameState.currentRoundQuestions.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: cardPadding * 0.75,
                          horizontal: cardPadding * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white.withOpacity(0.4),
                              size: fontSize * 0.9,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No questions yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: fontSize * 0.8,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...gameState.currentRoundQuestions.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final q = entry.value;
                        final answerColor = q.answer
                            ? const Color(0xFF74E67C)
                            : const Color(0xFFE63C3D);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.text,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize * 0.8,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: answerColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  q.answer ? 'YES' : 'NO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
          ),
        ],
      ),
    );

    // Build ASK button with Animated Border explicitly
    Widget askButton = SizedBox(
      height: buttonHeight,
      child: Tooltip(
        message: canAsk ? 'Ask a question' : 'No questions left',
        child: AnimatedBuilder(
          animation: _askButtonFlashController,
          builder: (context, child) {
            final isFlashing = _askButtonFlashController.isAnimating;
            final flashValue = _askButtonFlashController.value;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                boxShadow: isFlashing && canAsk
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF74E67C,
                          ).withOpacity(flashValue * 0.5),
                          blurRadius: 15 * flashValue,
                          spreadRadius: 2 * flashValue,
                        ),
                      ]
                    : [],
              ),
              child: RainbowEdgeLighting(
                radius: buttonHeight / 2,
                thickness: 4.0,
                enabled: isFlashing && canAsk,
                speed: 1.5,
                clip: true,
                child: ElevatedButton(
                  onPressed: canAsk
                      ? () {
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
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'ASK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Build GUESS button
    Widget guessButton = Container(
      height: buttonHeight,
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
        borderRadius: BorderRadius.circular(buttonHeight / 2),
      ),
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: () async {
          AudioService().playButtonClick();
          final isPartyMode =
              context.read<GameProvider>().gameState.settings.gameMode ==
              GameMode.partyMode;

          if (isPartyMode) {
            context.read<GameProvider>().pauseTimer();
          }

          await showDialog(
            context: context,
            builder: (context) => const GuessDialog(),
          );

          if (isPartyMode && context.mounted) {
            context.read<GameProvider>().resumeTimer();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(232, 255, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 0,
        ),
        child: Text(
          'GUESS',
          style: TextStyle(
            color: Colors.white,
            fontSize: buttonFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Phone layout: vertical column
    if (isPhone) {
      return Container(
        width: panelWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            playerBadge,
            questionsCard,
            SizedBox(height: cardPadding),
            Row(
              children: [
                if (!allQuestionsUsed) ...[
                  Expanded(child: askButton),
                  SizedBox(width: cardPadding),
                ],
                Expanded(child: guessButton),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Anyone can guess!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: fontSize * 0.75,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Larger screens: horizontal layout
    return Container(
      width: panelWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [playerBadge, questionsCard],
            ),
          ),
          SizedBox(width: cardPadding),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: cardPadding),
                if (!allQuestionsUsed) ...[
                  askButton,
                  SizedBox(height: cardPadding * 0.75),
                ],
                guessButton,
                SizedBox(height: 8),
                Text(
                  'Anyone can guess!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: fontSize * 0.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
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

    // Responsive values matching party mode panel
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

    final buttonHeight = Responsive.value<double>(
      context,
      phone: 44,
      tablet: 50,
      laptop: 56,
      desktop: 60,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 18,
      laptop: 20,
      desktop: 22,
    );

    final isPhone = Responsive.isPhone(context);

    // Build the questions card
    final hasScrollableContent = gameState.currentRoundQuestions.length > 2;

    // Dynamic height based on screen height and aspect ratio
    // Reduce heights on wide screens (aspect ratio >= 2:1) to prevent overflow
    final aspectRatio = screenWidth / screenHeight;
    final heightMultiplier = aspectRatio >= 2.0
        ? 1.0 // Increased from 0.5 to match party mode logic
        : (aspectRatio >= 1.5 ? 1.9 : 1.0); // Increased logic

    // Adjusted min/max heights to be consistent with party mode but accounted for lack of badge
    final minListHeight = (screenHeight * 0.12 * heightMultiplier).clamp(
      80.0,
      150.0,
    );
    final maxListHeight = (screenHeight * 0.25 * heightMultiplier).clamp(
      120.0,
      300.0,
    );

    Widget questionsCard = Container(
      constraints: BoxConstraints(
        minHeight: minListHeight,
        maxHeight: maxListHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: cardPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4A34A3).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFFFEA00),
          width: 3,
        ), // Thinner border match
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
              if (hasScrollableContent) ...[
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.5),
                  size: fontSize,
                ),
                Text(
                  'scroll',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: fontSize * 0.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: cardPadding * 0.75),
          Flexible(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: hasScrollableContent
                      ? [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ]
                      : [Colors.white, Colors.white],
                  stops: hasScrollableContent
                      ? [0.0, 0.7, 0.9, 1.0]
                      : [0.0, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (gameState.currentRoundQuestions.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: cardPadding,
                          horizontal: cardPadding * 0.75,
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
                              size: fontSize,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No questions asked yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: fontSize * 0.85,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...gameState.currentRoundQuestions.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final q = entry.value;
                        final answerColor = q.answer
                            ? const Color(0xFF74E67C)
                            : const Color(0xFFE63C3D);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.symmetric(
                            vertical: cardPadding * 0.5,
                            horizontal: cardPadding * 0.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: answerColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Number bubble
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
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
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Question text
                              Expanded(
                                child: Text(
                                  q.text,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize * 0.85,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Answer badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: answerColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  q.answer ? 'YES' : 'NO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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
          ),
        ],
      ),
    );

    // Build the buttons
    Widget askButton = SizedBox(
      height: buttonHeight,
      child: Tooltip(
        message: canAsk
            ? 'Ask a question about the landmark'
            : 'You have used all your questions',
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
              borderRadius: BorderRadius.circular(buttonHeight / 2),
            ),
            elevation: 2,
          ),
          child: Text(
            'ASK',
            style: TextStyle(
              color: Colors.white,
              fontSize: buttonFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    Widget guessButton = Container(
      height: buttonHeight,
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
        borderRadius: BorderRadius.circular(buttonHeight / 2),
      ),
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: () async {
          AudioService().playButtonClick();
          final isPartyMode =
              context.read<GameProvider>().gameState.settings.gameMode ==
              GameMode.partyMode;

          if (isPartyMode) {
            context.read<GameProvider>().pauseTimer();
          }

          await showDialog(
            context: context,
            builder: (context) => const GuessDialog(),
          );

          if (isPartyMode && context.mounted) {
            context.read<GameProvider>().resumeTimer();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(232, 255, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 0,
        ),
        child: Text(
          'GUESS',
          style: TextStyle(
            color: Colors.white,
            fontSize: buttonFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // On phones: vertical layout (buttons below questions)
    // On larger screens: horizontal layout (buttons to the right)
    if (isPhone) {
      return Container(
        width: panelWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            questionsCard,
            SizedBox(height: cardPadding),
            Row(
              children: [
                Expanded(child: askButton),
                SizedBox(width: cardPadding),
                Expanded(child: guessButton),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: panelWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: questionsCard),
            SizedBox(width: cardPadding),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Added small top spacing to align visually with card internal padding
                  SizedBox(height: 0),
                  askButton,
                  SizedBox(height: cardPadding),
                  guessButton,
                ],
              ),
            ),
          ],
        ),
      );
    }
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
                    builder: (context) {
                      final gameProvider = this.context.read<GameProvider>();
                      final pending = gameProvider.nextRoundSettings;
                      final current = gameProvider.gameState.settings;
                      return GameSettingsDialog(
                        isOnlineMode: false,
                        isHost: true,
                        initialTimerEnabled:
                            pending?.isTimerEnabled ?? current.isTimerEnabled,
                        initialTimerDuration:
                            pending?.turnDurationSeconds ??
                            current.turnDurationSeconds,
                        onTimerSettingsChanged: (enabled, duration) {
                          final updated = GameSettings(
                            gameMode: current.gameMode,
                            difficulty: current.difficulty,
                            numberOfRounds: current.numberOfRounds,
                            questionsPerPlayer: current.questionsPerPlayer,
                            turnDurationSeconds: duration,
                            isTimerEnabled: enabled,
                          );
                          gameProvider.updateNextRoundSettings(updated);
                        },
                        onQuitToMenu: () {
                          AudioService().stopMusic();
                          this.context.read<GameProvider>().resetGame();
                          Navigator.of(this.context).pushReplacementNamed('/');
                        },
                      );
                    },
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

    Widget imageWidget = Container(
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

                      // frameBuilder works better for showing a loading overlay even if cached
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            final bool isLoaded =
                                frame != null || wasSynchronouslyLoaded;

                            if (isLoaded) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  context.read<GameProvider>().onImageLoaded();
                                }
                              });
                            }

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
                  // Tap hint overlay
                  if (gameState.currentLandmark != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.zoom_in,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'TAP TO ZOOM',
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
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

    return GestureDetector(
      onTap: () {
        if (gameState.currentLandmark != null) {
          _openFullScreenImage(context, gameState.currentLandmark!.imagePath);
        }
      },
      child: imageWidget,
    );
  }

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    int rotationQuarter = 0;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Stack(
                    children: [
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isRotated = rotationQuarter == 1;
                              final screenWidth = constraints.maxWidth;
                              final screenHeight = constraints.maxHeight;

                              Widget imgWidget = Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: isRotated ? screenHeight : null,
                                height: isRotated ? screenWidth : null,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: const Color(0xFF74E67C),
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                              );

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isRotated
                                    ? RotatedBox(
                                        key: const ValueKey('rotated'),
                                        quarterTurns: 1,
                                        child: SizedBox(
                                          width: screenHeight,
                                          height: screenWidth,
                                          child: imgWidget,
                                        ),
                                      )
                                    : SizedBox(
                                        key: const ValueKey('normal'),
                                        width: screenWidth,
                                        height: screenHeight,
                                        child: imgWidget,
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Top buttons row
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  rotationQuarter = rotationQuarter == 0
                                      ? 1
                                      : 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.rotate_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Zoom hint
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Pinch to zoom • Double-tap to reset',
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Removed legacy separate sections in favor of combined panel
}
