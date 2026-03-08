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
  final LayerLink _layerLink = LayerLink();
  bool _isButtonEnabled = false;
  String? _selectedPlayerId;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedPlayerId == null) {
      final gameState = context.read<GameProvider>().gameState;
      final players = gameState.players;
      final playersWhoGuessed = gameState.playersWhoGuessed;

      final current = gameState.currentPlayer;
      if (current != null && !playersWhoGuessed.contains(current.id)) {
        _selectedPlayerId = current.id;
      } else {
        // Find first player who hasn't guessed
        try {
          final firstUnplayed = players.firstWhere(
            (p) => !playersWhoGuessed.contains(p.id),
          );
          _selectedPlayerId = firstUnplayed.id;
        } catch (_) {
          // Everyone has guessed
        }
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic responsive values based on screen width
    // Dialog width: 85% on small screens, max 500px on large screens
    final dialogWidth = (screenWidth * 0.85).clamp(280.0, 500.0);

    // Font sizes scale with screen width
    final titleFontSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final hintFontSize = (screenWidth * 0.028).clamp(10.0, 14.0);

    // Padding and spacing scale with screen width
    final padding = (screenWidth * 0.04).clamp(14.0, 24.0);
    final borderRadius = (screenWidth * 0.03).clamp(10.0, 20.0);

    // Button sizing
    final buttonHeight = (screenWidth * 0.1).clamp(40.0, 52.0);
    final playerBadgePadding = (screenWidth * 0.02).clamp(6.0, 12.0);

    return Dialog(
      backgroundColor: const Color(0xFF2D1B69).withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Make Your Guess',
                  style: GoogleFonts.hanaleiFill(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: playerBadgePadding * 1.5,
                    vertical: playerBadgePadding * 0.75,
                  ),
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
                          fontSize: hintFontSize,
                          letterSpacing: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.5
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        currentPlayer.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: hintFontSize,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: padding),

            // Player selector (only in multiplayer)
            Builder(
              builder: (context) {
                final gameState = context.read<GameProvider>().gameState;
                final gameMode = gameState.settings.gameMode;
                final players = gameState.players;
                final playersWhoGuessed = gameState.playersWhoGuessed;

                final availablePlayers = players
                    .where((p) => !playersWhoGuessed.contains(p.id))
                    .toList();

                if (gameMode == GameMode.singlePlayer ||
                    availablePlayers.length <= 1) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: padding),
                  child: Row(
                    children: [
                      Text(
                        'Guessing as: ',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white70,
                          fontSize: bodyFontSize,
                        ),
                      ),
                      SizedBox(width: padding * 0.5),
                      if (availablePlayers.isEmpty)
                        Text(
                          'Everyone has guessed',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: bodyFontSize,
                          ),
                        )
                      else
                        DropdownButton<String>(
                          dropdownColor: const Color(0xFF3c2a85),
                          value: _selectedPlayerId,
                          style: GoogleFonts.hanaleiFill(
                            color: Colors.white,
                            fontSize: bodyFontSize,
                          ),
                          underline: Container(
                            height: 2,
                            color: const Color(0xFFFFEA00),
                          ),
                          items: availablePlayers.map((p) {
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

            // Country input with autocomplete
            CompositedTransformTarget(
              link: _layerLink,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final String query = textEditingValue.text
                      .trim()
                      .toLowerCase();
                  if (query.length < 2) {
                    return const Iterable<String>.empty();
                  }
                  final suggestions = allCountries.where((String country) {
                    return country.toLowerCase().startsWith(query);
                  });
                  return suggestions;
                },
                onSelected: (String selection) {
                  _guessController.text = selection;
                  _guessController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _guessController.text.length),
                  );
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        showCursor: true,
                        cursorColor: const Color(0xFFFFEA00),
                        onChanged: (String text) {
                          _guessController.text = text;
                        },
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white,
                          fontSize: bodyFontSize,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter country name...',
                          hintStyle: GoogleFonts.hanaleiFill(
                            color: Colors.white38,
                            fontSize: bodyFontSize * 0.9,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: EdgeInsets.all(padding * 0.75),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius * 0.75,
                            ),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius * 0.75,
                            ),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius * 0.75,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFEA00),
                              width: 2,
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                      );
                    },
                optionsViewBuilder:
                    (
                      BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options,
                    ) {
                      return CompositedTransformFollower(
                        link: _layerLink,
                        showWhenUnlinked: false,
                        offset: Offset(0.0, buttonHeight + 12),
                        child: Material(
                          elevation: 4.0,
                          color: const Color(0xFF3c2a85),
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth: dialogWidth - (padding * 2),
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
                                    padding: EdgeInsets.all(padding * 0.75),
                                    child: Text(
                                      option,
                                      style: GoogleFonts.hanaleiFill(
                                        color: Colors.white,
                                        fontSize: bodyFontSize,
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

            SizedBox(height: padding * 0.75),

            // Warning message
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: bodyFontSize * 1.2,
                ),
                SizedBox(width: padding * 0.5),
                Expanded(
                  child: Text(
                    'You cannot cancel your guess after submitting!',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.orange,
                      fontSize: hintFontSize,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: padding),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.5,
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: bodyFontSize,
                    ),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _submitGuess : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63C3D),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                      ),
                      elevation: 4,
                      padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'GUESS!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: bodyFontSize,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          'GUESS!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: bodyFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
