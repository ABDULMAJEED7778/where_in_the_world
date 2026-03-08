import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/online_game_models.dart';
import '../providers/online_game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/visual_feedback_overlay.dart';
import '../widgets/online_guess_dialog.dart';
import '../widgets/question_display_overlay.dart';
import '../widgets/game_settings_dialog.dart';
import '../widgets/online/online_game_header.dart';
import '../widgets/online/online_game_info_bar.dart';
import '../widgets/online/online_landmark_image.dart';
import '../widgets/online/online_turn_indicator.dart';
import '../widgets/online/online_questions_list.dart';
import '../widgets/online/online_interaction_area.dart';
import '../widgets/online/online_guess_button.dart';
import '../widgets/online/online_round_over_view.dart';
import '../widgets/online/online_game_ended_view.dart';
import '../widgets/online/online_scores_dialog.dart';
import '../widgets/online/online_lobby_view.dart';
import '../widgets/online/online_debug_panel.dart';

/// Main game screen for online multiplayer.
/// Thin orchestrator that delegates rendering to extracted widget files.
class OnlineGameScreen extends StatefulWidget {
  final String roomCode;

  const OnlineGameScreen({super.key, required this.roomCode});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late OnlineGameProvider _provider;
  DateTime _lastSync = DateTime.now();
  bool _showDebug = false;

  // State tracking for notifications
  Set<String> _knownGuessedIds = {};
  int _currentRound = 1;

  // Question overlay state
  int _lastKnownQuestionCount = 0;
  OnlineQuestion? _questionToShow;
  bool _showQuestionOverlay = false;

  @override
  void initState() {
    super.initState();
    print('🎨 OnlineGameScreen: initState for room ${widget.roomCode}');
    _provider = OnlineGameProvider();
    _provider.addListener(_onGameUpdate);
    _initGame();
  }

  Future<void> _initGame() async {
    try {
      print('🎨 OnlineGameScreen: Calling initializeRoom...');
      await _provider.initializeRoom(widget.roomCode);
      print('🎨 OnlineGameScreen: Initialization complete');
    } catch (e) {
      print('❌ OnlineGameScreen: _initGame failed: $e');
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onGameUpdate);
    _provider.dispose();
    super.dispose();
  }

