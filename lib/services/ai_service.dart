import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/game_models.dart';
import '../config/api_config.dart';

class AIService {
  GenerativeModel? _model;
  late String _apiKey;

  AIService({String? apiKey}) {
    _apiKey = apiKey ?? APIConfig.getApiKey();
    print('\n=== AIService Constructor ===');
    print('API key provided directly: ${apiKey != null}');
    if (apiKey != null) {
      print('Direct API key length: ${apiKey.length}');
      print(
        'Direct API key preview: ${apiKey.length > 10 ? "${apiKey.substring(0, 10)}..." : apiKey}',
      );
    } else {
      print('Using APIConfig.getApiKey()');
      print('Retrieved API key length: ${_apiKey.length}');
      print(
        'Retrieved API key preview: ${_apiKey.length > 10 ? "${_apiKey.substring(0, 10)}..." : _apiKey}',
      );
      print('Is placeholder: ${_apiKey == "YOUR_API_KEY_HERE"}');
    }
    print('==============================\n');
  }

  GenerativeModel get _modelInstance {
    if (_model == null) {
      _initializeModel();
    }
    return _model!;
  }

  void _initializeModel() {
    print('\n=== Model Initialization ===');
    print('API key length: ${_apiKey.length}');
    print('API key is empty: ${_apiKey.isEmpty}');
    print('API key is placeholder: ${_apiKey == "YOUR_API_KEY_HERE"}');

    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      print('ERROR: Invalid API key!');
      print('==========================\n');
      throw Exception(
        'Google AI API key not configured. Please set your API key using GameProvider.updateAIApiKey() or set the GOOGLE_AI_API_KEY environment variable.',
      );
    }

