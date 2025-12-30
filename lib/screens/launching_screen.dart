import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../utils/responsive.dart';
import 'mode_selection_screen.dart';

class LaunchingScreen extends StatefulWidget {
  const LaunchingScreen({super.key});

  @override
  State<LaunchingScreen> createState() => _LaunchingScreenState();
}

class _LaunchingScreenState extends State<LaunchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showStartButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Show start button after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showStartButton = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    // Start lobby music (this works now because it's triggered by user interaction)
    AudioService().playLobbyMusic();

    // Navigate to mode selection screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values
    final logoSize = Responsive.value<double>(
      context,
      phone: 200,
      tablet: 250,
      laptop: 280,
      desktop: 320,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 20,
      tablet: 24,
      laptop: 28,
      desktop: 32,
    );

    final buttonPaddingH = Responsive.value<double>(
      context,
      phone: 36,
      tablet: 48,
      laptop: 56,
      desktop: 64,
    );

    final buttonPaddingV = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 16,
      laptop: 18,
      desktop: 20,
    );

    final spacing = Responsive.value<double>(
      context,
      phone: 40,
      tablet: 48,
      laptop: 56,
      desktop: 64,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildLogo(logoSize),
                  ),
                );
              },
            ),
            SizedBox(height: spacing),
            // Start Button
            AnimatedOpacity(
              opacity: _showStartButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _showStartButton
                  ? ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74E67C), // Green
                        foregroundColor: const Color(0xFF2D1B69), // Dark Purple
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPaddingH,
                          vertical: buttonPaddingV,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        'START GAME',
                        style: GoogleFonts.hanaleiFill(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: buttonPaddingV * 2 + buttonFontSize,
                      width: buttonPaddingH * 2 + 150,
                    ), // Placeholder to prevent layout jump
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    // Scale internal elements based on logo size
    final scale = size / 250; // 250 is the base size

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
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
                      color: const Color(0xFFF3D42B), // Yellow
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'IN',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'THE',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'WORLD',
                        style: GoogleFonts.hanaleiFill(
                          color: const Color(0xFFF3D42B), // Yellow
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '?',
                        style: GoogleFonts.hanaleiFill(
                          color: const Color(0xFFE63C3D), // Red
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Container(
                    width: 20 * scale,
                    height: 20 * scale,
                    decoration: const BoxDecoration(
                      color: Color(0xFF74E67C), // Green
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 12 * scale,
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
}
