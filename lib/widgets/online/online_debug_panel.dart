import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/online_game_provider.dart';
import '../../models/online_game_models.dart';

/// Debug panel overlay showing sync info and game state.
class OnlineDebugPanel extends StatelessWidget {
  final OnlineGameProvider provider;
  final String roomCode;
  final DateTime lastSync;

  const OnlineDebugPanel({
    super.key,
    required this.provider,
    required this.roomCode,
    required this.lastSync,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛠 DEBUG INFO',
                  style: GoogleFonts.hanaleiFill(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    fontSize: 12,
                  ),
                ),
                InkWell(
                  onTap: () {
                    print('🔄 Manual Sync Triggered');
                    provider.initializeRoom(roomCode);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: Colors.cyan, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'SYNC NOW',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Text(
              'Room: $roomCode',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'My ID: ${provider.currentPlayerId}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Turn ID: ${provider.gameState?.currentPlayerId}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Is My Turn: ${provider.isMyTurn}',
              style: GoogleFonts.hanaleiFill(
                color: provider.isMyTurn ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Step: ${provider.status.name}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Questions: ${provider.gameState?.questions.length ?? 0}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              'Last Update: ${lastSync.hour}:${lastSync.minute}:${lastSync.second}',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
