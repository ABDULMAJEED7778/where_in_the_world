import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/online_game_provider.dart';
import '../../models/online_game_models.dart';

/// Game-ended screen with winner card, full leaderboard, and back-to-menu button.
class OnlineGameEndedView extends StatelessWidget {
  final OnlineGameProvider provider;
  final Future<void> Function() onLeaveGame;

  const OnlineGameEndedView({
    super.key,
    required this.provider,
    required this.onLeaveGame,
  });

  @override
  Widget build(BuildContext context) {
    final winner = provider.winner;
    final sortedPlayers = List<OnlinePlayer>.from(provider.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final topScore = sortedPlayers.isNotEmpty ? sortedPlayers.first.score : 0;
    final winners = sortedPlayers.where((p) => p.score == topScore).toList();
    final hasMultipleWinners = winners.length > 1;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isWideScreen = screenWidth > 900 && screenWidth > screenHeight;

    final titleFontSize = (screenWidth * 0.05).clamp(24.0, 48.0);
    final subtitleFontSize = (screenWidth * 0.035).clamp(18.0, 28.0);
    final bodyFontSize = (screenWidth * 0.025).clamp(14.0, 18.0);
    final smallFontSize = (screenWidth * 0.022).clamp(11.0, 14.0);
    final iconSize = (screenWidth * 0.12).clamp(48.0, 96.0);
    final padding = (screenWidth * 0.04).clamp(16.0, 32.0);
    final borderRadius = (screenWidth * 0.03).clamp(16.0, 24.0);

    Widget buildWinnerCard() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFEA00).withOpacity(0.25),
              const Color(0xFFFFEA00).withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: const Color(0xFFFFEA00).withOpacity(0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFEA00).withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(padding * 0.6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEA00).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFEA00), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFEA00).withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                color: const Color(0xFFFFEA00),
                size: iconSize,
              ),
            ),
            SizedBox(height: padding),
            Text(
              'GAME OVER',
              style: GoogleFonts.hanaleiFill(
                fontSize: titleFontSize,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            if (winner != null) ...[
              SizedBox(height: padding * 0.6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasMultipleWinners ? 'CHAMPIONS' : 'CHAMPION',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: smallFontSize,
                    color: const Color(0xFFFFEA00),
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...winners.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    w.nickname.toUpperCase(),
                    style: GoogleFonts.hanaleiFill(
                      fontSize: hasMultipleWinners
                          ? subtitleFontSize
                          : subtitleFontSize * 1.3,
                      color: const Color(0xFF74E67C),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '$topScore POINTS',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: bodyFontSize,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget buildLeaderboard() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding * 0.7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FINAL STANDINGS',
              style: GoogleFonts.hanaleiFill(
                fontSize: bodyFontSize,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: padding * 0.6),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sortedPlayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  final isTop3 = index < 3;
                  final color = index == 0
                      ? const Color(0xFFFFD700)
                      : index == 1
                      ? const Color(0xFFC0C0C0)
                      : index == 2
                      ? const Color(0xFFCD7F32)
                      : Colors.white54;
                  final medal = index == 0
                      ? '🥇'
                      : index == 1
                      ? '🥈'
                      : index == 2
                      ? '🥉'
                      : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isTop3
                          ? color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isTop3
                          ? Border.all(color: color.withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: medal != null
                              ? Text(
                                  medal,
                                  style: const TextStyle(fontSize: 18),
                                )
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.hanaleiFill(
                                    fontSize: 16,
                                    color: Colors.white38,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            player.nickname.toUpperCase(),
                            style: GoogleFonts.hanaleiFill(
                              fontSize: bodyFontSize * 0.9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${player.score}',
                          style: GoogleFonts.hanaleiFill(
                            fontSize: bodyFontSize,
                            color: isTop3 ? color : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: padding),
            ElevatedButton(
              onPressed: () async {
                await onLeaveGame();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74E67C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'BACK TO MENU',
                style: GoogleFonts.hanaleiFill(
                  fontSize: bodyFontSize,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: buildWinnerCard()),
                      SizedBox(width: padding * 1.5),
                      Expanded(flex: 1, child: buildLeaderboard()),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        buildWinnerCard(),
                        SizedBox(height: padding),
                        buildLeaderboard(),
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
