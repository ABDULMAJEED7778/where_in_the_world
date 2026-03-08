import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/online_game_models.dart';
import '../services/audio_service.dart';
import '../services/room_service.dart';
import '../widgets/animated_background.dart';
import 'online_game_screen.dart';

/// Screen for creating and managing an online room as host
class CreateRoomScreen extends StatefulWidget {
  final String nickname;

  const CreateRoomScreen({super.key, required this.nickname});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final RoomService _roomService = RoomService();
  final TextEditingController _passwordController = TextEditingController();

  String? _roomCode;
  OnlineRoom? _room;
  StreamSubscription? _roomSubscription;
  bool _isCreating = false;
  bool _usePassword = false;
  int _selectedRounds = 6;
  int _selectedDifficulty = 1;
  int _questionsPerTurn = 2;
  bool _isTimerEnabled = true;
  int _timerDuration = 60;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);
    print('🔄 Starting room creation for ${widget.nickname}...');

    try {
      final code = await _roomService.createRoom(
        hostName: widget.nickname,
        password: _usePassword ? _passwordController.text : null,
        totalRounds: _selectedRounds,
        difficulty: _selectedDifficulty,
        questionsPerTurn: _questionsPerTurn,
        isTimerEnabled: _isTimerEnabled,
        timerDuration: _timerDuration,
      );

      print('✅ Room created successfully! Code: $code');

      setState(() {
        _roomCode = code;
        _isCreating = false;
      });

      // Listen to room updates
      _roomSubscription = _roomService
          .listenToRoom(code)
          .listen(
            (room) {
              print('📡 Room update received: ${room?.players.length} players');
              if (mounted) {
                setState(() => _room = room);
              }
            },
            onError: (error) {
              print('❌ Room listener error: $error');
            },
          );
    } catch (e, stackTrace) {
      print('❌ Room creation failed: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create room: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _copyRoomCode() {
    if (_roomCode == null) return;
    Clipboard.setData(ClipboardData(text: _roomCode!));
    AudioService().playSecondaryButtonClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied!'),
        backgroundColor: Color(0xFF74E67C),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareRoom() {
    if (_roomCode == null) return;
    AudioService().playSecondaryButtonClick();
    final link = _roomService.generateShareLink(_roomCode!);
    Share.share(
      'Join my Where in the World game!\n\nRoom Code: $_roomCode\n\nOr click: $link',
      subject: 'Join my game!',
    );
  }

  Future<void> _kickPlayer(String playerId) async {
    try {
      await _roomService.kickPlayer(playerId);
      AudioService().playSecondaryButtonClick();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startGame() async {
    if (_room == null || _room!.players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 2 players to start'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      AudioService().playButtonClick();

      // Show loading while starting round
      if (mounted) {
        setState(
          () => _isCreating = true,
        ); // Repurposing _isCreating for start loading
      }

      print('🏁 Host starting game...');

      await _roomService.startNewRound(
        roomCode: _roomCode!,
        difficulty: _selectedDifficulty,
        playerIds: _room!.players.keys.toList(),
        totalRounds: _selectedRounds,
        questionsPerTurn: _questionsPerTurn,
      );

      print('🚀 Game status updated! Navigating to OnlineGameScreen...');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineGameScreen(roomCode: _roomCode!),
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to start game: $e');
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveRoom() async {
    await _roomService.leaveRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / screenHeight;

    // Reduce spacing on short/wide screens
    final isShortScreen = screenHeight < 700 || aspectRatio >= 1.0;
    final spacingMultiplier = isShortScreen ? 0.6 : 1.0;

    // Compact mode for screens with aspect ratio >= 5:6 (0.83) and height < 800px
    final isCompactScreen = aspectRatio >= 0.83 && screenHeight < 800;
    final compactMultiplier = isCompactScreen ? 0.8 : 1.0;

    // Dynamic responsive values (scaled down in compact mode)
    final padding = ((screenWidth * 0.05) * compactMultiplier).clamp(
      12.0,
      32.0,
    );
    final titleFontSize = ((screenWidth * 0.06) * compactMultiplier).clamp(
      18.0,
      32.0,
    );
    final cardPadding = ((screenWidth * 0.05) * compactMultiplier).clamp(
      12.0,
      24.0,
    );
    final spacing =
        ((screenHeight * 0.03) * spacingMultiplier * compactMultiplier).clamp(
          8.0,
          24.0,
        );

    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2D1B69),
        body: Stack(
          children: [
            const AnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(screenWidth, titleFontSize),
                  Expanded(
                    child: _isCreating
                        ? _buildLoadingState(screenWidth)
                        : _buildRoomContent(
                            screenWidth,
                            padding,
                            cardPadding,
                            spacing,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double fontSize) {
    final padding = (screenWidth * 0.04).clamp(12.0, 24.0);
    final iconSize = (screenWidth * 0.06).clamp(20.0, 28.0);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: _leaveRoom,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          Expanded(
            child: Text(
              'YOUR ROOM',
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: iconSize + 16), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth) {
    final spinnerSize = (screenWidth * 0.1).clamp(30.0, 50.0);
    final fontSize = (screenWidth * 0.045).clamp(16.0, 24.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: spinnerSize,
            height: spinnerSize,
            child: const CircularProgressIndicator(color: Color(0xFF74E67C)),
          ),
          const SizedBox(height: 20),
          Text(
            'Creating room...',
            style: GoogleFonts.hanaleiFill(
              color: Colors.white70,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomContent(
    double screenWidth,
    double padding,
    double cardPadding,
    double spacing,
  ) {
    // Check if we should use wide layout (Tablet/Desktop)
    final isWideScreen = screenWidth > 800;

    if (isWideScreen) {
      return _buildWideLayout(screenWidth, padding, cardPadding, spacing);
    }

    return _buildMobileLayout(screenWidth, padding, cardPadding, spacing);
  }

  Widget _buildMobileLayout(
    double screenWidth,
    double padding,
    double cardPadding,
    double spacing,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          // Room Code Card
          _buildRoomCodeCard(screenWidth, cardPadding),
          SizedBox(height: spacing),

          // Game Settings Card
          _buildGameSettingsCard(screenWidth, cardPadding, spacing),
          SizedBox(height: spacing),

          // Players List
          _buildPlayersCard(screenWidth, cardPadding),
          SizedBox(height: spacing),

          // Start Game Button
          _buildStartButton(screenWidth),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    double screenWidth,
    double padding,
    double cardPadding,
    double spacing,
  ) {
    // Max constraints for content area - creates white space on very wide/tall screens
    const double maxContentWidth = 1200.0;
    const double maxContentHeight = 700.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: maxContentWidth,
          maxHeight: maxContentHeight,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Room Code & Settings
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRoomCodeCard(screenWidth, cardPadding),
                      SizedBox(height: spacing),
                      _buildGameSettingsCard(screenWidth, cardPadding, spacing),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing),

              // Right Column: Players List (Expanded) & Start Button
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildPlayersCard(
                        screenWidth,
                        cardPadding,
                        expandHeight: true,
                      ),
                    ),
                    SizedBox(height: spacing),
                    _buildStartButton(screenWidth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCodeCard(double screenWidth, double padding) {
    final titleFontSize = (screenWidth * 0.035).clamp(10.0, 14.0);
    final codeFontSize = (screenWidth * 0.10).clamp(28.0, 56.0);
    final letterSpacing = (screenWidth * 0.02).clamp(4.0, 10.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF74E67C).withOpacity(0.2),
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
            'ROOM CODE',
            style: GoogleFonts.hanaleiFill(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: padding * 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _roomCode ?? '------',
                style: GoogleFonts.hanaleiFill(
                  fontSize: codeFontSize,
                  color: const Color(0xFF74E67C),
                  letterSpacing: letterSpacing,
                ),
              ),
            ],
          ),
          SizedBox(height: padding * 0.6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionChip(
                screenWidth: screenWidth,
                icon: Icons.copy,
                label: 'Copy',
                onTap: _copyRoomCode,
              ),
              const SizedBox(width: 12),
              _buildActionChip(
                screenWidth: screenWidth,
                icon: Icons.share,
                label: 'Share',
                onTap: _shareRoom,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsCard(
    double screenWidth,
    double padding,
    double spacing,
  ) {
    final titleFontSize = (screenWidth * 0.04).clamp(12.0, 16.0);
    final subTitleFontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: Colors.white70, size: iconSize),
              const SizedBox(width: 8),
              Text(
                'GAME SETTINGS',
                style: GoogleFonts.hanaleiFill(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Difficulty Row
          Text(
            'DIFFICULTY',
            style: GoogleFonts.hanaleiFill(
              fontSize: subTitleFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDifficultyButton(
                  'EASY',
                  1,
                  const Color(0xFF74E67C),
                  screenWidth,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'MODERATE',
                  2,
                  const Color(0xFFF3D42B),
                  screenWidth,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'HARD',
                  3,
                  const Color(0xFFE63C3D),
                  screenWidth,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Rounds and Questions Row
          Row(
            children: [
              Expanded(
                child: _buildNumberSetting(
                  label: 'ROUNDS',
                  value: _selectedRounds,
                  min: 2,
                  max: 10,
                  onChanged: (v) => setState(() => _selectedRounds = v),
                  screenWidth: screenWidth,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberSetting(
                  label: 'QUESTIONS/TURN',
                  value: _questionsPerTurn,
                  min: 2,
                  max: 5,
                  onChanged: (v) => setState(() => _questionsPerTurn = v),
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Timer Options Row
          Row(
            children: [
              Expanded(child: _buildTimerEnabledToggle(screenWidth)),
              const SizedBox(width: 16),
              Expanded(
                child: _isTimerEnabled
                    ? _buildNumberSetting(
                        label: 'TIMER (SEC)',
                        value: _timerDuration,
                        min: 30,
                        max: 180,
                        onChanged: (v) {
                          // Snap to common values
                          int snapped = v;
                          if (v % 15 != 0 && v > _timerDuration) {
                            snapped =
                                _timerDuration + 15 - (_timerDuration % 15);
                          } else if (v % 15 != 0 && v < _timerDuration) {
                            snapped = _timerDuration - (_timerDuration % 15);
                          }
                          setState(
                            () => _timerDuration = snapped.clamp(30, 180),
                          );
                        },
                        screenWidth: screenWidth,
                      )
                    : Opacity(
                        opacity: 0.5,
                        child: _buildNumberSetting(
                          label: 'TIMER (SEC)',
                          value: _timerDuration,
                          min: 30,
                          max: 180,
                          onChanged: (_) {},
                          screenWidth: screenWidth,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerEnabledToggle(double screenWidth) {
    final labelFontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    final valueFontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final padding = (screenWidth * 0.025).clamp(8.0, 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TURN TIMER',
          style: GoogleFonts.hanaleiFill(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            AudioService().playSecondaryButtonClick();
            setState(() => _isTimerEnabled = !_isTimerEnabled);
          },
          child: Container(
            height:
                40 + (padding * 2), // Matching the height of number settings
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isTimerEnabled
                    ? const Color(0xFF74E67C)
                    : Colors.white24,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isTimerEnabled ? Icons.timer : Icons.timer_off,
                  color: _isTimerEnabled
                      ? const Color(0xFF74E67C)
                      : Colors.white54,
                ),
                const SizedBox(width: 8),
                Text(
                  _isTimerEnabled ? 'ON' : 'OFF',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: valueFontSize,
                    color: _isTimerEnabled
                        ? const Color(0xFF74E67C)
                        : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
    String label,
    int difficulty,
    Color color,
    double screenWidth,
  ) {
    final isSelected = _selectedDifficulty == difficulty;
    final fontSize = (screenWidth * 0.03).clamp(10.0, 13.0);
    final padding = (screenWidth * 0.02).clamp(8.0, 12.0);

    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        setState(() => _selectedDifficulty = difficulty);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade400.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.0),
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.7),
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
              label,
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
              label,
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
                right: 0,
                top: 0,
                child: Icon(
                  Icons.check_circle,
                  size: fontSize * 1.2,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSetting({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required double screenWidth,
  }) {
    final labelFontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    final valueFontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final iconSize = (screenWidth * 0.05).clamp(16.0, 20.0);
    final padding = (screenWidth * 0.025).clamp(8.0, 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hanaleiFill(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Decrease button
              GestureDetector(
                onTap: () {
                  if (value > min) {
                    AudioService().playSecondaryButtonClick();
                    onChanged(value - 1);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(padding),
                  child: Icon(
                    Icons.remove,
                    color: value > min ? Colors.white : Colors.white38,
                    size: iconSize,
                  ),
                ),
              ),
              // Value display
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: GoogleFonts.hanaleiFill(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              // Increase button
              GestureDetector(
                onTap: () {
                  if (value < max) {
                    AudioService().playSecondaryButtonClick();
                    onChanged(value + 1);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(padding),
                  child: Icon(
                    Icons.add,
                    color: value < max ? Colors.white : Colors.white38,
                    size: iconSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required double screenWidth,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final iconSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final fontSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final hPadding = (screenWidth * 0.03).clamp(12.0, 16.0);

    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCard(
    double screenWidth,
    double padding, {
    bool expandHeight = false,
  }) {
    final players = _room?.players.values.toList() ?? [];
    final titleFontSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);

    return Container(
      padding: EdgeInsets.all(padding),
      width: double.infinity,
      height: expandHeight ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.white70, size: iconSize),
              const SizedBox(width: 8),
              Text(
                'PLAYERS (${players.length}/8)',
                style: GoogleFonts.hanaleiFill(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (players.isEmpty)
            Text(
              'Waiting for players...',
              style: GoogleFonts.hanaleiFill(color: Colors.white38),
            )
          else if (expandHeight)
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) =>
                    _buildPlayerTile(players[index], screenWidth),
              ),
            )
          else
            ...players.map((player) => _buildPlayerTile(player, screenWidth)),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(OnlinePlayer player, double screenWidth) {
    final isHost = player.isHost;
    final isMe = player.id == _roomService.currentPlayerId;
    final avatarRadius = (screenWidth * 0.045).clamp(16.0, 22.0);
    final nameFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    final paddingV = (screenWidth * 0.025).clamp(10.0, 12.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingV),
      decoration: BoxDecoration(
        color: isHost
            ? const Color(0xFFFFEA00).withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: const Color(0xFF74E67C), width: 2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: isHost
                ? const Color(0xFFFFEA00)
                : const Color(0xFF74E67C),
            child: Text(
              player.nickname[0].toUpperCase(),
              style: GoogleFonts.hanaleiFill(
                color: Colors.black,
                fontSize: avatarRadius * 0.9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.nickname,
                      style: GoogleFonts.hanaleiFill(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: nameFontSize,
                      ),
                    ),
                    if (isMe)
                      Text(
                        ' (You)',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white54,
                          fontSize: nameFontSize * 0.8,
                        ),
                      ),
                  ],
                ),
                if (isHost)
                  Text(
                    'Host',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFFFEA00),
                      fontSize: nameFontSize * 0.8,
                    ),
                  ),
              ],
            ),
          ),
          // Connection status
          Icon(
            player.isConnected ? Icons.wifi : Icons.wifi_off,
            color: player.isConnected ? Colors.green : Colors.red,
            size: avatarRadius,
          ),
          // Kick button (for non-host players)
          if (!isHost && !isMe)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: avatarRadius * 1.2,
              onPressed: () => _kickPlayer(player.id),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              tooltip: 'Kick player',
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton(double screenWidth) {
    final playerCount = _room?.players.length ?? 0;
    final canStart = playerCount >= 2;
    final fontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final padding = (screenWidth * 0.04).clamp(14.0, 20.0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canStart ? _startGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF74E67C),
          disabledBackgroundColor: Colors.grey,
          padding: EdgeInsets.symmetric(vertical: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          canStart ? 'START GAME' : 'WAITING FOR PLAYERS...',
          style: GoogleFonts.hanaleiFill(
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
