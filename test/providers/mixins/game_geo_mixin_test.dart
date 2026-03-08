import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/providers/mixins/game_geo_mixin.dart';

/// Concrete class to test the mixin.
class _TestGeo with GameGeoMixin {}

void main() {
  late _TestGeo geo;

  setUp(() {
    geo = _TestGeo();
  });

  group('findNearestGuessPlayer', () {
    test('single guess returns that player', () {
      final result = geo.findNearestGuessPlayer({'p1': 'Germany'}, 'France');
      expect(result, isNotNull);
      expect(result!.playerId, 'p1');
      expect(result.distance, greaterThan(0));
    });

    test('exact correct country returns distance ≈ 0', () {
      final result = geo.findNearestGuessPlayer({'p1': 'France'}, 'France');
      expect(result, isNotNull);
      expect(result!.playerId, 'p1');
      expect(result.distance, closeTo(0, 0.1));
    });

    test('closer guess wins over farther guess', () {
      // Germany is closer to France than Japan
      final result = geo.findNearestGuessPlayer({
        'p1': 'Japan',
        'p2': 'Germany',
      }, 'France');
      expect(result, isNotNull);
      expect(result!.playerId, 'p2');
    });

    test('unknown correct country returns null', () {
      final result = geo.findNearestGuessPlayer({'p1': 'France'}, 'Atlantis');
      expect(result, isNull);
    });

    test('all unknown guesses returns null', () {
      final result = geo.findNearestGuessPlayer({
        'p1': 'Atlantis',
        'p2': 'Narnia',
      }, 'France');
      expect(result, isNull);
    });

    test('empty guesses map returns null', () {
      final result = geo.findNearestGuessPlayer({}, 'France');
      expect(result, isNull);
    });

    test('distance field is plausible (e.g. France→Japan ~9700 km)', () {
      final result = geo.findNearestGuessPlayer({'p1': 'Japan'}, 'France');
      expect(result, isNotNull);
      expect(result!.distance, closeTo(9700, 600));
    });

    test('multiple guesses with one unknown skips invalid', () {
      final result = geo.findNearestGuessPlayer({
        'p1': 'Atlantis',
        'p2': 'Germany',
      }, 'France');
      expect(result, isNotNull);
      expect(result!.playerId, 'p2');
    });
  });
}
