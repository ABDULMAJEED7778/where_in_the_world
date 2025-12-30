import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_models.dart';

class PhotosService {
  static final PhotosService _instance = PhotosService._internal();

  factory PhotosService() {
    return _instance;
  }

  PhotosService._internal();

  List<Landmark>? _cachedLandmarks;
  bool _isLoading = false;

  /// Load landmarks from photos_data.json
  Future<List<Landmark>> loadLandmarks() async {
    if (_cachedLandmarks != null) {
      return _cachedLandmarks!;
    }

    if (_isLoading) {
      // If already loading, wait a bit and try again
      await Future.delayed(const Duration(milliseconds: 100));
      return loadLandmarks();
    }

    _isLoading = true;

    try {
      // Load the JSON file
      final jsonString = await rootBundle.loadString(
        'lib/data/photos_data.json',
      );
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Convert JSON to Landmark objects
      _cachedLandmarks = jsonData
          .map(
            (item) => Landmark(
              name: item['country'] ?? 'Unknown',
              country: item['country'] ?? 'Unknown',
              imagePath: item['imageUrl'] ?? '',
              description: item['funFact'] ?? '',
              difficulty: item['difficulty'] is int ? item['difficulty'] : 1,
            ),
          )
          .toList();

      _isLoading = false;
      return _cachedLandmarks!;
    } catch (e) {
      _isLoading = false;
      print('Error loading landmarks: $e');
      rethrow;
    }
  }

  /// Get a random landmark from the cached data
  Future<Landmark?> getRandomLandmark({
    List<String>? excludeLandmarkIds,
    int? difficulty,
  }) async {
    try {
      final landmarks = await loadLandmarks();
      if (landmarks.isEmpty) return null;

      // Filter out excluded landmarks if provided
      List<Landmark> available = landmarks;

      // Filter by difficulty if provided
      if (difficulty != null) {
        available = available.where((l) => l.difficulty == difficulty).toList();
        // If no landmarks match the exact difficulty, fallback to all (or maybe nearby difficulties?)
        // For now, let's strictly enforce it, but if empty, maybe fallback to all to avoid crashing.
        if (available.isEmpty) {
          print(
            'No landmarks found for difficulty $difficulty. Falling back to all.',
          );
          available = landmarks;
        }
      }

      if (excludeLandmarkIds != null && excludeLandmarkIds.isNotEmpty) {
        available = available
            .where((l) => !excludeLandmarkIds.contains(l.name))
            .toList();
      }

      if (available.isEmpty) {
        // If all landmarks are excluded, reset and get any random landmark (respecting difficulty if possible)
        available = landmarks;
        if (difficulty != null) {
          available = available
              .where((l) => l.difficulty == difficulty)
              .toList();
          if (available.isEmpty) available = landmarks;
        }
      }

      available.shuffle();
      return available.first;
    } catch (e) {
      print('Error getting random landmark: $e');
      return null;
    }
  }

  /// Get a landmark by its ID (name)
  Future<Landmark?> getLandmarkById(String landmarkId) async {
    try {
      final landmarks = await loadLandmarks();
      return landmarks.firstWhere(
        (l) => l.name == landmarkId,
        orElse: () => landmarks.first,
      );
    } catch (e) {
      print('Error getting landmark by ID: $e');
      return null;
    }
  }

  /// Get all landmarks
  Future<List<Landmark>> getAllLandmarks() async {
    return loadLandmarks();
  }

  /// Get landmarks by country
  Future<List<Landmark>> getLandmarksByCountry(String country) async {
    try {
      final landmarks = await loadLandmarks();
      return landmarks
          .where(
            (landmark) =>
                landmark.country.toLowerCase() == country.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('Error getting landmarks by country: $e');
      return [];
    }
  }

  /// Clear cache (useful for testing or refreshing)
  void clearCache() {
    _cachedLandmarks = null;
  }
}