  void _onGameUpdate() {
    if (!mounted) return;

    // Reset tracking on round change
    if (_provider.currentRound != _currentRound) {
      _currentRound = _provider.currentRound;
      _knownGuessedIds.clear();
      _lastKnownQuestionCount = 0;
    }

    // Check for new questions and show overlay
    final questions = _provider.questions;
    if (questions.length > _lastKnownQuestionCount && questions.isNotEmpty) {
      final newQuestion = questions.last;
      _lastKnownQuestionCount = questions.length;

      setState(() {
        _questionToShow = newQuestion;
        _showQuestionOverlay = true;
      });
    }

    // Check for new guesses
    final guesses = _provider.gameState?.playerGuesses;
    final currentLandmark = _provider.currentLandmark;
    if (guesses != null && currentLandmark != null) {
      for (final entry in guesses.entries) {
        final id = entry.key;
        final guessValue = entry.value;

        if (!_knownGuessedIds.contains(id)) {
          _knownGuessedIds.add(id);

          if (id != _provider.currentPlayerId &&
              _provider.currentPlayerId != null) {
            final player = _provider.players.firstWhere(
              (p) => p.id == id,
              orElse: () =>
                  OnlinePlayer(id: id, nickname: 'A player', isHost: false),
            );

            final isCorrect =
                guessValue.toLowerCase() ==
                currentLandmark.country.toLowerCase();

            _showGameSnackBar(
              "${player.nickname.toUpperCase()} GUESSED ${isCorrect ? 'CORRECTLY!' : 'INCORRECTLY!'}",
              icon: isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.not_interested_rounded,
              isError: !isCorrect,
            );
          }
        }
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<OnlineGameProvider>(
        builder: (context, provider, _) {
          return WillPopScope(
            onWillPop: () async {
              await _showLeaveDialog();
              return false;
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF2D1B69),
              body: VisualFeedbackOverlay(
                eventStream: provider.events,
                child: Stack(
                  children: [
                    const AnimatedBackground(),
                    SafeArea(child: _buildContent(provider)),
                    if (_showDebug)
                      OnlineDebugPanel(
                        provider: provider,
                        roomCode: widget.roomCode,
                        lastSync: _lastSync,
                      ),
                    if (_showQuestionOverlay && _questionToShow != null)
                      QuestionDisplayOverlay(
                        question: _questionToShow!.text,
                        answer: _questionToShow!.answer,
                        askedBy: _questionToShow!.askedByName,
                        onDismiss: () {
                          if (mounted) {
                            setState(() => _showQuestionOverlay = false);
                          }
                        },
                      ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.small(
                onPressed: () => setState(() => _showDebug = !_showDebug),
                backgroundColor: Colors.black45,
                child: Icon(
                  _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
                  color: Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(OnlineGameProvider provider) {
    if (provider.isLoading || !provider.initialized || provider.room == null) {
      return _buildLoadingState();
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    print(
      '🎨 OnlineGameScreen: Rendering status=${provider.status.name} (Players: ${provider.players.length})',
    );
    _lastSync = DateTime.now();

    switch (provider.status) {
      case OnlineGameStatus.lobby:
        return OnlineLobbyView(
          roomCode: widget.roomCode,
          playerCount: provider.players.length,
          isHost: provider.isHost,
          onStartGame: () => provider.startGame(),
          headerWidget: _buildHeader(provider),
        );
      case OnlineGameStatus.playing:
        return _buildPlayingState(provider);
      case OnlineGameStatus.roundOver:
        return OnlineRoundOverView(
          provider: provider,
          onShowScores: () => _showScoresDialog(provider),
          onNextRound: () => provider.proceedToNextRound(),
        );
      case OnlineGameStatus.gameEnded:
        return OnlineGameEndedView(
          provider: provider,
          onLeaveGame: () => provider.leaveGame(),
        );
    }
  }

  // ─── Simple states ────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF74E67C)),
          const SizedBox(height: 20),
          Text(
            'Loading game...',
            style: GoogleFonts.hanaleiFill(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: GoogleFonts.hanaleiFill(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Playing state layouts ────────────────────────────────────────

  Widget _buildHeader(OnlineGameProvider provider) {
    return OnlineGameHeader(
      currentRound: provider.currentRound,
      totalRounds: provider.totalRounds,
      onBack: _showLeaveDialog,
      onShowScores: () => _showScoresDialog(provider),
      onShowSettings: _showSettingsDialog,
    );
  }

  Widget _buildPlayingState(OnlineGameProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / screenHeight;
    final isWideScreen = screenWidth > 900 && aspectRatio > 1;
    final maxContentWidth = screenWidth * 0.9;

    if (isWideScreen) {
      return Column(
        children: [
          _buildHeader(provider),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: _buildWidePlayingLayout(provider),
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _buildMobilePlayingLayout(provider),
      ),
    );
  }

  Widget _buildMobilePlayingLayout(OnlineGameProvider provider) {
    final screenHeight = MediaQuery.of(context).size.height;

    final gameInfoBar = _buildGameInfoBar(provider);
    final landmarkImage = OnlineLandmarkImage(
      imageUrl: provider.currentLandmark!.imagePath,
    );
    final turnIndicator = _buildTurnIndicator(provider);
    final questionsList = OnlineQuestionsList(questions: provider.questions);
    final interactionArea = _buildInteractionArea(provider);
    final guessButton = _buildGuessButton(provider);

    if (screenHeight < 700) {
      return Column(
        children: [
          _buildHeader(provider),
          gameInfoBar,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  landmarkImage,
                  const SizedBox(height: 16),
                  turnIndicator,
                  const SizedBox(height: 16),
                  questionsList,
                  const SizedBox(height: 16),
                  interactionArea,
                  guessButton,
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHeader(provider),
        gameInfoBar,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                landmarkImage,
                const SizedBox(height: 16),
                turnIndicator,
                const SizedBox(height: 16),
                questionsList,
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [interactionArea, guessButton],
          ),
        ),
      ],
    );
  }

  Widget _buildWidePlayingLayout(OnlineGameProvider provider) {
    final gameInfoBar = _buildGameInfoBar(provider);
    final landmarkImage = OnlineLandmarkImage(
      imageUrl: provider.currentLandmark!.imagePath,
      isWide: true,
    );
    final turnIndicator = _buildTurnIndicator(provider);
    final questionsList = OnlineQuestionsList(questions: provider.questions);
    final interactionArea = _buildInteractionArea(provider);
    final guessButton = _buildGuessButton(provider);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 70,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxImageHeight = constraints.maxHeight - 180;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            gameInfoBar,
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxImageHeight > 200
                                    ? maxImageHeight
                                    : 200,
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: landmarkImage,
                              ),
                            ),
                            const SizedBox(height: 24),
                            turnIndicator,
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 30,
                  child: Column(
                    children: [
                      Expanded(child: questionsList),
                      const SizedBox(height: 16),
                      interactionArea,
                      guessButton,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Sub-widget builders (thin wrappers) ──────────────────────────

  Widget _buildGameInfoBar(OnlineGameProvider provider) {
    final playersRemaining = provider.players
        .where((p) => !provider.hasGuessed(p.id))
        .length;

    return OnlineGameInfoBar(
      difficulty: provider.gameState?.difficulty ?? 1,
      questionsPerTurn: provider.questionsPerTurn,
      playersRemaining: playersRemaining,
      totalPlayers: provider.players.length,
    );
  }

  Widget _buildTurnIndicator(OnlineGameProvider provider) {
    final questionsLimit = provider.questionsPerTurn;
    final playersWhoCanAsk = provider.players
        .where((p) => !provider.hasGuessed(p.id))
        .toList();

    bool allQuestionsUsed = true;
    for (final player in playersWhoCanAsk) {
      final playerQuestions = provider.questions
          .where((q) => q.askedBy == player.id)
          .length;
      if (playerQuestions < questionsLimit) {
        allQuestionsUsed = false;
        break;
      }
    }

    final currentId = provider.gameState?.currentPlayerId;
    final int currentQuestionsAsked = provider.questions
        .where((q) => q.askedBy == currentId)
        .length;
    final int questionsRemaining = (questionsLimit - currentQuestionsAsked)
        .clamp(0, 99);

    return OnlineTurnIndicator(
      currentPlayerName: provider.currentTurnPlayer?.nickname,
      isMyTurn: provider.isMyTurn,
      allQuestionsUsed: allQuestionsUsed,
      questionsRemaining: questionsRemaining,
      timeRemaining: provider.timeRemaining,
      isImageLoaded: provider.isImageLoaded,
      isTimerEnabled: provider.gameState?.isTimerEnabled ?? true,
    );
  }

  Widget _buildInteractionArea(OnlineGameProvider provider) {
    final myId = provider.currentPlayerId;
    final myQuestionsAsked = provider.questions
        .where((q) => q.askedBy == myId)
        .length;
    final questionsLimit = provider.questionsPerTurn;

    return OnlineInteractionArea(
      isMyTurn: provider.isMyTurn,
      canAskMore: myQuestionsAsked < questionsLimit,
      questionsLimit: questionsLimit,
      timeRemaining: provider.timeRemaining,
      turnDurationSeconds: 60,
      onAskQuestion: (question) => _provider.askQuestion(question),
    );
  }

  Widget _buildGuessButton(OnlineGameProvider provider) {
    final myId = provider.currentPlayerId;
    final hasGuessed = myId != null && provider.hasGuessed(myId);

    return OnlineGuessButton(
      hasGuessed: hasGuessed,
      onGuess: () {
        AudioService().playButtonClick();
        _showGuessDialog(provider);
      },
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────

  Future<void> _showLeaveDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B69),
        title: Text(
          'Leave Game?',
          style: GoogleFonts.hanaleiFill(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave the game?',
          style: GoogleFonts.hanaleiFill(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Stay', style: GoogleFonts.hanaleiFill()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Leave',
              style: GoogleFonts.hanaleiFill(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _provider.leaveGame();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _showScoresDialog(OnlineGameProvider provider) {
    OnlineScoresDialog.show(context, provider.players);
  }

  void _showGuessDialog(OnlineGameProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: provider,
        child: OnlineGuessDialog(roomCode: widget.roomCode),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => GameSettingsDialog(
        isOnlineMode: true,
        isHost: _provider.isHost,
        initialTimerEnabled: _provider.gameState?.nextRoundTimerEnabled ?? true,
        initialTimerDuration: _provider.gameState?.nextRoundTurnDuration ?? 60,
        onTimerSettingsChanged: (enabled, duration) {
          _provider.updateNextRoundTimerSettings(enabled, duration);
        },
        onQuitToMenu: () {
          Navigator.of(context).pop();
          Navigator.of(this.context).pop();
        },
      ),
    );
  }

  // ─── Snackbar ─────────────────────────────────────────────────────

  void _showGameSnackBar(
    String message, {
    IconData icon = Icons.info_outline,
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isError
                  ? [
                      Colors.red.withOpacity(0.9),
                      Colors.redAccent.withOpacity(0.7),
                    ]
                  : [
                      const Color(0xFF74E67C).withOpacity(0.9),
                      const Color(0xFF4CAF50).withOpacity(0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.red : const Color(0xFF74E67C))
                    .withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          left: 20,
          right: 20,
        ),
      ),
    );
  }
}
