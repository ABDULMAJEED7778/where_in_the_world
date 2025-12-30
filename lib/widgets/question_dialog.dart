import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'question_display_overlay.dart';

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key});

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _canSubmitQuestion = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    _questionController.addListener(() {
      final canSubmit = _questionController.text.trim().isNotEmpty;
      if (canSubmit != _canSubmitQuestion) {
        setState(() {
          _canSubmitQuestion = canSubmit;
        });
      }
    });
  }

  @override
  void dispose() {
    // The listener is automatically removed when the controller is disposed
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = context.watch<GameProvider>().gameState.currentPlayer;

    return AlertDialog(
      backgroundColor: const Color(
        0xFF2D1B69,
      ).withOpacity(0.9), // Primary with opacity
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ask a Question',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 240, 0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  currentPlayer?.name.toUpperCase() ?? 'PLAYER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.5
                      ..color = Colors.black,
                  ),
                ),
                Text(
                  currentPlayer?.name.toUpperCase() ?? 'PLAYER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            cursorColor: Colors.white,
            cursorWidth: 2,
            maxLines: 3,
          ),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            'The AI will answer your question about the COUNTRY where this landmark is located.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: (_canSubmitQuestion && !_isLoading)
              ? _submitQuestion
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74E67C), // Green
            disabledBackgroundColor: Colors.grey.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Ask AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _submitQuestion() async {
    if (!_canSubmitQuestion || _isLoading) return;

    final question = _questionController.text.trim();

    // Validate the question before submitting
    final validationError = _validateQuestion(question);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.askQuestion(question);

      if (mounted) {
        // Get the last question to retrieve the AI answer
        final lastQuestion = gameProvider.gameState.currentRoundQuestions.last;

        // Close the dialog
        Navigator.of(context).pop();

        // Show the question display overlay
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: QuestionDisplayOverlay(
              question: lastQuestion.text,
              answer: lastQuestion.answer,
              askedBy: lastQuestion.askedBy,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to get AI response. Please try again.';
        });
      }
    }
  }

  /// Validates if the question is acceptable
  /// Returns error message if invalid, null if valid
  String? _validateQuestion(String question) {
    final lowerQuestion = question.toLowerCase().trim();

    // Check for yes/no question indicators
    final yesNoIndicators = [
      'is ',
      'are ',
      'do ',
      'does ',
      'can ',
      'could ',
      'would ',
      'will ',
      'has ',
      'have ',
      'is the ',
      'are the ',
      'did ',
      'was ',
      'were ',
      'should ',
      'may ',
      'might ',
    ];

    final isYesNoQuestion = yesNoIndicators.any(
      (indicator) => lowerQuestion.startsWith(indicator),
    );

    if (!isYesNoQuestion) {
      return 'Ask a yes/no question (start with "Is", "Are", "Do", "Does", "Can", etc.)';
    }

    // Check for direct country guessing (is it [country]?)
    if (_isDirectCountryGuess(lowerQuestion)) {
      return 'Cannot ask about specific countries directly. Ask about geography, geography features, climate, or location instead.';
    }

    // Check for too-vague questions
    if (_isAmbiguousQuestion(lowerQuestion)) {
      return 'Question is too vague. Be more specific about what you\'re asking.';
    }

    // Check for questions that are too short/simple
    final words = question.split(' ').where((w) => w.isNotEmpty).length;
    if (words < 3) {
      return 'Question is too short. Please provide more details.';
    }

    return null; // Question is valid
  }

  /// Check if the question is trying to guess a specific country
  bool _isDirectCountryGuess(String question) {
    final lowerQuestion = question.toLowerCase();

    // If it contains locational prepositions, it's likely a valid geography question
    if (lowerQuestion.contains(' in ') ||
        lowerQuestion.contains(' near ') ||
        lowerQuestion.contains(' on ') ||
        lowerQuestion.contains(' located ') ||
        lowerQuestion.contains(' part of ')) {
      return false;
    }

    // Pattern: "is it [country]?" or "is the [country]?" etc.
    final countryGuessPatterns = [
      RegExp(r'is\s+it\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+this\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+the\s+country\s+[a-z\s]+\??\s*$', caseSensitive: false),
    ];

    for (var pattern in countryGuessPatterns) {
      if (pattern.hasMatch(question)) {
        // Extract the potential country name
        final match = pattern.firstMatch(question);
        if (match != null) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check for ambiguous or poorly formed questions
  bool _isAmbiguousQuestion(String question) {
    final lowerQuestion = question.toLowerCase();

    // Questions without clear subject
    final vaguePhrases = [
      'is it?',
      'are they?',
      'do you?',
      'can it?',
      'what is it?',
      'who is it?',
      'where is it?',
      'when is it?',
      'why is it?',
      'how is it?',
    ];

    for (var phrase in vaguePhrases) {
      if (lowerQuestion.trim() == phrase) {
        return true;
      }
    }

    // Questions with multiple independent clauses (likely yes/no mashup)
    final hasMultipleClauses =
        lowerQuestion.split(' and ').length > 2 ||
        lowerQuestion.split(' or ').length > 2;

    if (hasMultipleClauses) {
      return true;
    }

    return false;
  }
}
