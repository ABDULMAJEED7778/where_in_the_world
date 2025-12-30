import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/online_game_models.dart';
import 'photos_service.dart';

/// Service for managing online multiplayer rooms via Firebase Realtime Database
class RoomService {
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  // Lazy initialization - only access after Firebase is initialized
  // Update this URL to match your Firebase Realtime Database URL
  static const String _databaseUrl =
      'https://whereintheworld-133f0-default-rtdb.firebaseio.com';

  FirebaseDatabase? _firebaseDbInstance;
  FirebaseDatabase get _firebaseDb {
    _firebaseDbInstance ??= FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    );
    return _firebaseDbInstance!;
  }

  DatabaseReference? _dbRef;
  DatabaseReference get _db {
    _dbRef ??= _firebaseDb.ref();
    return _dbRef!;
  }

  final Uuid _uuid = const Uuid();

  String? _currentRoomId;
  String? _currentPlayerId;

  String? get currentRoomId => _currentRoomId;
  String? get currentPlayerId => _currentPlayerId;

  /// Set the current room and player info (used when resuming/entering a room)
  void setPlayerInfo(String roomCode, String playerId) {
    print(
      '🔑 RoomService: Setting player info - Room: $roomCode, Player: $playerId',
    );
    _currentRoomId = roomCode;
    _currentPlayerId = playerId;
  }

  /// Generate a random 6-character alphanumeric room code
  String _generateRoomCode() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoiding confusing chars
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a new room and return the room code
  Future<String> createRoom({
    required String hostName,
    String? password,
    int totalRounds = 6,
    int difficulty = 1,
    int questionsPerTurn = 2,
  }) async {
    final roomCode = _generateRoomCode();
    final playerId = _uuid.v4();
    _currentPlayerId = playerId;
    _currentRoomId = roomCode;

    final host = OnlinePlayer(
      id: playerId,
      nickname: hostName,
      isHost: true,
      isConnected: true,
    );

    final room = OnlineRoom(
      id: roomCode,
      password: password,
      hostId: playerId,
      hostName: hostName,
      players: {playerId: host},
      gameState: OnlineGameState(
        totalRounds: totalRounds,
        difficulty: difficulty,
        questionsPerTurn: questionsPerTurn,
        status: OnlineGameStatus.lobby,
      ),
    );

    await _db.child('rooms/$roomCode').set(room.toJson());

    // Set up presence (mark as disconnected when connection lost)
    final connectedRef = _firebaseDb.ref('.info/connected');
    connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _db
            .child('rooms/$roomCode/players/$playerId/isConnected')
            .onDisconnect()
            .set(false);
      }
    });

    return roomCode;
  }

  /// Join an existing room
  Future<OnlineRoom?> joinRoom({
    required String roomCode,
    required String nickname,
    String? password,
  }) async {
    final roomRef = _db.child('rooms/$roomCode');
    final snapshot = await roomRef.get();

    if (!snapshot.exists) {
      throw Exception('Room not found');
    }

    final roomData = Map<String, dynamic>.from(snapshot.value as Map);
    final room = OnlineRoom.fromJson(roomData);

    // Check if room is active
    if (!room.isActive) {
      throw Exception('Room is no longer active');
    }

    // Check password if required
    if (room.password != null && room.password!.isNotEmpty) {
      if (password != room.password) {
        throw Exception('Incorrect password');
      }
    }

    // Check if game already started
    if (room.gameState.status != OnlineGameStatus.lobby) {
      throw Exception('Game has already started');
    }

    // Create new player
    final playerId = _uuid.v4();
    _currentPlayerId = playerId;
    _currentRoomId = roomCode;

    final player = OnlinePlayer(
      id: playerId,
      nickname: nickname,
      isHost: false,
      isConnected: true,
    );

    await roomRef.child('players/$playerId').set(player.toJson());

    // Set up presence
    final connectedRef = _firebaseDb.ref('.info/connected');
    connectedRef.onValue.listen((event) {
      if (event.snapshot.value == true) {
        roomRef
            .child('players/$playerId/isConnected')
            .onDisconnect()
            .set(false);
      }
    });

    return room;
  }

  /// Leave the current room
  Future<void> leaveRoom() async {
    if (_currentRoomId == null || _currentPlayerId == null) return;

    final roomRef = _db.child('rooms/$_currentRoomId');
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      final roomData = Map<String, dynamic>.from(snapshot.value as Map);
      final room = OnlineRoom.fromJson(roomData);

      // If host leaves, close the room
      if (room.hostId == _currentPlayerId) {
        await roomRef.update({'isActive': false});
      } else {
        // Remove player from room
        await roomRef.child('players/$_currentPlayerId').remove();
      }
    }

    _currentRoomId = null;
    _currentPlayerId = null;
  }

  /// Kick a player from the room (host only)
  Future<void> kickPlayer(String playerId) async {
    if (_currentRoomId == null || _currentPlayerId == null) return;

    final roomRef = _db.child('rooms/$_currentRoomId');
    final snapshot = await roomRef.get();

    if (snapshot.exists) {
      final roomData = Map<String, dynamic>.from(snapshot.value as Map);
      final room = OnlineRoom.fromJson(roomData);

      // Only host can kick
      if (room.hostId != _currentPlayerId) {
        throw Exception('Only the host can kick players');
      }

      // Can't kick yourself
      if (playerId == _currentPlayerId) {
        throw Exception('Cannot kick yourself');
      }

      await roomRef.child('players/$playerId').remove();
    }
  }

  /// Listen to room state changes
  Stream<OnlineRoom?> listenToRoom(String roomCode) {
    // Use broadcast controller so multiple listeners can subscribe
    final controller = StreamController<OnlineRoom?>.broadcast();
    int eventCount = 0;

    print('📡 RoomService: Starting listener for room: $roomCode');

    // Use a local subscription to avoid interference in singleton
    StreamSubscription? sub;
    sub = _db
        .child('rooms/$roomCode')
        .onValue
        .listen(
          (event) {
            eventCount++;
            print(
              '📡 RoomService: Firebase event #$eventCount received for $roomCode',
            );
            try {
              if (event.snapshot.exists && event.snapshot.value != null) {
                final dynamic rawValue = event.snapshot.value;
                if (rawValue is Map) {
                  final data = Map<String, dynamic>.from(rawValue);
                  final room = OnlineRoom.fromJson(data);
                  print(
                    '📡 RoomService: Parsed room - status=${room.gameState.status.name}, questions=${room.gameState.questions.length}',
                  );
                  controller.add(room);
                } else {
                  print(
                    '⚠ RoomService: Snapshot value is NOT a Map: ${rawValue.runtimeType}',
                  );
                  // Try to cast anyway if possible, or handle other formats
                }
              } else {
                print(
                  '📡 RoomService: Room $roomCode does not exist or is empty',
                );
                controller.add(null);
              }
            } catch (e, stack) {
              print('❌ RoomService: Mapping error for $roomCode: $e');
              print(stack);
              // Don't close the controller, just log the error
            }
          },
          onError: (error) {
            print('❌ RoomService: Firebase stream error for $roomCode: $error');
            controller.addError(error);
          },
          onDone: () {
            print(
              '📡 RoomService: Firebase stream DONE for $roomCode (eventCount=$eventCount)',
            );
          },
        );

    controller.onCancel = () {
      print(
        '📡 RoomService: Listener cancelled for $roomCode (total events=$eventCount)',
      );
      sub?.cancel();
    };

    return controller.stream;
  }

  /// Update game state (host only)
  Future<void> updateGameState(OnlineGameState state) async {
    if (_currentRoomId == null) return;
    await _db.child('rooms/$_currentRoomId/gameState').set(state.toJson());
  }

  /// Update only specific fields of game state
  Future<void> updateGameStateFields(Map<String, dynamic> fields) async {
    if (_currentRoomId == null) return;
    await _db.child('rooms/$_currentRoomId/gameState').update(fields);
  }

  /// Update player score
  Future<void> updatePlayerScore(String playerId, int score) async {
    if (_currentRoomId == null) return;
    await _db.child('rooms/$_currentRoomId/players/$playerId/score').set(score);
  }

  /// Add a question to the game
  Future<void> addQuestion(OnlineQuestion question) async {
    print('📝 addQuestion called: ${question.text}');
    if (_currentRoomId == null) {
      print('❌ addQuestion: No room ID');
      return;
    }

    try {
      final questionsRef = _db.child(
        'rooms/$_currentRoomId/gameState/questions',
      );
      final snapshot = await questionsRef.get();
      List<dynamic> questions = [];

      if (snapshot.exists && snapshot.value != null) {
        // Firebase may return List or Map depending on array state
        if (snapshot.value is List) {
          questions = List.from(snapshot.value as List);
        } else if (snapshot.value is Map) {
          // Convert Map to List (Firebase sometimes returns arrays as maps)
          final map = snapshot.value as Map;
          questions = map.values.toList();
        }
      }

      questions.add(question.toJson());
      await questionsRef.set(questions);
      print(
        '✅ Question added successfully! Total questions: ${questions.length}',
      );
    } catch (e) {
      print('❌ addQuestion error: $e');
    }
  }

  /// Start a new round (host only helper)
  Future<void> startNewRound({
    required String roomCode,
    required int difficulty,
    required List<String> playerIds,
    int? currentRound,
    int totalRounds = 6,
    int questionsPerTurn = 2,
  }) async {
    print('🎲 Starting new round for room $roomCode (Difficulty: $difficulty)');

    // Pick landmark
    final landmark = await PhotosService().getRandomLandmark(
      difficulty: difficulty,
    );

    if (landmark == null) {
      throw Exception('No landmarks found for difficulty $difficulty');
    }

    // Randomize turns
    final shuffledIds = List<String>.from(playerIds)..shuffle(Random());

    final newState = OnlineGameState(
      currentLandmarkId: landmark.name,
      currentPlayerId: shuffledIds.first,
      currentRound: (currentRound ?? 0) + 1,
      totalRounds: totalRounds,
      difficulty: difficulty,
      questionsPerTurn: questionsPerTurn,
      playerGuesses: {},
      questions: [],
      status: OnlineGameStatus.playing,
    );

    print('📡 Updating Firebase status to PLAYING for $roomCode');
    await _db.child('rooms/$roomCode/gameState').set(newState.toJson());
  }

  /// Submit a guess
  Future<void> submitGuess(String playerId, String country) async {
    if (_currentRoomId == null) return;
    await _db
        .child('rooms/$_currentRoomId/gameState/playerGuesses/$playerId')
        .set(country);
  }

  /// Generate a shareable link for the room
  String generateShareLink(String roomCode) {
    // You can customize this URL to match your app's deep link configuration
    return 'https://whereintheworld.app/join?room=$roomCode';
  }

  /// Check if a room exists
  Future<bool> roomExists(String roomCode) async {
    final snapshot = await _db.child('rooms/$roomCode').get();
    return snapshot.exists;
  }

  /// Get room info without joining
  Future<OnlineRoom?> getRoomInfo(String roomCode) async {
    final snapshot = await _db.child('rooms/$roomCode').get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return OnlineRoom.fromJson(data);
  }

  /// Check if room requires password
  Future<bool> roomRequiresPassword(String roomCode) async {
    final room = await getRoomInfo(roomCode);
    return room?.password != null && room!.password!.isNotEmpty;
  }

  /// Clean up resources
  void dispose() {
    // Controller in listenToRoom handles its own subscription
  }
}
