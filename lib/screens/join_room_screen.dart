import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/online_game_models.dart';
import '../services/audio_service.dart';
import '../services/room_service.dart';
import '../widgets/animated_background.dart';
import 'online_game_screen.dart';

/// Screen for joining an existing online room
class JoinRoomScreen extends StatefulWidget {
  final String nickname;
  final String? prefilledCode; // For deep linking

  const JoinRoomScreen({super.key, required this.nickname, this.prefilledCode});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final RoomService _roomService = RoomService();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isJoining = false;
  bool _requiresPassword = false;
  String? _errorMessage;
  OnlineRoom? _joinedRoom;
  StreamSubscription? _roomSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledCode != null) {
      _codeController.text = widget.prefilledCode!;
      _checkRoom();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkRoom() async {
    final code = _codeController.text.toUpperCase().trim();
    if (code.length != 6) return;

    try {
      final exists = await _roomService.roomExists(code);
      if (!exists) {
        setState(() => _errorMessage = 'Room not found');
        return;
      }

      final needsPassword = await _roomService.roomRequiresPassword(code);
      setState(() {
        _requiresPassword = needsPassword;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error checking room');
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.toUpperCase().trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-character room code');
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      await _roomService.joinRoom(
        roomCode: code,
        nickname: widget.nickname,
        password: _requiresPassword ? _passwordController.text : null,
      );

      // Listen to room updates
      _roomSubscription = _roomService.listenToRoom(code).listen((room) {
        if (mounted) {
          setState(() => _joinedRoom = room);

          // If game starts, navigate to game screen
          if (room != null &&
              room.gameState.status == OnlineGameStatus.playing) {
            _navigateToGame(code);
          }

          // If room becomes inactive (host left), show message
          if (room == null || !room.isActive) {
            _showKickedMessage();
          }
        }
      });

      setState(() => _isJoining = false);
      AudioService().playButtonClick();
    } catch (e) {
      setState(() {
        _isJoining = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _navigateToGame(String code) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnlineGameScreen(roomCode: code)),
    );
  }

  void _showKickedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You were removed from the room'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pop(context);
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
        if (_joinedRoom != null) {
          await _leaveRoom();
          return false;
        }
        return true;
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
                    child: _joinedRoom != null
                        ? _buildWaitingRoom()
                        : _buildJoinForm(),
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
            onPressed: _joinedRoom != null
                ? _leaveRoom
                : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              _joinedRoom != null ? 'WAITING ROOM' : 'JOIN ROOM',
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildJoinForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Room code input
          Text(
            'ENTER ROOM CODE',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),

          _buildCodeInput(),
          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Password input (if required)
          if (_requiresPassword) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Room Password',
                  labelStyle: GoogleFonts.poppins(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white54,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Join button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isJoining ? null : _joinRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEA00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isJoining
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'JOIN ROOM',
                      style: GoogleFonts.hanaleiFill(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _codeController,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        maxLength: 6,
        style: GoogleFonts.hanaleiFill(
          fontSize: 36,
          color: Colors.white,
          letterSpacing: 8,
        ),
        decoration: InputDecoration(
          hintText: '------',
          hintStyle: GoogleFonts.hanaleiFill(
            fontSize: 36,
            color: Colors.white24,
            letterSpacing: 8,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.length == 6) {
            _checkRoom();
          }
        },
      ),
    );
  }

  Widget _buildWaitingRoom() {
    final players = _joinedRoom?.players.values.toList() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEA00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFEA00).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFEA00),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Waiting for host to start...',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFEA00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Players list
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      'PLAYERS IN ROOM',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...players.map((player) => _buildPlayerTile(player)),
              ],
            ),
          ),
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
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe)
                      Text(
                        ' (You)',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (isHost)
                  Text(
                    'Host',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFEA00),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            player.isConnected ? Icons.wifi : Icons.wifi_off,
            color: player.isConnected ? Colors.green : Colors.red,
            size: 18,
          ),
        ],
      ),
    );
  }
}
