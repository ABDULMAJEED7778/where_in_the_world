import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';
import '../models/online_game_models.dart';
import '../providers/online_game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/visual_feedback_overlay.dart';
import '../widgets/online_guess_dialog.dart';
import '../widgets/question_display_overlay.dart';
import '../widgets/game_settings_dialog.dart';

/// Main game screen for online multiplayer
class OnlineGameScreen extends StatefulWidget {
  final String roomCode;

  const OnlineGameScreen({super.key, required this.roomCode});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late OnlineGameProvider _provider;
  final TextEditingController _questionController = TextEditingController();
  DateTime _lastSync = DateTime.now();
  bool _showDebug = false;
  String? _questionError;

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
    _questionController.dispose();
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

      // Show overlay for the new question
      setState(() {
        _questionToShow = newQuestion;
        _showQuestionOverlay = true;
      });
    }

    // Check for new guesses
    final guesses = _provider.gameState?.playerGuesses;
    if (guesses != null) {
      for (final id in guesses.keys) {
        if (!_knownGuessedIds.contains(id)) {
          _knownGuessedIds.add(id);

          if (id != _provider.currentPlayerId &&
              _provider.currentPlayerId != null) {
            final player = _provider.players.firstWhere(
              (p) => p.id == id,
              orElse: () =>
                  OnlinePlayer(id: id, nickname: 'A player', isHost: false),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.person_off, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "${player.nickname.toUpperCase()} guessed incorrectly!",
                    ),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

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
                    if (_showDebug) _buildDebugPanel(provider),
                    // Question overlay
                    if (_showQuestionOverlay && _questionToShow != null)
                      QuestionDisplayOverlay(
                        question: _questionToShow!.text,
                        answer: _questionToShow!.answer,
                        askedBy: _questionToShow!.askedByName,
                        onDismiss: () {
                          if (mounted) {
                            setState(() {
                              _showQuestionOverlay = false;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.small(
                onPressed: () {
                  setState(() => _showDebug = !_showDebug);
                },
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
    // Show loading until we have actual room data
    if (provider.isLoading || !provider.initialized || provider.room == null) {
      return _buildLoadingState();
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    // Log current status for debugging
    print(
      '🎨 OnlineGameScreen: Rendering status=${provider.status.name} (Players: ${provider.players.length})',
    );
    _lastSync = DateTime.now();

    switch (provider.status) {
      case OnlineGameStatus.lobby:
        return _buildLobbyState(provider);
      case OnlineGameStatus.playing:
        return _buildPlayingState(provider);
      case OnlineGameStatus.roundOver:
        return _buildRoundOverState(provider);
      case OnlineGameStatus.gameEnded:
        return _buildGameEndedState(provider);
    }
  }

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

  Widget _buildLobbyState(OnlineGameProvider provider) {
    return Column(
      children: [
        _buildHeader(provider),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WAITING FOR HOST',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Room: ${widget.roomCode}',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: 18,
                    color: const Color(0xFF74E67C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.players.length} players',
                  style: GoogleFonts.hanaleiFill(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                if (provider.isHost)
                  ElevatedButton(
                    onPressed: provider.players.length >= 2
                        ? () => provider.startGame()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74E67C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'START GAME',
                      style: GoogleFonts.hanaleiFill(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(color: Color(0xFFFFEA00)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayingState(OnlineGameProvider provider) {
    return Column(
      children: [
        _buildHeader(provider),
        _buildOnlineGameInfo(provider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Landmark Image or loading
                if (provider.currentLandmark != null)
                  _buildLandmarkImage(provider)
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF74E67C)),
                          SizedBox(height: 8),
                          Text(
                            'Loading image...',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Turn indicator
                _buildTurnIndicator(provider),
                const SizedBox(height: 16),

                // Questions list
                _buildQuestionsList(provider),
                const SizedBox(height: 16),

                // Interaction area (Ask + Guess)
                _buildInteractionArea(provider),

                _buildGuessButton(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(OnlineGameProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _showLeaveDialog,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'ROUND ${provider.currentRound}/${provider.totalRounds}',
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(fontSize: 20, color: Colors.white),
            ),
          ),
          // Scores button
          IconButton(
            onPressed: () => _showScoresDialog(provider),
            icon: const Icon(Icons.leaderboard, color: Colors.white),
          ),
          // Settings button
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineGameInfo(OnlineGameProvider provider) {
    final difficulty = provider.gameState?.difficulty ?? 1;
    final questionsPerTurn = provider.questionsPerTurn;
    final playersRemaining = provider.players
        .where((p) => !provider.hasGuessed(p.id))
        .length;
    final totalPlayers = provider.players.length;

    Color difficultyColor;
    String difficultyText;
    switch (difficulty) {
      case 1:
        difficultyColor = const Color(0xFF74E67C);
        difficultyText = 'EASY';
        break;
      case 2:
        difficultyColor = const Color(0xFFF3D42B);
        difficultyText = 'MODERATE';
        break;
      case 3:
        difficultyColor = const Color(0xFFE63C3D);
        difficultyText = 'HARD';
        break;
      default:
        difficultyColor = const Color(0xFF74E67C);
        difficultyText = 'EASY';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Difficulty Badge
          _buildInfoBadge(
            icon: Icons.speed,
            label: difficultyText,
            color: difficultyColor,
          ),

          // Divider
          Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2)),

          // Questions per Turn
          _buildInfoBadge(
            icon: Icons.help_outline,
            label: '$questionsPerTurn Q/TURN',
            color: const Color(0xFFFFEA00),
          ),

          // Divider
          Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2)),

          // Players Remaining
          _buildInfoBadge(
            icon: Icons.people,
            label: '$playersRemaining/$totalPlayers',
            color: const Color(0xFF5BC0EB),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.hanaleiFill(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLandmarkImage(OnlineGameProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.9; // Use 90% of screen width

    return Container(
      width: imageWidth,
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
              clip: true,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    provider.currentLandmark!.imagePath,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          final bool isLoaded =
                              frame != null || wasSynchronouslyLoaded;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              child,
                              if (!isLoaded)
                                Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Lottie.asset(
                                      'assets/lotties/Camera.json',
                                      width: imageWidth / 4,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Center(
                          child: Lottie.asset(
                            'assets/lotties/Camera.json',
                            width: imageWidth / 4,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(OnlineGameProvider provider) {
    final currentPlayer = provider.currentTurnPlayer;
    final isMyTurn = provider.isMyTurn;
    final questionsLimit = provider.questionsPerTurn;

    // Check if all players have used all their questions
    // Each player who hasn't guessed can have up to questionsLimit questions
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

    // If all questions are used, show guess-time indicator
    if (allQuestionsUsed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE63C3D).withOpacity(0.3),
              const Color(0xFFE63C3D).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE63C3D), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFFFEA00)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "NO QUESTIONS LEFT!",
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Time to make your guess",
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMyTurn
            ? const Color(0xFF74E67C).withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isMyTurn
            ? Border.all(color: const Color(0xFF74E67C), width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMyTurn ? Icons.person : Icons.hourglass_top,
            color: isMyTurn ? const Color(0xFF74E67C) : Colors.white54,
          ),
          const SizedBox(width: 8),
          Text(
            isMyTurn
                ? "IT'S YOUR TURN!"
                : "${currentPlayer?.nickname ?? 'Someone'}'s turn",
            style: GoogleFonts.hanaleiFill(
              color: isMyTurn ? const Color(0xFF74E67C) : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(OnlineGameProvider provider) {
    final questions = provider.questions;

    if (questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withOpacity(0.3),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No questions asked yet',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ask yes/no questions to narrow down the country!',
              style: GoogleFonts.hanaleiFill(color: Colors.white24),
              maxLines: 1,
              textScaler: TextScaler.linear(0.8),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEA00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Color(0xFFFFEA00),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'QUESTIONS',
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${questions.length}',
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Questions
          ...questions.asMap().entries.map(
            (entry) => _buildQuestionTile(entry.value, entry.key + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(OnlineQuestion question, int number) {
    final isYes = question.answer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYes
              ? const Color(0xFF74E67C).withOpacity(0.3)
              : const Color(0xFFE63C3D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Question number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Question content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text,
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Asked by ${question.askedByName}',
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Answer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isYes
                    ? [const Color(0xFF74E67C), const Color(0xFF4CAF50)]
                    : [const Color(0xFFE63C3D), const Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isYes
                      ? const Color(0xFF74E67C).withOpacity(0.4)
                      : const Color(0xFFE63C3D).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isYes ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isYes ? 'YES' : 'NO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionArea(OnlineGameProvider provider) {
    // Count how many questions the current player has asked this round
    final myId = provider.currentPlayerId;
    final myQuestionsAsked = provider.questions
        .where((q) => q.askedBy == myId)
        .length;
    final questionsLimit = provider.questionsPerTurn;
    final canAskMore = myQuestionsAsked < questionsLimit;

    return Column(
      children: [
        // Ask Question Section (Only if my turn AND haven't reached limit)
        if (provider.isMyTurn && canAskMore) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF74E67C).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  style: GoogleFonts.hanaleiFill(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask a yes/no question...',
                    hintStyle: GoogleFonts.hanaleiFill(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF74E67C)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                // Error message display
                if (_questionError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _questionError!,
                            style: GoogleFonts.hanaleiFill(
                              color: Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // ASK Button - Green with rounded corners like offline mode
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_questionController.text.isNotEmpty) {
                        final validationError = _validateQuestion(
                          _questionController.text.trim(),
                        );
                        if (validationError != null) {
                          setState(() {
                            _questionError = validationError;
                          });
                          return;
                        }
                        setState(() {
                          _questionError = null;
                        });
                        AudioService().playSecondaryButtonClick();
                        _provider.askQuestion(_questionController.text);
                        _questionController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74E67C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 2,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Stroke text
                        Text(
                          'ASK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        // Fill text
                        const Text(
                          'ASK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Show message when player has used all their questions
        if (provider.isMyTurn && !canAskMore) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEA00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFEA00).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFFEA00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You've used all $questionsLimit questions",
                        style: GoogleFonts.hanaleiFill(
                          color: const Color(0xFFFFEA00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Make a guess or wait for others',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildGuessButton(OnlineGameProvider provider) {
    final myId = provider.currentPlayerId;
    // Check if *I* have guessed
    final bool iHaveGuessed = myId != null && provider.hasGuessed(myId);

    // Check if *I* am the asker
    final bool iAmAsker =
        myId != null && provider.currentTurnPlayer?.id == myId;

    if (iHaveGuessed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.close, color: Colors.red, size: 24),
            const SizedBox(height: 8),
            Text(
              'You guessed incorrectly',
              style: GoogleFonts.hanaleiFill(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Wait for round end',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          AudioService().playButtonClick();
          _showGuessDialog(provider);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63C3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 4,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Stroke text
            Text(
              'GUESS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            // Fill text
            const Text(
              'GUESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Waiting for asker indicator (only if not my turn)

  Widget _buildRoundOverState(OnlineGameProvider provider) {
    final correctAnswer = provider.currentLandmark?.country ?? 'Unknown';
    final winnerId = provider.gameState?.lastRoundWinnerId;
    final reason = provider.gameState?.lastRoundWinReason;
    final winner = winnerId != null
        ? provider.players.firstWhere(
            (p) => p.id == winnerId,
            orElse: () =>
                OnlinePlayer(id: 'unknown', nickname: 'Unknown', isHost: false),
          )
        : null;

    return Column(
      children: [
        _buildHeader(provider),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Winner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: winner != null
                            ? [
                                const Color(0xFFFFEA00).withOpacity(0.2),
                                const Color(0xFFFFEA00).withOpacity(0.05),
                              ]
                            : [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: winner != null
                            ? const Color(0xFFFFEA00).withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: winner != null
                              ? const Color(0xFFFFEA00).withOpacity(0.15)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (winner != null) ...[
                          // Trophy icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEA00).withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFEA00),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFEA00,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Color(0xFFFFEA00),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Win reason
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: reason == 'correct'
                                    ? [
                                        const Color(0xFF74E67C),
                                        const Color(0xFF4CAF50),
                                      ]
                                    : [
                                        const Color(0xFF5BC0EB),
                                        const Color(0xFF3498DB),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (reason == 'correct'
                                              ? const Color(0xFF74E67C)
                                              : const Color(0xFF5BC0EB))
                                          .withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              reason == 'correct'
                                  ? 'CORRECT GUESS!'
                                  : 'NEAREST GUESS!',
                              style: GoogleFonts.hanaleiFill(
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Winner name
                          Text(
                            winner.nickname.toUpperCase(),
                            style: GoogleFonts.hanaleiFill(
                              fontSize: 32,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          if (reason == 'nearest')
                            Text(
                              '+5 POINTS',
                              style: GoogleFonts.hanaleiFill(
                                fontSize: 16,
                                color: const Color(0xFFFFEA00),
                              ),
                            ),
                        ] else ...[
                          // No winner - round over
                          const Icon(
                            Icons.timer_off,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ROUND OVER',
                            style: GoogleFonts.hanaleiFill(
                              fontSize: 32,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF74E67C).withOpacity(0.15),
                          const Color(0xFF74E67C).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF74E67C).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'THE ANSWER WAS',
                          style: GoogleFonts.hanaleiFill(
                            fontSize: 14,
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          correctAnswer.toUpperCase(),
                          style: GoogleFonts.hanaleiFill(
                            fontSize: 28,
                            color: const Color(0xFF74E67C),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next Round Button or Waiting
                  if (provider.isHost)
                    ElevatedButton(
                      onPressed: () => provider.proceedToNextRound(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEA00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFFEA00).withOpacity(0.5),
                      ),
                      child: Text(
                        provider.currentRound < provider.totalRounds
                            ? 'NEXT ROUND'
                            : 'SEE RESULTS',
                        style: GoogleFonts.hanaleiFill(
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'WAITING FOR HOST...',
                            style: GoogleFonts.hanaleiFill(
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameEndedState(OnlineGameProvider provider) {
    final winner = provider.winner;
    // Sort players by score for final leaderboard
    final sortedPlayers = List<OnlinePlayer>.from(provider.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      children: [
        _buildHeader(provider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Game Over Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFEA00).withOpacity(0.25),
                        const Color(0xFFFFEA00).withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFEA00).withOpacity(0.6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFEA00).withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Trophy with glow
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEA00).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFEA00),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFEA00).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFEA00),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GAME OVER',
                        style: GoogleFonts.hanaleiFill(
                          fontSize: 36,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      if (winner != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CHAMPION',
                            style: GoogleFonts.hanaleiFill(
                              fontSize: 14,
                              color: const Color(0xFFFFEA00),
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          winner.nickname.toUpperCase(),
                          style: GoogleFonts.hanaleiFill(
                            fontSize: 32,
                            color: const Color(0xFF74E67C),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            '${winner.score} POINTS',
                            style: GoogleFonts.hanaleiFill(
                              fontSize: 18,
                              color: Colors.black87,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Final Leaderboard
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'FINAL STANDINGS',
                        style: GoogleFonts.hanaleiFill(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...sortedPlayers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        final isFirst = index == 0;
                        final isSecond = index == 1;
                        final isThird = index == 2;
                        final isTopThree = index < 3;

                        final Color rankColor = isFirst
                            ? const Color(0xFFFFD700)
                            : isSecond
                            ? const Color(0xFFC0C0C0)
                            : isThird
                            ? const Color(0xFFCD7F32)
                            : Colors.white54;

                        final String medal = isFirst
                            ? '🥇'
                            : isSecond
                            ? '🥈'
                            : isThird
                            ? '🥉'
                            : '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                rankColor.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: isTopThree
                                ? Border.all(
                                    color: rankColor.withOpacity(0.5),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  isTopThree ? medal : '${index + 1}',
                                  style: GoogleFonts.hanaleiFill(
                                    fontSize: 18,
                                    color: rankColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.nickname.toUpperCase(),
                                  style: GoogleFonts.hanaleiFill(
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Text(
                                '${player.score}',
                                style: GoogleFonts.hanaleiFill(
                                  fontSize: 18,
                                  color: isTopThree
                                      ? rankColor
                                      : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Back to Menu Button
                ElevatedButton(
                  onPressed: () async {
                    await provider.leaveGame();
                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74E67C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF74E67C).withOpacity(0.5),
                  ),
                  child: Text(
                    'BACK TO MENU',
                    style: GoogleFonts.hanaleiFill(
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
    // Sort players by score in descending order
    final sortedPlayers = List<OnlinePlayer>.from(provider.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B69).withOpacity(0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFFFEA00).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFFEA00).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEA00).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFEA00),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFEA00),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'LEADERBOARD',
                      style: GoogleFonts.hanaleiFill(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Players List
                ...sortedPlayers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  final isFirst = index == 0;
                  final isSecond = index == 1;
                  final isThird = index == 2;
                  final isTopThree = index < 3;

                  final Color rankColor = isFirst
                      ? const Color(0xFFFFD700) // Gold
                      : isSecond
                      ? const Color(0xFFC0C0C0) // Silver
                      : isThird
                      ? const Color(0xFFCD7F32) // Bronze
                      : Colors.white70;

                  final String medalEmoji = isFirst
                      ? "🥇"
                      : isSecond
                      ? "🥈"
                      : isThird
                      ? "🥉"
                      : "";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          rankColor.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTopThree
                            ? rankColor.withOpacity(0.8)
                            : Colors.white24,
                        width: isTopThree ? 2 : 1,
                      ),
                      boxShadow: isTopThree
                          ? [
                              BoxShadow(
                                color: rankColor.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank Circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: rankColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              isTopThree ? medalEmoji : '${index + 1}',
                              style: TextStyle(
                                color: rankColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Player Name
                        Expanded(
                          child: Text(
                            player.nickname.toUpperCase(),
                            style: GoogleFonts.hanaleiFill(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: isTopThree
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        // Score
                        Text(
                          player.score.toString(),
                          style: GoogleFonts.hanaleiFill(
                            color: isTopThree ? rankColor : Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEA00),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFFEA00).withOpacity(0.5),
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.hanaleiFill(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        onQuitToMenu: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(this.context).pop(); // Leave game screen
        },
      ),
    );
  }

  Widget _buildDebugPanel(OnlineGameProvider provider) {
    return Positioned(
      bottom: 80,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛠 DEBUG INFO',
                  style: GoogleFonts.hanaleiFill(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    fontSize: 12,
                  ),
                ),
                InkWell(
                  onTap: () {
                    print('🔄 Manual Sync Triggered');
                    provider.initializeRoom(widget.roomCode);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: Colors.cyan, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'SYNC NOW',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Text(
              'Room: ${widget.roomCode}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'My ID: ${provider.currentPlayerId}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Turn ID: ${provider.gameState?.currentPlayerId}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Is My Turn: ${provider.isMyTurn}',
              style: GoogleFonts.hanaleiFill(
                color: provider.isMyTurn ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Step: ${provider.status.name}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Questions: ${provider.gameState?.questions.length ?? 0}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Last Update: ${_lastSync.hour}:${_lastSync.minute}:${_lastSync.second}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates if the question is acceptable
  /// Returns error message if invalid, null if valid
  String? _validateQuestion(String question) {
    final lowerQuestion = question.toLowerCase().trim();

    // Check for yes/no question indicators
    final yesNoIndicators = [
      'is ',
      'are ',
      'do ',
      'does ',
      'can ',
      'could ',
      'would ',
      'will ',
      'has ',
      'have ',
      'is the ',
      'are the ',
      'did ',
      'was ',
      'were ',
      'should ',
      'may ',
      'might ',
    ];

    final isYesNoQuestion = yesNoIndicators.any(
      (indicator) => lowerQuestion.startsWith(indicator),
    );

    if (!isYesNoQuestion) {
      return 'Ask a yes/no question (start with "Is", "Are", "Do", "Does", "Can", etc.)';
    }

    // Check for direct country guessing
    if (_isDirectCountryGuess(lowerQuestion)) {
      return 'Cannot ask about specific countries directly. Ask about geography, features, climate, or location instead.';
    }

    // Check for too-vague questions
    if (_isAmbiguousQuestion(lowerQuestion)) {
      return 'Question is too vague. Be more specific about what you\'re asking.';
    }

    // Check for questions that are too short
    final words = question.split(' ').where((w) => w.isNotEmpty).length;
    if (words < 3) {
      return 'Question is too short. Please provide more details.';
    }

    return null; // Question is valid
  }

  /// Check if the question is trying to guess a specific country
  bool _isDirectCountryGuess(String question) {
    final lowerQuestion = question.toLowerCase();

    // If it contains locational prepositions, it's likely a valid geography question
    if (lowerQuestion.contains(' in ') ||
        lowerQuestion.contains(' near ') ||
        lowerQuestion.contains(' on ') ||
        lowerQuestion.contains(' located ') ||
        lowerQuestion.contains(' part of ')) {
      return false;
    }

    final countryGuessPatterns = [
      RegExp(r'is\s+it\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+this\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+the\s+country\s+[a-z\s]+\??\s*$', caseSensitive: false),
    ];

    for (var pattern in countryGuessPatterns) {
      if (pattern.hasMatch(question)) {
        return true;
      }
    }

    return false;
  }

  /// Check for ambiguous or poorly formed questions
  bool _isAmbiguousQuestion(String question) {
    final lowerQuestion = question.toLowerCase();

    final vaguePhrases = [
      'is it?',
      'are they?',
      'do you?',
      'can it?',
      'what is it?',
      'who is it?',
      'where is it?',
      'when is it?',
      'why is it?',
      'how is it?',
    ];

    for (var phrase in vaguePhrases) {
      if (lowerQuestion.trim() == phrase) {
        return true;
      }
    }

    // Questions with multiple independent clauses
    final hasMultipleClauses =
        lowerQuestion.split(' and ').length > 2 ||
        lowerQuestion.split(' or ').length > 2;

    if (hasMultipleClauses) {
      return true;
    }

    return false;
  }
}
