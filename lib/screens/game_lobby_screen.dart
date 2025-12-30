import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import '../utils/responsive.dart';
import '../widgets/audio_settings_dialog.dart';
import 'main_game_screen.dart';

class GameLobbyScreen extends StatefulWidget {
  final GameMode gameMode;

  const GameLobbyScreen({super.key, required this.gameMode});

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _numberOfRounds = 6;
  int _questionsPerPlayer = 2;
  bool _rulesExpanded =
      false; // Start collapsed, will auto-expand on larger screens

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values
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
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Stack(
        children: [
          // Main Content
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
                      minHeight:
                          constraints.maxHeight - 80, // Account for padding
                    ),
                    child: Center(
                      child: Container(
                        width: isPhone ? double.infinity : null,
                        constraints: BoxConstraints(
                          maxWidth: containerMaxWidth,
                        ),
                        decoration: isPhone
                            ? null // No container decoration on phones
                            : BoxDecoration(
                                color: const Color(
                                  0xFF1A0F3D,
                                ), // Darker purple for contrast
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
                              // Show mode label based on passed game mode
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
                              _buildDifficultySection(),
                              SizedBox(height: sectionSpacing),
                              // Use Wrap for better responsiveness on small screens
                              Responsive.isPhone(context)
                                  ? Column(
                                      children: [
                                        _buildRoundsSection(),
                                        SizedBox(height: sectionSpacing),
                                        _buildQuestionsSection(),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(child: _buildRoundsSection()),
                                        SizedBox(width: sectionSpacing * 2),
                                        Expanded(
                                          child: _buildQuestionsSection(),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: sectionSpacing * 2),
                              // Conditionally show player list or single name field based on game mode
                              if (widget.gameMode == GameMode.partyMode) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildPlayerList(),
                                ),
                                const SizedBox(height: 0),
                                _buildAddPlayerSection(),
                              ],
                              if (widget.gameMode == GameMode.singlePlayer) ...[
                                _buildSinglePlayerNameSection(),
                              ],
                              SizedBox(height: sectionSpacing * 1.5),
                              _buildRulesSection(),
                              SizedBox(height: sectionSpacing * 1.5),
                              _buildPlayButton(),
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
            // Fallback to the original design if image fails to load
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D1B69), // Primary
                    Color(0xFF74E67C), // Green
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WHERE',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFFFEA00), // Yellow
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
                      color: const Color(0xFFFFEA00), // Yellow
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

  Widget _buildDifficultySection() {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 11,
      tablet: 13,
      laptop: 14,
      desktop: 15,
    );

    // On phone, use column layout for difficulty
    if (Responsive.isPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIFFICULTY:',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDifficultyButton(
                  'EASY',
                  Difficulty.easy,
                  _selectedDifficulty == Difficulty.easy,
                  buttonFontSize,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'MODERATE',
                  Difficulty.moderate,
                  _selectedDifficulty == Difficulty.moderate,
                  buttonFontSize,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'DIFFICULT',
                  Difficulty.difficult,
                  _selectedDifficulty == Difficulty.difficult,
                  buttonFontSize,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          'DIFFICULTY:',
          style: TextStyle(
            color: Colors.white,
            fontSize: labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildDifficultyButton(
            'EASY',
            Difficulty.easy,
            _selectedDifficulty == Difficulty.easy,
            buttonFontSize,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyButton(
            'MODERATE',
            Difficulty.moderate,
            _selectedDifficulty == Difficulty.moderate,
            buttonFontSize,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyButton(
            'DIFFICULT',
            Difficulty.difficult,
            _selectedDifficulty == Difficulty.difficult,
            buttonFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
    String text,
    Difficulty difficulty,
    bool isSelected,
    double fontSize,
  ) {
    Color baseColor;
    switch (difficulty) {
      case Difficulty.easy:
        baseColor = const Color(0xFF74E67C); // Green
        break;
      case Difficulty.moderate:
        baseColor = const Color(0xFFF3D42B); // Yellow
        break;
      case Difficulty.difficult:
        baseColor = const Color(0xFFE63C3D); // Red
        break;
    }

    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        setState(() => _selectedDifficulty = difficulty);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: Responsive.value<double>(
            context,
            phone: 10,
            tablet: 12,
            laptop: 14,
            desktop: 14,
          ),
          horizontal: Responsive.value<double>(
            context,
            phone: 6,
            tablet: 8,
            laptop: 10,
            desktop: 10,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.grey.shade400.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.5),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    baseColor.withOpacity(0.9),
                    baseColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Text stroke (black outline)
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            // White fill text
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            // ✅ Check icon when selected
            if (isSelected)
              Positioned(
                right: 2,
                top: 2,
                child: Icon(
                  Icons.check_circle,
                  size: fontSize * 1.1,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundsSection() {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'NO. OF ROUNDS:',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _buildNumberField(_numberOfRounds),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  setState(() {
                    if (_numberOfRounds < 10) {
                      _numberOfRounds++;
                    } else {
                      _numberOfRounds = 10;
                    }
                  });
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (_numberOfRounds > 2) {
                    setState(() {
                      if (_numberOfRounds > 2) {
                        _numberOfRounds--;
                      } else {
                        _numberOfRounds = 2;
                      }
                    });
                  }
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            widget.gameMode == GameMode.singlePlayer
                ? 'NO. OF QUESTIONS:'
                : 'QUESTIONS PER PLAYER:',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _buildNumberField(_questionsPerPlayer),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  setState(() {
                    if (_questionsPerPlayer < 5) {
                      _questionsPerPlayer++;
                    } else {
                      _questionsPerPlayer = 5;
                    }
                  });
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (_questionsPerPlayer > 2) {
                    setState(() => _questionsPerPlayer--);
                  }
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(int value) {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          bottomLeft: Radius.circular(12.0),
        ),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        onTap();
      },
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: icon == Icons.keyboard_arrow_down
              ? BorderRadius.only(bottomRight: Radius.circular(12.0))
              : BorderRadius.only(topRight: Radius.circular(12.0)),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildPlayerList() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final players = gameProvider.gameState.players;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'PLAYERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF74E67C).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF74E67C),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${players.length}/8',
                    style: const TextStyle(
                      color: Color(0xFF74E67C),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (players.isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
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
                      Icons.group_add_outlined,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add players to start the game',
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
              ...players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;

                // Assign colors based on player index
                final playerColors = [
                  const Color(0xFF74E67C), // Green
                  const Color(0xFFF3D42B), // Yellow
                  const Color(0xFF5BC0EB), // Blue
                  const Color(0xFFE63C3D), // Red
                  const Color(0xFFFF6B6B), // Coral
                  const Color(0xFF9B59B6), // Purple
                  const Color(0xFFFF9F43), // Orange
                  const Color(0xFF1ABC9C), // Teal
                ];
                final playerColor = playerColors[index % playerColors.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        playerColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: playerColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Player number badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: playerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Remove button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            AudioService().playSecondaryButtonClick();
                            gameProvider.removePlayer(player.name);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildAddPlayerSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _playerNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter player name',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            cursorColor: Colors.white,
            cursorWidth: 2,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            AudioService().playSecondaryButtonClick();
            if (_playerNameController.text.isNotEmpty) {
              context.read<GameProvider>().addPlayer(
                _playerNameController.text,
              );
              _playerNameController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a player name'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74E67C), // Green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              Text(
                "ADD",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              const Text(
                'ADD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection() {
    final isSinglePlayer = widget.gameMode == GameMode.singlePlayer;
    final screenHeight = MediaQuery.of(context).size.height;

    // Make rules collapsible on phones OR when screen height is constrained (< 700px)
    final isSmallScreen = Responsive.isPhone(context) || screenHeight < 900;

    // On larger screens with enough height, always show rules expanded
    final showExpanded = !isSmallScreen || _rulesExpanded;

    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    final ruleFontSize = Responsive.value<double>(
      context,
      phone: 11,
      tablet: 12,
      laptop: 13,
      desktop: 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - tappable on small screens
        GestureDetector(
          onTap: isSmallScreen
              ? () => setState(() => _rulesExpanded = !_rulesExpanded)
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 8 : 0,
              horizontal: isSmallScreen ? 4 : 0,
            ),
            decoration: isSmallScreen
                ? BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: Responsive.value<double>(
                    context,
                    phone: 18,
                    tablet: 20,
                    laptop: 22,
                    desktop: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'RULES:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (isSmallScreen) ...[
                  const Spacer(),
                  Icon(
                    showExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
        // Animated rules content
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: isSinglePlayer
                  ? [
                      // Single Player Rules
                      Text(
                        '• ASK YES/NO QUESTIONS TO NARROW DOWN THE LANDMARK\'S LOCATION.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ONCE YOU GUESS, YOU CANNOT CANCEL OR CHANGE YOUR ANSWER.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• CORRECT GUESS: +10 POINTS. WRONG GUESS: 0 POINTS.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• TRY TO GUESS WITH AS FEW QUESTIONS AS POSSIBLE!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ]
                  : [
                      // Party Mode Rules
                      Text(
                        '• PLAYER WHO ASKED THE LAST QUESTION HAS THE PRIORITY TO GUESS.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• CANCELLATION OF A GUESS AFTER PRESSING THE GUESS BUTTON IS NOT ALLOWED.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• PLAYERS ARE ALLOWED TO DIRECTLY GUESS AT THEIR TURN POINT IN THE GAME.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• IN CASE NO PLAYER GUESSES THE RIGHT COUNTRY, THE PLAYER WITH THE NEAREST GUESS GETS 5 POINTS.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ruleFontSize,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
            ),
          ),
          crossFadeState: showExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // For single player mode, need at least 1 player. For party mode, need at least 2.
        final canPlay = widget.gameMode == GameMode.singlePlayer
            ? gameProvider.gameState.players.length >= 1
            : gameProvider.gameState.players.length >= 2;

        final glowColor = const Color(0xFFEB7A36); // Orange glow

        return Container(
          width: 220,
          height: 55,
          decoration: BoxDecoration(
            gradient: canPlay
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFE63C3D), // Red
                      Color(0xFFEB7A36), // Orange
                      Color(0xFFF3D42B), // Yellow
                      Color(0xFFEB7A36), // Orange
                      Color(0xFFE63C3D), // Red
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
                    // Outer glow
                    BoxShadow(
                      color: glowColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    // Inner glow
                    BoxShadow(
                      color: const Color(0xFFE63C3D).withOpacity(0.4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                    // Subtle white highlight on top
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
                        gameMode: widget.gameMode,
                        difficulty: _selectedDifficulty,
                        numberOfRounds: _numberOfRounds,
                        questionsPerPlayer: _questionsPerPlayer,
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

  Widget _buildSinglePlayerNameSection() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final players = gameProvider.gameState.players;
        final hasPlayer = players.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ENTER YOUR NAME:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            if (hasPlayer)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF74E67C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF74E67C), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF74E67C)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        players.first.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          gameProvider.removePlayer(players.first.name),
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      tooltip: 'Change name',
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _playerNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_playerNameController.text.isNotEmpty) {
                        gameProvider.addPlayer(_playerNameController.text);
                        _playerNameController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74E67C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Text(
                          "SET",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        const Text(
                          'SET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
