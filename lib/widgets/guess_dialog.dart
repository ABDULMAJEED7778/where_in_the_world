import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../data/countries.dart';
import '../services/audio_service.dart';

class GuessDialog extends StatefulWidget {
  const GuessDialog({super.key});

  @override
  State<GuessDialog> createState() => _GuessDialogState();
}

class _GuessDialogState extends State<GuessDialog> {
  final TextEditingController _guessController = TextEditingController();
  final LayerLink _layerLink = LayerLink(); // ✅ 1. Create a LayerLink
  bool _isButtonEnabled = false;
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    // ✅ 2. Add a listener to the controller
    // This function will be called every time the text changes.
    _guessController.addListener(() {
      // Check if the button's state needs to be changed
      final isTextNotEmpty = _guessController.text.trim().isNotEmpty;
      if (isTextNotEmpty != _isButtonEnabled) {
        // Use setState to rebuild the widget and update the button
        setState(() {
          _isButtonEnabled = isTextNotEmpty;
        });
      }
    });

    // We'll set a default selected player later in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedPlayerId == null) {
      final players = context.read<GameProvider>().gameState.players;
      final current = context.read<GameProvider>().gameState.currentPlayer;
      if (current != null) {
        _selectedPlayerId = current.id;
      } else if (players.isNotEmpty) {
        _selectedPlayerId = players.first.id;
      }
    }
  }

  @override
  void dispose() {
    _guessController.removeListener(() {});
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<GameProvider>().gameState.players;
    final currentPlayer = players.firstWhere(
      (p) => p.id == _selectedPlayerId,
      orElse: () =>
          players.isNotEmpty ? players.first : Player(name: 'Unknown'),
    );

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
                  currentPlayer.name.toUpperCase(),
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
                  currentPlayer.name.toUpperCase(),
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
          // Only show in multiplayer mode
          Builder(
            builder: (context) {
              final gameMode = context
                  .read<GameProvider>()
                  .gameState
                  .settings
                  .gameMode;
              final players = context.read<GameProvider>().gameState.players;

              // Don't show player selector in single player mode
              if (gameMode == GameMode.singlePlayer || players.length <= 1) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(
                      'Guessing as: ',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    if (players.isEmpty)
                      const Text(
                        'No players',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF3c2a85),
                        value: _selectedPlayerId,
                        style: GoogleFonts.poppins(color: Colors.white),
                        underline: Container(
                          height: 2,
                          color: const Color(0xFFFFEA00),
                        ),
                        items: players.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPlayerId = val;
                          });
                        },
                      ),
                  ],
                ),
              );
            },
          ),

          // const SizedBox(height: 12), // Removed as padding is added to player selector
          CompositedTransformTarget(
            link: _layerLink,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final String query = textEditingValue.text.trim().toLowerCase();
                if (query.length < 2) {
                  return const Iterable<String>.empty();
                }
                final suggestions = allCountries.where((String country) {
                  return country.toLowerCase().startsWith(query);
                });
                // You can uncomment this now, it will work!
                // print('Query: "$query", Suggestions: ${suggestions.length}');
                return suggestions;
              },
              onSelected: (String selection) {
                // When a user selects an item, update our controller.
                // This ensures the button state updates correctly.
                _guessController.text = selection;
                // Move cursor to the end
                _guessController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _guessController.text.length),
                );
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController
                    fieldTextEditingController, // This is the controller Autocomplete uses
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // ✅ FIX 1: The TextField MUST use the 'fieldTextEditingController'
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      showCursor: true,
                      cursorColor: const Color(0xFFFFEA00),
                      // ✅ FIX 2: Sync the changes back to our own controller
                      onChanged: (String text) {
                        // This keeps our listener in initState working for the button state
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
              // The optionsViewBuilder remains the same as before, it was correct.
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options,
                  ) {
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
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
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
    // The check is technically redundant now but is good for safety
    if (_isButtonEnabled) {
      AudioService().playButtonClick();
      context.read<GameProvider>().makeGuess(
        _guessController.text.trim(),
        playerId: _selectedPlayerId,
      );
      Navigator.of(context).pop();
    }
  }
}
