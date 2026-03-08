import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/providers/mixins/game_ai_mixin.dart';

/// Concrete class to test the mixin.
class _TestAI with GameAIMixin {}

void main() {
  group('GameAIMixin', () {
    test('ai getter returns a non-null AIService instance', () {
      final ai = _TestAI();
      // Accessing `ai` should lazily create the service
      expect(ai.ai, isNotNull);
    });

    test('repeated calls to ai getter return same instance', () {
      final t = _TestAI();
      final first = t.ai;
      final second = t.ai;
      expect(identical(first, second), true);
    });

    test('updateAIApiKey before any usage creates service', () {
      final t = _TestAI();
      // Should not throw
      t.updateAIApiKey('test-key-123');
      expect(t.ai, isNotNull);
    });

    test('updateAIApiKey after usage updates existing service', () {
      final t = _TestAI();
      final _ = t.ai; // force lazy init
      // Should not throw
      t.updateAIApiKey('new-key-456');
      expect(t.ai, isNotNull);
    });
  });
}
