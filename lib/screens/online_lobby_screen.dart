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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / screenHeight;

    // Reduce spacing on short/wide screens (tablets in landscape, small windows)
    final isShortScreen = screenHeight < 700 || aspectRatio >= 1.0;
    final spacingMultiplier = isShortScreen ? 0.5 : 1.0;

    // Dynamic responsive values
    final titleFontSize = (screenWidth * 0.08).clamp(24.0, 48.0);
    final subtitleFontSize = (screenWidth * 0.035).clamp(11.0, 16.0);
    final padding = (screenWidth * 0.05).clamp(12.0, 28.0);
    final spacing = ((screenHeight * 0.04) * spacingMultiplier).clamp(
      16.0,
      40.0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Back button and title
                _buildHeader(screenWidth),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'ONLINE\nMULTIPLAYER',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hanaleiFill(
                              fontSize: titleFontSize,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: spacing * 0.2),
                          Text(
                            'Play with friends anywhere!',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: spacing),

                          // Nickname Input
                          _buildNicknameInput(screenWidth),
                          SizedBox(height: spacing),

                          // Create Room Button
                          _buildActionButton(
                            screenWidth: screenWidth,
                            icon: Icons.add_circle_outline,
                            label: 'CREATE ROOM',
                            description: 'Host a game for others to join',
                            color: const Color(0xFF74E67C),
                            onTap: _navigateToCreateRoom,
                          ),
                          SizedBox(height: padding * 0.8),

                          // Join Room Button
                          _buildActionButton(
                            screenWidth: screenWidth,
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

  Widget _buildHeader(double screenWidth) {
    final padding = (screenWidth * 0.04).clamp(12.0, 24.0);
    final iconSize = (screenWidth * 0.06).clamp(22.0, 32.0);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              AudioService().playSecondaryButtonClick();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          const Spacer(),
          Icon(Icons.wifi, color: Colors.white, size: iconSize),
        ],
      ),
    );
  }

  Widget _buildNicknameInput(double screenWidth) {
    final maxWidth = (screenWidth * 0.9).clamp(300.0, 500.0);
    final padding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final labelFontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    final inputFontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final borderRadius = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
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
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: padding * 0.4),
          TextField(
            controller: _nicknameController,
            style: GoogleFonts.poppins(
              fontSize: inputFontSize,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: inputFontSize * 0.9,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person_outline,
                color: _isNicknameValid
                    ? const Color(0xFF74E67C)
                    : Colors.white54,
                size: inputFontSize * 1.2,
              ),
              suffixIcon: _isNicknameValid
                  ? Icon(
                      Icons.check_circle,
                      color: const Color(0xFF74E67C),
                      size: inputFontSize * 1.2,
                    )
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
    required double screenWidth,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final maxWidth = (screenWidth * 0.9).clamp(300.0, 500.0);
    final padding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final iconSize = (screenWidth * 0.08).clamp(28.0, 40.0);
    final labelFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final descFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);
    final borderRadius = (screenWidth * 0.05).clamp(16.0, 24.0);
    final arrowSize = (screenWidth * 0.05).clamp(18.0, 24.0);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(padding * 0.6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(borderRadius * 0.6),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),
                SizedBox(width: padding * 0.8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.hanaleiFill(
                          fontSize: labelFontSize,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: padding * 0.2),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: descFontSize,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: arrowSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
