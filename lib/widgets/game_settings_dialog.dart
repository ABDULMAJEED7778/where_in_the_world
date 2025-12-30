import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class GameSettingsDialog extends StatefulWidget {
  final VoidCallback? onQuitToMenu;

  const GameSettingsDialog({super.key, this.onQuitToMenu});

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  final AudioService _audioService = AudioService();

  late double _masterVolume;
  late double _musicVolume;
  late double _sfxVolume;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _masterVolume = _audioService.masterVolume;
    _musicVolume = _audioService.musicVolume;
    _sfxVolume = _audioService.sfxVolume;
    _isMuted = _audioService.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Game Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Settings Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Mute Toggle
                  _buildMuteToggle(),

                  const SizedBox(height: 32),

                  // Master Volume
                  _buildVolumeSlider(
                    label: 'Master Volume',
                    icon: Icons.volume_up,
                    value: _masterVolume,
                    onChanged: (value) async {
                      setState(() => _masterVolume = value);
                      await _audioService.setMasterVolume(value);
                    },
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 24),

                  // Music Volume
                  _buildVolumeSlider(
                    label: 'Music Volume',
                    icon: Icons.music_note,
                    value: _musicVolume,
                    onChanged: (value) async {
                      setState(() => _musicVolume = value);
                      await _audioService.setMusicVolume(value);
                    },
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 24),

                  // SFX Volume
                  _buildVolumeSlider(
                    label: 'Sound Effects',
                    icon: Icons.notifications_active,
                    value: _sfxVolume,
                    onChanged: (value) async {
                      setState(() => _sfxVolume = value);
                      await _audioService.setSfxVolume(value);
                      // Play test sound
                      _audioService.playButtonClick();
                    },
                    color: Colors.green,
                  ),

                  const SizedBox(height: 32),

                  // Quit to Menu Button
                  if (widget.onQuitToMenu != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1a1a2e),
                              title: const Text(
                                'Quit to Menu?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Your current game progress will be lost.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    Navigator.of(context).pop();
                                    widget.onQuitToMenu!();
                                  },
                                  child: const Text(
                                    'Quit',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text(
                          'Quit to Menu',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _audioService.playButtonClick();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isMuted
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isMuted
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isMuted ? Icons.volume_off : Icons.volume_up,
            color: _isMuted ? Colors.red : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isMuted ? 'Sound Muted' : 'Sound Enabled',
              style: TextStyle(
                color: _isMuted ? Colors.red : Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: !_isMuted,
            onChanged: (value) async {
              setState(() => _isMuted = !value);
              await _audioService.setMuted(!value);
              if (value) {
                _audioService.playButtonClick();
              }
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            onChanged: _isMuted ? null : onChanged,
            min: 0.0,
            max: 1.0,
            divisions: 20,
          ),
        ),
      ],
    );
  }
}
