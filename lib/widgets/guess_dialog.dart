import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GuessDialog extends StatefulWidget {
  const GuessDialog({super.key});

  @override
  State<GuessDialog> createState() => _GuessDialogState();
}

class _GuessDialogState extends State<GuessDialog> {
  final TextEditingController _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(
        0xFF2D1B69,
      ).withOpacity(0.9), // Primary with opacity
      title: const Text(
        'Make Your Guess',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'What country is this landmark in?',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _guessController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter country name...',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          const Text(
            '⚠️ You cannot cancel your guess after submitting!',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _guessController.text.trim().isNotEmpty
              ? _submitGuess
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE63C3D), // Red
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'GUESS!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _submitGuess() {
    if (_guessController.text.trim().isNotEmpty) {
      context.read<GameProvider>().makeGuess(_guessController.text.trim());
      Navigator.of(context).pop();
    }
  }
}
