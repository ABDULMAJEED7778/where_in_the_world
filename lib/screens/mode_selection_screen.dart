import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../utils/responsive.dart';
import '../widgets/animated_background.dart';
import '../widgets/audio_settings_dialog.dart';
import '../models/game_models.dart';
import 'game_lobby_screen.dart';
import 'online_lobby_screen.dart';

/// Mode selection screen - first screen after launch where user picks game mode
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToSinglePlayer() {
    AudioService().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const GameLobbyScreen(gameMode: GameMode.singlePlayer),
      ),
    );
  }

  void _navigateToPartyMode() {
    AudioService().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const GameLobbyScreen(gameMode: GameMode.partyMode),
      ),
    );
  }

  void _navigateToOnlineRooms() {
    AudioService().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnlineLobbyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values
    final logoSize = Responsive.value<double>(
      context,
      phone: 180,
      tablet: 140,
      laptop: 150,
      desktop: 160,
    );

    final titleFontSize = Responsive.value<double>(
      context,
      phone: 24,
      tablet: 24,
      laptop: 26,
      desktop: 28,
    );

    final contentPadding = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 16,
      laptop: 20,
      desktop: 24,
    );

    final buttonSpacing = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 14,
      laptop: 16,
      desktop: 18,
    );

    final maxContentWidth = Responsive.value<double>(
      context,
      phone: double.infinity,
      tablet: 450,
      laptop: 500,
      desktop: 550,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Settings button
                  _buildHeader(),

                  Expanded(
                    child: Responsive.isPhone(context)
                        ? Center(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(contentPadding),
                              child: _buildModeContent(
                                logoSize: logoSize,
                                titleFontSize: titleFontSize,
                                buttonSpacing: buttonSpacing,
                                maxContentWidth: maxContentWidth,
                              ),
                            ),
                          )
                        : Center(
                            child: _buildModeContent(
                              logoSize: logoSize,
                              titleFontSize: titleFontSize,
                              buttonSpacing: buttonSpacing,
                              maxContentWidth: maxContentWidth,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeContent({
    required double logoSize,
    required double titleFontSize,
    required double buttonSpacing,
    required double maxContentWidth,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(logoSize),
          SizedBox(height: buttonSpacing),
          Text(
            'SELECT GAME MODE',
            style: GoogleFonts.hanaleiFill(
              fontSize: titleFontSize,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: buttonSpacing * 2),
          _buildModeButton(
            icon: Icons.wifi,
            label: 'ONLINE ROOMS',
            description: 'Play with friends anywhere',
            color: const Color.fromARGB(255, 221, 78, 78),
            onTap: _navigateToOnlineRooms,
            isNew: true,
          ),
          SizedBox(height: buttonSpacing),
          _buildModeButton(
            icon: Icons.groups,
            label: 'PARTY MODE',
            description: 'Same device, take turns with friends',
            color: const Color(0xFFF3D42B),
            onTap: _navigateToPartyMode,
          ),
          SizedBox(height: buttonSpacing),
          _buildModeButton(
            icon: Icons.person,
            label: 'SINGLE PLAYER',
            description: 'Play solo and test your knowledge',
            color: const Color(0xFF74E67C),
            onTap: _navigateToSinglePlayer,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(padding * 0.5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(Icons.settings, color: Colors.white, size: iconSize),
            ),
            onPressed: () {
              AudioService().playButtonClick();
              showDialog(
                context: context,
                builder: (context) => const AudioSettingsDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double size) {
    final scale = size / 120; // 120 is base size

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

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    // Responsive values for button
    final buttonPadding = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 20,
      laptop: 24,
      desktop: 28,
    );

    final iconContainerSize = Responsive.value<double>(
      context,
      phone: 44,
      tablet: 52,
      laptop: 58,
      desktop: 64,
    );

    final iconSize = Responsive.value<double>(
      context,
      phone: 28,
      tablet: 32,
      laptop: 36,
      desktop: 40,
    );

    final labelFontSize = Responsive.value<double>(
      context,
      phone: 18,
      tablet: 20,
      laptop: 22,
      desktop: 24,
    );

    final descFontSize = Responsive.value<double>(
      context,
      phone: 11,
      tablet: 12,
      laptop: 13,
      desktop: 14,
    );

    final arrowSize = Responsive.value<double>(
      context,
      phone: 18,
      tablet: 20,
      laptop: 22,
      desktop: 24,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(buttonPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              SizedBox(width: buttonPadding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.hanaleiFill(
                              fontSize: labelFontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEA00),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: descFontSize * 0.85,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
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
    );
  }
}
