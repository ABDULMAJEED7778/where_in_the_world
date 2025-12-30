import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/online_game_provider.dart';
import '../data/countries.dart';
import '../services/audio_service.dart';

class OnlineGuessDialog extends StatefulWidget {
  final String roomCode;

  const OnlineGuessDialog({super.key, required this.roomCode});

  @override
  State<OnlineGuessDialog> createState() => _OnlineGuessDialogState();
}

class _OnlineGuessDialogState extends State<OnlineGuessDialog> {
  final TextEditingController _guessController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _guessController.addListener(() {
      final isTextNotEmpty = _guessController.text.trim().isNotEmpty;
      if (isTextNotEmpty != _isButtonEnabled) {
        setState(() {
          _isButtonEnabled = isTextNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnlineGameProvider>();
    final myId = provider.currentPlayerId;

    return AlertDialog(
      backgroundColor: const Color(0xFF2D1B69).withOpacity(0.95),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Make Your Guess',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          if (myId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEA00),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    provider.players.any((p) => p.id == myId)
                        ? provider.players
                              .firstWhere((p) => p.id == myId)
                              .nickname
                              .toUpperCase()
                        : 'PLAYER',
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
                    provider.players.any((p) => p.id == myId)
                        ? provider.players
                              .firstWhere((p) => p.id == myId)
                              .nickname
                              .toUpperCase()
                        : 'PLAYER',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final String query = textEditingValue.text.trim().toLowerCase();
                if (query.length < 2) {
                  return const Iterable<String>.empty();
                }
                return allCountries.where((String country) {
                  return country.toLowerCase().startsWith(query);
                });
              },
              onSelected: (String selection) {
                _guessController.text = selection;
                _guessController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _guessController.text.length),
                );
              },
              fieldViewBuilder:
                  (
                    context,
                    fieldTextEditingController,
                    fieldFocusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      showCursor: true,
                      cursorColor: const Color(0xFFFFEA00),
                      onChanged: (String text) {
                        _guessController.text = text;
                      },
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter country name...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFEA00),
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                return CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0.0, 56.0),
                  child: Material(
                    elevation: 4.0,
                    color: const Color(0xFF3c2a85),
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 300,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                option,
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You cannot cancel your guess after submitting!',
                  style: GoogleFonts.poppins(
                    color: Colors.orange,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isButtonEnabled ? _submitGuess : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63C3D),
              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 4,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'GUESS!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.black,
                  ),
                ),
                const Text(
                  'GUESS!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitGuess() {
    if (_isButtonEnabled) {
      AudioService().playButtonClick();
      context.read<OnlineGameProvider>().makeGuess(
        _guessController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }
}
