import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/data/countries.dart';

void main() {
  group('allCountries', () {
    test('list is non-empty', () {
      expect(allCountries.isNotEmpty, true);
    });

    test('contains expected countries', () {
      expect(allCountries, contains('United States'));
      expect(allCountries, contains('France'));
      expect(allCountries, contains('Japan'));
      expect(allCountries, contains('Brazil'));
      expect(allCountries, contains('Australia'));
    });

    test('no duplicate entries', () {
      expect(allCountries.length, allCountries.toSet().length);
    });

    test('all entries are non-empty strings', () {
      for (final country in allCountries) {
        expect(country.isNotEmpty, true, reason: 'Found empty country name');
      }
    });

    test('contains at least 190 countries', () {
      expect(allCountries.length, greaterThanOrEqualTo(190));
    });
  });
}
