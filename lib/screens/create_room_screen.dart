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
                  _buildHeader(),
                  Expanded(
                    child: _isCreating
                        ? _buildLoadingState()
                        : _buildRoomContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _leaveRoom,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'YOUR ROOM',
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF74E67C)),
          const SizedBox(height: 20),
          Text(
            'Creating room...',
            style: GoogleFonts.hanaleiFill(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Room Code Card
          _buildRoomCodeCard(),
          const SizedBox(height: 24),

          // Game Settings Card
          _buildGameSettingsCard(),
          const SizedBox(height: 24),

          // Players List
          _buildPlayersCard(),
          const SizedBox(height: 24),

          // Start Game Button
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildRoomCodeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _roomCode ?? '------',
                style: GoogleFonts.hanaleiFill(
                  fontSize: 48,
                  color: const Color(0xFF74E67C),
                  letterSpacing: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionChip(
                icon: Icons.copy,
                label: 'Copy',
                onTap: _copyRoomCode,
              ),
              const SizedBox(width: 12),
              _buildActionChip(
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

  Widget _buildGameSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.tune, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'GAME SETTINGS',
                style: GoogleFonts.hanaleiFill(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Difficulty Row
          Text(
            'DIFFICULTY',
            style: GoogleFonts.hanaleiFill(
              fontSize: 12,
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'MODERATE',
                  2,
                  const Color(0xFFF3D42B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDifficultyButton(
                  'HARD',
                  3,
                  const Color(0xFFE63C3D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String label, int difficulty, Color color) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        setState(() => _selectedDifficulty = difficulty);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade400.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.5),
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
                fontSize: 13,
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            // ✅ Check icon when selected
            if (isSelected)
              Positioned(
                right: 2,
                top: 2,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hanaleiFill(
            fontSize: 12,
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
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.remove,
                    color: value > min ? Colors.white : Colors.white38,
                    size: 20,
                  ),
                ),
              ),
              // Value display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: GoogleFonts.hanaleiFill(
                        fontSize: 18,
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
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.add,
                    color: value < max ? Colors.white : Colors.white38,
                    size: 20,
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
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.hanaleiFill(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCard() {
    final players = _room?.players.values.toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'PLAYERS (${players.length}/8)',
                style: GoogleFonts.hanaleiFill(
                  fontSize: 14,
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
          else
            ...players.map((player) => _buildPlayerTile(player)),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(OnlinePlayer player) {
    final isHost = player.isHost;
    final isMe = player.id == _roomService.currentPlayerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            radius: 18,
            backgroundColor: isHost
                ? const Color(0xFFFFEA00)
                : const Color(0xFF74E67C),
            child: Text(
              player.nickname[0].toUpperCase(),
              style: GoogleFonts.hanaleiFill(color: Colors.black, fontSize: 16),
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
                      ),
                    ),
                    if (isMe)
                      Text(
                        ' (You)',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (isHost)
                  Text(
                    'Host',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFFFEA00),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Connection status
          Icon(
            player.isConnected ? Icons.wifi : Icons.wifi_off,
            color: player.isConnected ? Colors.green : Colors.red,
            size: 18,
          ),
          // Kick button (for non-host players)
          if (!isHost && !isMe)
            IconButton(
              onPressed: () => _kickPlayer(player.id),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              tooltip: 'Kick player',
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final playerCount = _room?.players.length ?? 0;
    final canStart = playerCount >= 2;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canStart ? _startGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF74E67C),
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          canStart ? 'START GAME' : 'WAITING FOR PLAYERS...',
          style: GoogleFonts.hanaleiFill(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
