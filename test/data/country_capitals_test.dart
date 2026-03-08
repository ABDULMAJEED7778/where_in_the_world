import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/data/country_capitals.dart';

void main() {
  // ── findCountryCapital ───────────────────────────────────────────────

  group('findCountryCapital', () {
    test('returns correct capital for known country', () {
      final result = findCountryCapital('France');
      expect(result, isNotNull);
      expect(result!.capital, 'Paris');
      expect(result.country, 'France');
    });

    test('is case-insensitive', () {
      final result = findCountryCapital('france');
      expect(result, isNotNull);
      expect(result!.country, 'France');

      final result2 = findCountryCapital('JAPAN');
      expect(result2, isNotNull);
      expect(result2!.capital, 'Tokyo');
    });

    test('returns null for unknown country', () {
      expect(findCountryCapital('Atlantis'), isNull);
    });

    test('returns null for empty string', () {
      expect(findCountryCapital(''), isNull);
    });

    test('finds United States (multi-word country)', () {
      final result = findCountryCapital('United States');
      expect(result, isNotNull);
      expect(result!.capital, 'Washington, D.C.');
    });

    test('finds United Kingdom', () {
      final result = findCountryCapital('United Kingdom');
      expect(result, isNotNull);
      expect(result!.capital, 'London');
    });
  });

  // ── calculateDistance ────────────────────────────────────────────────

  group('calculateDistance', () {
    test('same point returns 0', () {
      final d = calculateDistance(51.5074, -0.1278, 51.5074, -0.1278);
      expect(d, closeTo(0, 0.001));
    });

    test('London to Paris is a short distance (~300-400 km)', () {
      final d = calculateDistance(51.5074, -0.1278, 48.8566, 2.3522);
      expect(d, greaterThan(250));
      expect(d, lessThan(500));
    });

    test('relative ordering: nearby < far away', () {
      // France→Germany should be shorter than France→Japan
      final shortDist = calculateDistance(48.8566, 2.3522, 52.5200, 13.4050);
      final longDist = calculateDistance(48.8566, 2.3522, 35.6762, 139.6503);
      expect(shortDist, lessThan(longDist));
    });

    test('distance is always non-negative', () {
      final d = calculateDistance(38.8951, -77.0369, 51.5074, -0.1278);
      expect(d, greaterThanOrEqualTo(0));
    });

    test('distance is symmetric', () {
      final d1 = calculateDistance(51.5, -0.1, 48.9, 2.4);
      final d2 = calculateDistance(48.9, 2.4, 51.5, -0.1);
      expect(d1, closeTo(d2, 0.001));
    });

    test('equator crossing gives reasonable distance', () {
      // Nairobi: -1.2865, 36.8172  London: 51.5074, -0.1278
      final d = calculateDistance(-1.2865, 36.8172, 51.5074, -0.1278);
      expect(d, greaterThan(3000));
    });
  });

  // ── CountryCapital data integrity ────────────────────────────────────

  group('countryCapitals data', () {
    test('list is non-empty', () {
      expect(countryCapitals.isNotEmpty, true);
    });

    test('all entries have valid latitude range (-90 to 90)', () {
      for (final cc in countryCapitals) {
        expect(
          cc.latitude,
          inInclusiveRange(-90, 90),
          reason: '${cc.country} latitude ${cc.latitude} out of range',
        );
      }
    });

    test('all entries have valid longitude range (-180 to 180)', () {
      for (final cc in countryCapitals) {
        expect(
          cc.longitude,
          inInclusiveRange(-180, 180),
          reason: '${cc.country} longitude ${cc.longitude} out of range',
        );
      }
    });

    test('all entries have non-empty country and capital names', () {
      for (final cc in countryCapitals) {
        expect(cc.country.isNotEmpty, true);
        expect(cc.capital.isNotEmpty, true);
      }
    });

    test('has at least 190 unique countries', () {
      final uniqueCountries = countryCapitals
          .map((cc) => cc.country.toLowerCase())
          .toSet();
      expect(uniqueCountries.length, greaterThanOrEqualTo(190));
    });
  });
}
