import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

/// Entry screen for online multiplayer - choose to create or join a room
class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameValid = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _validateNickname() {
    setState(() {
      _isNicknameValid = _nicknameController.text.trim().length >= 2;
    });
  }

  void _navigateToCreateRoom() {
    if (!_isNicknameValid) {
      _showNicknameError();
      return;
    }
    AudioService().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateRoomScreen(nickname: _nicknameController.text.trim()),
      ),
    );
  }

  void _navigateToJoinRoom() {
    if (!_isNicknameValid) {
      _showNicknameError();
      return;
    }
    AudioService().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JoinRoomScreen(nickname: _nicknameController.text.trim()),
      ),
    );
  }

  void _showNicknameError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a nickname (at least 2 characters)'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Back button and title
                _buildHeader(),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'ONLINE\nMULTIPLAYER',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hanaleiFill(
                              fontSize: 36,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Play with friends anywhere!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Nickname Input
                          _buildNicknameInput(),
                          const SizedBox(height: 40),

                          // Create Room Button
                          _buildActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'CREATE ROOM',
                            description: 'Host a game for others to join',
                            color: const Color(0xFF74E67C),
                            onTap: _navigateToCreateRoom,
                          ),
                          const SizedBox(height: 20),

                          // Join Room Button
                          _buildActionButton(
                            icon: Icons.login_rounded,
                            label: 'JOIN ROOM',
                            description: 'Enter a room code to join',
                            color: const Color(0xFFFFEA00),
                            onTap: _navigateToJoinRoom,
                          ),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AudioService().playSecondaryButtonClick();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Spacer(),
          const Icon(Icons.wifi, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildNicknameInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isNicknameValid
              ? const Color(0xFF74E67C)
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR NICKNAME',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nicknameController,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name...',
              hintStyle: GoogleFonts.poppins(color: Colors.white38),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person_outline,
                color: _isNicknameValid
                    ? const Color(0xFF74E67C)
                    : Colors.white54,
              ),
              suffixIcon: _isNicknameValid
                  ? const Icon(Icons.check_circle, color: Color(0xFF74E67C))
                  : null,
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.hanaleiFill(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
