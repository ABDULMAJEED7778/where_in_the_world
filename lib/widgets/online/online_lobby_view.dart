import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lobby waiting state shown before the game starts.
class OnlineLobbyView extends StatelessWidget {
  final String roomCode;
  final int playerCount;
  final bool isHost;
  final VoidCallback onStartGame;
  final Widget headerWidget;

  const OnlineLobbyView({
    super.key,
    required this.roomCode,
    required this.playerCount,
    required this.isHost,
    required this.onStartGame,
    required this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
        child: Column(
          children: [
            headerWidget,
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
                      'Room: $roomCode',
                      style: GoogleFonts.hanaleiFill(
                        fontSize: 18,
                        color: const Color(0xFF74E67C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$playerCount players',
                      style: GoogleFonts.hanaleiFill(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    if (isHost)
                      ElevatedButton(
                        onPressed: playerCount >= 2 ? onStartGame : null,
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
        ),
      ),
    );
  }
}
