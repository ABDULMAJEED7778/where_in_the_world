import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing all audio in the game
/// Handles both background music and sound effects
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players
  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();

  // SFX Player Pool (allows overlapping sounds and reduces lag)
  static const int _sfxPoolSize = 5;
  final List<AudioPlayer> _sfxPool = [];
  int _currentSfxIndex = 0;

  // Volume settings (0.0 to 1.0)
  double _masterVolume = 0.7;
  double _musicVolume = 0.3;
  double _sfxVolume = 0.6;
  bool _isMuted = false;

  // Current music track
  String? _currentMusicTrack;

  // Preferences keys
  static const String _keyMasterVolume = 'master_volume';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySfxVolume = 'sfx_volume';
  static const String _keyIsMuted = 'is_muted';

  // Getters
  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMuted => _isMuted;

  /// Initialize the audio service and load saved settings
  Future<void> initialize() async {
    try {
      await loadSettings();

      // Initialize music player
      final musicInit = _musicPlayer.setReleaseMode(ReleaseMode.loop);

      // Initialize SFX pool in parallel
      // We create multiple players to allow overlapping sounds
      final sfxInits = List.generate(_sfxPoolSize, (index) async {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        _sfxPool.add(player);
      });

      // Wait for all players to be ready
      await Future.wait([musicInit, ...sfxInits]);

      // Apply initial volumes
      await _updateVolumes();

      print('✅ AudioService initialized with $_sfxPoolSize SFX players');
    } catch (e) {
      print('⚠️ Error initializing AudioService: $e');
    }
  }

  /// Load volume settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _masterVolume = prefs.getDouble(_keyMasterVolume) ?? 0.7;
      _musicVolume = prefs.getDouble(_keyMusicVolume) ?? 0.3;
      _sfxVolume = prefs.getDouble(_keySfxVolume) ?? 0.6;
      _isMuted = prefs.getBool(_keyIsMuted) ?? false;
    } catch (e) {
      print('⚠️ Error loading audio settings: $e');
    }
  }

  /// Save volume settings to SharedPreferences
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMasterVolume, _masterVolume);
      await prefs.setDouble(_keyMusicVolume, _musicVolume);
      await prefs.setDouble(_keySfxVolume, _sfxVolume);
      await prefs.setBool(_keyIsMuted, _isMuted);
    } catch (e) {
      print('⚠️ Error saving audio settings: $e');
    }
  }

  /// Update all player volumes based on current settings
  Future<void> _updateVolumes() async {
    final effectiveMusicVolume = _isMuted ? 0.0 : _masterVolume * _musicVolume;
    final effectiveSfxVolume = _isMuted ? 0.0 : _masterVolume * _sfxVolume;

    await _musicPlayer.setVolume(effectiveMusicVolume);

    // Update all SFX pool players
    for (var player in _sfxPool) {
      await player.setVolume(effectiveSfxVolume);
    }
  }

  // ========== SETTERS ==========

  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
    await saveSettings();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
    await saveSettings();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _updateVolumes();
    await saveSettings();
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _updateVolumes();
    await saveSettings();
  }

  Future<void> toggleMute() async {
    await setMuted(!_isMuted);
  }

  // ========== BACKGROUND MUSIC ==========

  /// Play background music (loops automatically)
  /// Play background music (loops automatically)
  /// Fire-and-forget to prevent blocking UI
  void playMusic(String track) {
    if (_currentMusicTrack == track &&
        _musicPlayer.state == PlayerState.playing) {
      return; // Already playing this track
    }

    // Don't await! Use .then() chain
    _musicPlayer.stop().then((_) {
      _currentMusicTrack = track;
      _musicPlayer.play(AssetSource('sounds/music/$track')).catchError((e) {
        print('⚠️ Error playing music $track: $e');
      });
    });
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      _currentMusicTrack = null;
    } catch (e) {
      print('⚠️ Error stopping music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('⚠️ Error pausing music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    try {
      await _musicPlayer.resume();
    } catch (e) {
      print('⚠️ Error resuming music: $e');
    }
  }

  // ========== SOUND EFFECTS ==========

  /// Play a sound effect using the player pool
  /// Optimized for low latency and no blocking
  void playSfx(String effectPath) {
    if (_isMuted || _sfxPool.isEmpty) return;

    // Use a simple round-robin strategy for the pool
    // This is faster than checking player states and "good enough" for games
    final player = _sfxPool[_currentSfxIndex];
    _currentSfxIndex = (_currentSfxIndex + 1) % _sfxPoolSize;

    // Fire and forget - don't await!
    player.stop().then((_) {
      player.play(AssetSource('sounds/effects/$effectPath')).catchError((e) {
        // Suppress errors to prevent log spam affecting performance
        // print('⚠️ SFX Error: $e');
      });
    });
  }

  // ========== GAME EVENT SOUNDS ==========

  // Gameplay sounds
  void playCorrectGuess() => playSfx('gameplay/correct_guess.mp3');
  void playIncorrectGuess() => playSfx('gameplay/incorrect_guess.mp3');
  void playNearestGuess() => playSfx('gameplay/nearest_guess.mp3');
  void playHintUsed() => playSfx('gameplay/hint_used.mp3');

  // Question sounds
  void playQuestionAsked() => playSfx('questions/question_asked.mp3');
  void playAnswerYes() => playSfx('questions/answer_yes.mp3');
  void playAnswerNo() => playSfx('questions/answer_no.mp3');

  // UI sounds
  void playButtonClick() => playSfx('ui/button_click.mp3');
  void playSecondaryButtonClick() => playSfx('ui/secondary_button_click.mp3');

  // Game flow sounds
  void playGameStart() => playSfx('game_flow/game_start.mp3');
  void playGameEnd() => playSfx('game_flow/game_end.mp3');
  void playRoundStart() => playSfx('game_flow/round_start.mp3');

  // Music tracks
  void playLobbyMusic() => playMusic('lobby_music.mp3');
  void playGameplayMusic() => playMusic('gameplay_music.mp3');
  void playVictoryMusic() => playMusic('victory_music.mp3');

  /// Dispose of audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    for (var player in _sfxPool) {
      await player.dispose();
    }
  }
}
