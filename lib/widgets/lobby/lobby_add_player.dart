import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../services/audio_service.dart';

/// Text field + ADD button for adding players in party mode.
class LobbyAddPlayerSection extends StatefulWidget {
  const LobbyAddPlayerSection({super.key});

  @override
  State<LobbyAddPlayerSection> createState() => _LobbyAddPlayerSectionState();
}

class _LobbyAddPlayerSectionState extends State<LobbyAddPlayerSection> {
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _playerNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter player name',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            cursorColor: Colors.white,
            cursorWidth: 2,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            AudioService().playSecondaryButtonClick();
            if (_playerNameController.text.isNotEmpty) {
              context.read<GameProvider>().addPlayer(
                _playerNameController.text,
              );
              _playerNameController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a player name'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74E67C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              Text(
                "ADD",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              const Text(
                'ADD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
