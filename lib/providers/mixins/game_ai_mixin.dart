import '../../models/game_models.dart';
import '../../services/ai_service.dart';

/// Mixin providing shared AI service lazy-initialization and question answering.
mixin GameAIMixin {
  AIService? _aiService;

  /// Lazily initialised AI service.
  AIService get ai {
    try {
      _aiService ??= AIService();
      return _aiService!;
    } catch (e) {
      print('Warning: AI Service initialization issue: $e');
      _aiService ??= AIService(apiKey: 'YOUR_API_KEY_HERE');
      return _aiService!;
    }
  }

  /// Ask the AI a yes/no question about [landmark].
  /// Returns `false` if the AI call fails.
  Future<bool> getAIAnswer(String question, Landmark landmark) async {
    try {
      return await ai.answerQuestion(question, landmark);
    } catch (e) {
      print('AI Error: $e');
      return false;
    }
  }

  /// Update the API key used by the AI service.
  void updateAIApiKey(String apiKey) {
    if (_aiService == null) {
      _aiService = AIService(apiKey: apiKey);
    } else {
      _aiService!.updateApiKey(apiKey);
    }
  }
}
