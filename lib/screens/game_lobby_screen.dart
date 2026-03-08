import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import '../utils/responsive.dart';
import '../widgets/audio_settings_dialog.dart';
import '../widgets/lobby/lobby_difficulty_section.dart';
import '../widgets/lobby/lobby_rounds_questions.dart';
import '../widgets/lobby/lobby_player_list.dart';
import '../widgets/lobby/lobby_add_player.dart';
import '../widgets/lobby/lobby_single_player_name.dart';
import '../widgets/lobby/lobby_rules_section.dart';
import '../widgets/lobby/lobby_play_button.dart';
import '../widgets/lobby/lobby_timer_settings.dart';

class GameLobbyScreen extends StatefulWidget {
  final GameMode gameMode;
  final GameSettings? initialSettings;
  final List<Player>? initialPlayers;

  const GameLobbyScreen({
    super.key,
    required this.gameMode,
    this.initialSettings,
    this.initialPlayers,
  });

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _numberOfRounds = 6;
  int _questionsPerPlayer = 2;
  bool _isTimerEnabled = true;
  int _timerDuration = 60;

  @override
  void initState() {
    super.initState();
    if (widget.initialSettings != null) {
      _selectedDifficulty = widget.initialSettings!.difficulty;
      _numberOfRounds = widget.initialSettings!.numberOfRounds;
      _questionsPerPlayer = widget.initialSettings!.questionsPerPlayer;
      _isTimerEnabled = widget.initialSettings!.isTimerEnabled;
      _timerDuration = widget.initialSettings!.turnDurationSeconds;
    }

    if (widget.initialPlayers != null && widget.initialPlayers!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final gameProvider = context.read<GameProvider>();
        for (final player in widget.initialPlayers!) {
          bool exists = gameProvider.gameState.players.any(
            (p) => p.name == player.name,
          );
          if (!exists) {
            gameProvider.addPlayer(player.name);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerMaxWidth = Responsive.value<double>(
      context,
      phone: double.infinity,
      tablet: 540,
      laptop: 540,
      desktop: 600,
    );
    final containerPadding = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 20,
      laptop: 20,
      desktop: 24,
    );
    final logoSize = Responsive.value<double>(
      context,
      phone: 100,
      tablet: 90,
      laptop: 100,
      desktop: 110,
    );
    final sectionSpacing = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 12,
      laptop: 14,
      desktop: 16,
    );
    final titleFontSize = Responsive.value<double>(
      context,
      phone: 15,
      tablet: 18,
      laptop: 20,
      desktop: 22,
    );
    final settingsIconSize = Responsive.value<double>(
      context,
      phone: 24,
      tablet: 28,
      laptop: 30,
      desktop: 32,
    );
    final isPhone = Responsive.isPhone(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.value<double>(
                      context,
                      phone: 24,
                      tablet: 20,
                      laptop: 24,
                      desktop: 32,
                    ),
                    vertical: Responsive.value<double>(
                      context,
                      phone: 16,
                      tablet: 40,
                      laptop: 40,
                      desktop: 40,
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 80,
                    ),
                    child: Center(
                      child: Container(
                        width: isPhone ? double.infinity : null,
                        constraints: BoxConstraints(
                          maxWidth: containerMaxWidth,
                        ),
                        decoration: isPhone
                            ? null
                            : BoxDecoration(
                                color: const Color(0xFF1A0F3D),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            isPhone ? 0 : containerPadding,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLogo(logoSize),
                              SizedBox(height: sectionSpacing),
                              _buildModeLabel(),
                              SizedBox(height: sectionSpacing),
                              Text(
                                'CHOOSE YOUR GAME SETTINGS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: sectionSpacing * 1.5),
                              LobbyDifficultySection(
                                selectedDifficulty: _selectedDifficulty,
                                onDifficultyChanged: (d) =>
                                    setState(() => _selectedDifficulty = d),
                              ),
                              SizedBox(height: sectionSpacing),
                              LobbyRoundsQuestions(
                                numberOfRounds: _numberOfRounds,
                                questionsPerPlayer: _questionsPerPlayer,
                                isSinglePlayer:
                                    widget.gameMode == GameMode.singlePlayer,
                                onRoundsChanged: (v) =>
                                    setState(() => _numberOfRounds = v),
                                onQuestionsChanged: (v) =>
                                    setState(() => _questionsPerPlayer = v),
                              ),
                              SizedBox(height: sectionSpacing),
                              LobbyTimerSettings(
                                isTimerEnabled: _isTimerEnabled,
                                timerDuration: _timerDuration,
                                onTimerToggled: (v) =>
                                    setState(() => _isTimerEnabled = v),
                                onDurationChanged: (v) =>
                                    setState(() => _timerDuration = v),
                              ),
                              SizedBox(height: sectionSpacing * 2),
                              if (widget.gameMode == GameMode.partyMode) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: const LobbyPlayerList(),
                                ),
                                const SizedBox(height: 0),
                                const LobbyAddPlayerSection(),
                              ],
                              if (widget.gameMode == GameMode.singlePlayer) ...[
                                const LobbySinglePlayerName(),
                              ],
                              SizedBox(height: sectionSpacing * 1.5),
                              LobbyRulesSection(
                                isSinglePlayer:
                                    widget.gameMode == GameMode.singlePlayer,
                              ),
                              SizedBox(height: sectionSpacing * 1.5),
                              LobbyPlayButton(
                                gameMode: widget.gameMode,
                                difficulty: _selectedDifficulty,
                                numberOfRounds: _numberOfRounds,
                                questionsPerPlayer: _questionsPerPlayer,
                                isTimerEnabled: _isTimerEnabled,
                                timerDuration: _timerDuration,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Settings Button (Top-Right)
          Positioned(
            top: Responsive.value<double>(
              context,
              phone: 30,
              tablet: 40,
              laptop: 40,
              desktop: 40,
            ),
            right: Responsive.value<double>(
              context,
              phone: 12,
              tablet: 20,
              laptop: 24,
              desktop: 32,
            ),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(
                  Responsive.value<double>(
                    context,
                    phone: 6,
                    tablet: 8,
                    laptop: 10,
                    desktop: 12,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: settingsIconSize,
                ),
              ),
              onPressed: () {
                AudioService().playButtonClick();
                showDialog(
                  context: context,
                  builder: (context) => const AudioSettingsDialog(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double size) {
    final scale = size / 120;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D1B69), Color(0xFF74E67C)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WHERE',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFFFEA00),
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'IN THE',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontSize: 10 * scale,
                    ),
                  ),
                  Text(
                    'WORLD?',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFFFEA00),
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeLabel() {
    final isPartyMode = widget.gameMode == GameMode.partyMode;
    final modeColor = isPartyMode
        ? const Color(0xFFF3D42B)
        : const Color(0xFF74E67C);
    final modeText = isPartyMode ? 'PARTY MODE' : 'SINGLE PLAYER';
    final modeIcon = isPartyMode ? Icons.groups : Icons.person;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: modeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: modeColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(modeIcon, color: modeColor, size: 24),
          const SizedBox(width: 8),
          Text(
            modeText,
            style: TextStyle(
              color: modeColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
