import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioSettingsDialog extends StatefulWidget {
  const AudioSettingsDialog({super.key});

  @override
  State<AudioSettingsDialog> createState() => _AudioSettingsDialogState();
}

class _AudioSettingsDialogState extends State<AudioSettingsDialog> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dynamic responsive values based on screen width
    final dialogWidth = (screenWidth * 0.85).clamp(300.0, 500.0);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 18.0);
    final smallFontSize = (screenWidth * 0.032).clamp(12.0, 16.0);
    final padding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final iconSize = (screenWidth * 0.06).clamp(22.0, 32.0);
    final smallIconSize = (screenWidth * 0.05).clamp(20.0, 28.0);
    final borderRadius = (screenWidth * 0.04).clamp(14.0, 24.0);
    final buttonHeight = (screenWidth * 0.11).clamp(40.0, 52.0);
    final spacing = (screenWidth * 0.04).clamp(16.0, 24.0);
    final largeSpacing = (screenWidth * 0.06).clamp(24.0, 32.0);

    // Max height to prevent overflow on tall narrow screens
    final maxDialogHeight = screenHeight * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: dialogWidth,
        ),
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
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
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius - 2),
                    topRight: Radius.circular(borderRadius - 2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(padding * 0.5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.blue,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: spacing * 0.75),
                    Text(
                      'Audio Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: smallIconSize,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      // Mute Toggle
                      _buildMuteToggle(
                        padding,
                        iconSize,
                        bodyFontSize,
                        borderRadius,
                      ),

                      SizedBox(height: largeSpacing),

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
                        iconSize: smallIconSize,
                        fontSize: smallFontSize,
                        spacing: spacing * 0.5,
                      ),

                      SizedBox(height: spacing),

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
                        iconSize: smallIconSize,
                        fontSize: smallFontSize,
                        spacing: spacing * 0.5,
                      ),

                      SizedBox(height: spacing),

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
                        iconSize: smallIconSize,
                        fontSize: smallFontSize,
                        spacing: spacing * 0.5,
                      ),

                      SizedBox(height: largeSpacing),

                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            _audioService.playButtonClick();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                borderRadius * 0.5,
                              ),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuteToggle(
    double padding,
    double iconSize,
    double fontSize,
    double borderRadius,
  ) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _isMuted
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius * 0.5),
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
            size: iconSize,
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              _isMuted ? 'Sound Muted' : 'Sound Enabled',
              style: TextStyle(
                color: _isMuted ? Colors.red : Colors.green,
                fontSize: fontSize,
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
    required double iconSize,
    required double fontSize,
    required double spacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(width: spacing),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
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
