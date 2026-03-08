import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/online_game_provider.dart';
import '../../models/online_game_models.dart';

/// Round-over screen showing image reveal, winner/no-winner card,
/// scores button, and next round / waiting for host.
class OnlineRoundOverView extends StatelessWidget {
  final OnlineGameProvider provider;
  final VoidCallback onShowScores;
  final VoidCallback onNextRound;

  const OnlineRoundOverView({
    super.key,
    required this.provider,
    required this.onShowScores,
    required this.onNextRound,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswer = provider.currentLandmark?.country ?? 'Unknown';
    final winnerId = provider.gameState?.lastRoundWinnerId;
    final reason = provider.gameState?.lastRoundWinReason;
    final guesses = provider.gameState?.playerGuesses ?? {};
    final questionsAsked = provider.questions.length;

    final winner = winnerId != null
        ? provider.players.firstWhere(
            (p) => p.id == winnerId,
            orElse: () =>
                OnlinePlayer(id: 'unknown', nickname: 'Unknown', isHost: false),
          )
        : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = screenWidth / screenHeight;

    final isWideScreen = screenWidth > 900 && aspectRatio > 1;
    final maxContentWidth = isWideScreen
        ? 900.0
        : (screenWidth * 0.9).clamp(300.0, 600.0);

    final titleFontSize = (screenWidth * 0.065).clamp(24.0, 36.0);
    final subtitleFontSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 18.0);
    final smallFontSize = (screenWidth * 0.028).clamp(11.0, 14.0);
    final iconSize = (screenWidth * 0.1).clamp(36.0, 56.0);
    final padding = (screenWidth * 0.05).clamp(16.0, 32.0);
    final smallPadding = (screenWidth * 0.03).clamp(10.0, 20.0);
    final borderRadius = (screenWidth * 0.04).clamp(16.0, 28.0);
    final buttonPaddingH = (screenWidth * 0.08).clamp(32.0, 56.0);
    final buttonPaddingV = (screenWidth * 0.03).clamp(12.0, 20.0);

    Widget buildContent() {
      final imageReveal = provider.currentLandmark != null
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: AspectRatio(
                  aspectRatio: isWideScreen ? 4 / 3 : 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        provider.currentLandmark!.imagePath,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: smallPadding,
                        left: smallPadding,
                        right: smallPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REVEALED',
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white60,
                                fontSize: smallFontSize,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              provider.currentLandmark!.name.toUpperCase(),
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white,
                                fontSize: subtitleFontSize,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();

      final statsSection = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Winner Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: winner != null
                    ? [
                        const Color(0xFFFFEA00).withOpacity(0.2),
                        const Color(0xFFFFEA00).withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: winner != null
                    ? const Color(0xFFFFEA00).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: winner != null
                      ? const Color(0xFFFFEA00).withOpacity(0.15)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                if (winner != null) ...[
                  Container(
                    padding: EdgeInsets.all(smallPadding * 0.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEA00).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFEA00),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: const Color(0xFFFFEA00),
                      size: iconSize * 0.8,
                    ),
                  ),
                  SizedBox(height: smallPadding),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: reason == 'correct'
                          ? const Color(0xFF74E67C)
                          : const Color(0xFF5BC0EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reason == 'correct' ? 'CORRECT GUESS!' : 'NEAREST GUESS!',
                      style: GoogleFonts.hanaleiFill(
                        fontSize: smallFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner.nickname.toUpperCase(),
                    style: GoogleFonts.hanaleiFill(
                      fontSize: titleFontSize * 0.9,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    reason == 'correct' ? '+10 POINTS' : '+5 POINTS',
                    style: GoogleFonts.hanaleiFill(
                      fontSize: bodyFontSize,
                      color: const Color(0xFFFFEA00),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.timer_off_outlined,
                    color: Colors.white54,
                    size: iconSize,
                  ),
                  SizedBox(height: smallPadding),
                  Text(
                    'ROUND OVER',
                    style: GoogleFonts.hanaleiFill(
                      fontSize: titleFontSize,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'NO ONE GUESSED IT',
                    style: GoogleFonts.hanaleiFill(
                      fontSize: smallFontSize,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: smallPadding),

          // View Scores Button
          TextButton.icon(
            onPressed: onShowScores,
            icon: const Icon(
              Icons.leaderboard,
              color: Color(0xFFFFEA00),
              size: 20,
            ),
            label: Text(
              'VIEW FULL SCORES',
              style: GoogleFonts.hanaleiFill(
                color: const Color(0xFFFFEA00),
                fontSize: bodyFontSize * 0.9,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          SizedBox(height: padding),

          // Next Round Button / Waiting
          if (provider.isHost)
            ElevatedButton(
              onPressed: onNextRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEA00),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH,
                  vertical: buttonPaddingV * 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 12,
              ),
              child: Text(
                provider.currentRound < provider.totalRounds
                    ? 'NEXT ROUND'
                    : 'SEE RESULTS',
                style: GoogleFonts.hanaleiFill(
                  fontSize: subtitleFontSize * 0.9,
                  letterSpacing: 2,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFFFEA00).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'WAITING FOR HOST...',
                    style: GoogleFonts.hanaleiFill(
                      fontSize: bodyFontSize * 0.8,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

      if (isWideScreen) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: imageReveal),
            SizedBox(width: padding * 1.5),
            Expanded(flex: 2, child: statsSection),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageReveal,
            SizedBox(height: padding),
            statsSection,
          ],
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: buildContent(),
          ),
        ),
      ),
    );
  }
}
