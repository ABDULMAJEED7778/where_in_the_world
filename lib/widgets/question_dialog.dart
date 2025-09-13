import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key});

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  bool? _selectedAnswer;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(
        0xFF2D1B69,
      ).withOpacity(0.9), // Primary with opacity
      title: const Text(
        'Ask a Question',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _questionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter your yes/no question...',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            'What is the answer?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedAnswer = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAnswer == true
                        ? const Color(0xFF74E67C) // Green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'YES',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedAnswer = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAnswer == false
                        ? const Color(0xFFE63C3D) // Red
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _canSubmit() ? _submitQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74E67C), // Green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _questionController.text.trim().isNotEmpty &&
        _selectedAnswer != null;
  }

  void _submitQuestion() {
    if (_canSubmit()) {
      context.read<GameProvider>().askQuestion(
        _questionController.text.trim(),
        _selectedAnswer!,
      );
      Navigator.of(context).pop();
    }
  }
}
