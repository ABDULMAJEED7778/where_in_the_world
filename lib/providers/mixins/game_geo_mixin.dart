import '../../data/country_capitals.dart';

/// Mixin providing the shared "nearest guess" geographic calculation.
///
/// Both [GameProvider] and [OnlineGameProvider] need to find which player's
/// guess is geographically closest to the correct country.
mixin GameGeoMixin {
  /// Find the player whose guess is geographically nearest to [correctCountry].
  ///
  /// Returns a record with the player ID and distance in km,
  /// or `null` if no valid guess could be resolved.
  ({String playerId, double distance})? findNearestGuessPlayer(
    Map<String, String> guesses,
    String correctCountry,
  ) {
    final correctCapital = findCountryCapital(correctCountry);
    if (correctCapital == null) {
      print('Could not find capital for correct country: $correctCountry');
      return null;
    }

    double nearestDistance = double.infinity;
    String? nearestPlayerId;

    for (final entry in guesses.entries) {
      final guessCapital = findCountryCapital(entry.value);
      if (guessCapital == null) {
        print('Could not find capital for guessed country: ${entry.value}');
        continue;
      }

      final distance = calculateDistance(
        correctCapital.latitude,
        correctCapital.longitude,
        guessCapital.latitude,
        guessCapital.longitude,
      );

      print(
        'Distance from ${entry.value} to $correctCountry: ${distance.toStringAsFixed(2)} km',
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestPlayerId = entry.key;
      }
    }

    if (nearestPlayerId != null) {
      return (playerId: nearestPlayerId, distance: nearestDistance);
    }

    return null;
  }
}