    // Use Gemini Pro for text generation
    print('Initializing GenerativeModel with API key...');
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);
    print('Model initialized successfully!');
    print('==============================\n');
  }

  /// Updates the API key and reinitializes the model
  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
    _model = null; // Reset model to force reinitialization on next use
  }

  /// Answers a yes/no question about a landmark using AI
  /// Returns true for YES, false for NO
  Future<bool> answerQuestion(String question, Landmark landmark) async {
    try {
      final prompt = _buildPrompt(question, landmark);

      // Debug: Print the prompt being sent
      print('\n=== AI REQUEST ===');
      print('Landmark: ${landmark.name}');
      print('Country: ${landmark.country}');
      print('Question: $question');
      print('Prompt sent to AI:');
      print(prompt);
      print('==================\n');

      final response = await _modelInstance.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        print('ERROR: AI returned empty response');
        throw Exception('AI returned empty response');
      }

      // Debug: Print the full AI response
      print('\n=== AI RESPONSE ===');
      print('Full response: "${response.text}"');
      print('Response length: ${response.text!.length}');
      print('==================\n');

      final parsedAnswer = _parseResponse(response.text!);

      // Debug: Print the parsed result
      print('Parsed answer: ${parsedAnswer ? "YES" : "NO"}');
      print('=========================\n');

      return parsedAnswer;
    } catch (e) {
      print('\n=== AI ERROR ===');
      print('Error: $e');
      print('Using fallback answer method');
      print('==================\n');
      // Fallback: try to answer based on simple keyword matching
      return _fallbackAnswer(question, landmark);
    }
  }

  /// Builds a prompt for the AI to answer the question
  String _buildPrompt(String question, Landmark landmark) {
    return '''You are an expert geography assistant for a quiz game. Your task is to answer yes/no questions about countries.

CONTEXT:
- This landmark is located in the country: ${landmark.country}
- Players are asking questions about the COUNTRY (${landmark.country})

QUESTION TO ANSWER: $question

CRITICAL INSTRUCTIONS:
1. Interpret the question as being about the country ${landmark.country}
2. Use your knowledge of the geography, location, climate, borders, and characteristics of ${landmark.country}
3. Answer ONLY based on factual information about ${landmark.country}
4. If the question is ambiguous or could refer to the landmark, interpret it as being about the country
5. SPECIAL RULE FOR CONTINENTS: If a country is transcontinental (located in two continents) or is geographically in one but geopolitically/culturally in another, answer YES for ANY of the associated continents.
   - Example: Turkey is in Asia and Europe. Answer YES for "Is it in Asia?" AND "Is it in Europe?".
   - Example: Armenia is geographically in Asia but geopolitically in Europe. Answer YES for both.
6. Examples:
   - "Is it in Europe?" → Answer about whether ${landmark.country} is in Europe
   - "Does it have a coast?" → Answer about whether ${landmark.country} has a coastline
   - "Is it in the Northern Hemisphere?" → Answer about ${landmark.country}'s location
   - "Is it a large country?" → Answer about ${landmark.country}'s size

RESPONSE FORMAT:
You MUST respond with ONLY a single word: either "YES" or "NO" (all caps, nothing else).
Do NOT include any explanation, reasoning, or additional text.

Your answer:''';
  }

  /// Parses the AI response to extract YES/NO answer
  bool _parseResponse(String response) {
    final normalizedResponse = response.trim().toUpperCase();

    print('\n=== PARSING RESPONSE ===');
    print('Original: "$response"');
    print('Normalized: "$normalizedResponse"');

    // Extract the first word or check for YES/NO in the response
    final words = normalizedResponse
        .split(
          RegExp(
            r'[\s\n\r\t.,;:!?()\[\]{}"\-'
            ']+',
          ),
        )
        .where((w) => w.isNotEmpty)
        .toList();

    print('Words extracted: $words');

    if (words.isEmpty) {
      print('WARNING: No words found, defaulting to NO');
      return false;
    }

    // Check first word (most reliable)
    final firstWord = words[0];
    print('First word: "$firstWord"');

    // Check for YES variations
    if (firstWord == 'YES' ||
        firstWord == 'Y' ||
        firstWord == 'TRUE' ||
        firstWord == 'CORRECT' ||
        firstWord == 'AFFIRMATIVE' ||
        normalizedResponse.startsWith('YES') ||
        normalizedResponse.startsWith('Y ')) {
      print('Parsed as: YES');
      return true;
    }

    // Check for NO variations
    if (firstWord == 'NO' ||
        firstWord == 'N' ||
        firstWord == 'FALSE' ||
        firstWord == 'INCORRECT' ||
        firstWord == 'NEGATIVE' ||
        normalizedResponse.startsWith('NO') ||
        normalizedResponse.startsWith('N ')) {
      print('Parsed as: NO');
      return false;
    }

    // Check if response contains YES or NO anywhere
    if (normalizedResponse.contains('YES') &&
        !normalizedResponse.contains('NO')) {
      print('Found "YES" in response, parsed as: YES');
      return true;
    }

    if (normalizedResponse.contains('NO') &&
        !normalizedResponse.contains('YES')) {
      print('Found "NO" in response, parsed as: NO');
      return false;
    }

    // Default to NO if unclear
    print('WARNING: Could not parse response clearly, defaulting to NO');
    return false;
  }

  /// Fallback answer method using simple keyword matching
  /// This is used when AI call fails
  /// Answers are about the COUNTRY, not the landmark
  bool _fallbackAnswer(String question, Landmark landmark) {
    final questionLower = question.toLowerCase();
    final countryName = landmark.country.toLowerCase();

    // Check if question directly mentions the country name
    if (questionLower.contains(countryName)) {
      return true;
    }

    // Check common country name variations
    if (countryName == 'united states' || countryName == 'usa') {
      if (questionLower.contains('america') ||
          questionLower.contains('united states') ||
          questionLower.contains('usa') ||
          questionLower.contains('us')) {
        return true;
      }
    }

    // Check continent-based questions (about the country's continent)
    final continents = {
      'tanzania': 'africa',
      'france': 'europe',
      'china': 'asia',
      'peru': 'south america',
      'india': 'asia',
    };

    final continent = continents[landmark.country.toLowerCase()];
    if (continent != null && questionLower.contains(continent)) {
      return true;
    }

    // Check for regional/country-specific questions
    if (questionLower.contains('country') || questionLower.contains('nation')) {
      // If question asks about country/nation and we can't match, default to false
      // This helps with questions like "Is it a large country?" - we can't answer without AI
    }

    // Default to false for unknown questions (since we can't match country-specific info)
    return false;
  }

  /// Determines which player's guess is nearest to the correct country
  /// This can be used for scoring when no one guesses correctly
  Future<String?> findNearestGuess(
    Landmark landmark,
    Map<String, String> playerGuesses,
  ) async {
    try {
      final prompt =
          '''
You are a geography game assistant. Given the correct country "${landmark.country}", 
determine which of these player guesses is geographically nearest:

${playerGuesses.entries.map((e) => '${e.key}: ${e.value}').join('\n')}

Respond with ONLY the player key of the nearest guess, or "NONE" if all are equally distant.
Answer:''';

      final response = await _modelInstance.generateContent([
        Content.text(prompt),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        final answer = response.text!.trim();
        if (playerGuesses.containsKey(answer)) {
          return answer;
        }
      }
    } catch (e) {
      // Fallback: return first guess or null
    }

    return playerGuesses.keys.isNotEmpty ? playerGuesses.keys.first : null;
  }
}
