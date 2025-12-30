# Copilot / AI Agent Instructions for Where In The World

Purpose: Help an AI coding agent become productive quickly in this Flutter repo.

Quick facts
- Project: Flutter app (mobile / web / desktop) — entry: `lib/main.dart`
- State management: `Provider` with central `GameProvider` (`lib/providers/game_provider.dart`)
- AI integration: `lib/services/ai_service.dart` using `google_generative_ai` (Gemini model)
- API key entry points: `.env` (`assets/.env` or `./.env`), environment var `GOOGLE_AI_API_KEY`, `APIConfig.getApiKey()` and `GameProvider.updateAIApiKey()`
- Assets: landmarks images live in `assets/landmarks/` and are registered in `pubspec.yaml`

Big-picture architecture (what to know)
- The app is a single Flutter application with UI screens under `lib/screens/` and small domain models in `lib/models/game_models.dart`.
- `GameProvider` is the canonical source of truth for game state. Methods to focus on: `startGame()`, `askQuestion()`, `makeGuess()`, `proceedToNextRound()`, `updateAIApiKey()`.
- `AIService` is a thin wrapper around `google_generative_ai`'s `GenerativeModel`. It builds a strict prompt (expects ONLY `YES` or `NO`) and contains robust logging and fallback keyword logic.
- Landmark/country data: sample `Landmark` objects are embedded in `GameProvider` (for offline/demo play). A full country list for autocomplete is in `lib/data/countries.dart`.

Important code and patterns (concrete examples)
- API key resolution: `lib/config/api_config.dart::APIConfig.getApiKey()` checks, in order: `.env` (via `flutter_dotenv`), compile-time `--dart-define`, runtime `Platform.environment`, then falls back to the placeholder `YOUR_API_KEY_HERE`.
- .env loading behavior: `lib/main.dart` attempts `assets/.env` first (works for web), then `./.env` (desktop/mobile). For web, keep `.env` in `assets/` and include `assets/.env` in `pubspec.yaml`.
- AI prompt constraints: `lib/services/ai_service.dart::_buildPrompt` instructs the model to reply with a single word `YES` or `NO`. The app parses the first token strictly in `_parseResponse` and defaults to NO on ambiguity. When editing prompts, preserve the required response format.
- Error handling: AI failures fall back to `_fallbackAnswer()` (simple keyword heuristics). Tests/changes that affect scoring or parsing must consider this fallback path.
- Immutability style: `GameState` uses `copyWith(...)` to produce new states (see `lib/models/game_models.dart`). Update state by producing a new `GameState` and then calling `notifyListeners()` in `GameProvider`.

Developer workflows & commands
- Install dependencies: `flutter pub get`
- Run for web: `flutter run -d chrome` (ensure `assets/.env` is included if using web API key file)
- Run for Android/emulator: `flutter run -d android`
- Tests: basic `flutter test` (this repo includes `flutter_test` in dev_dependencies)
- Debugging notes: `AIService` and `APIConfig` print verbose debug info to console — useful when validating API key detection and AI responses.

Project-specific conventions
- API key management: prefer `.env` (assets/.env for web). Do NOT hard-code real API keys into source files; `lib/config/api_config.dart` expects `YOUR_API_KEY_HERE` to be replaced only in local dev flows.
- Prompting: treat the model as a strict boolean oracle. When changing prompt language, maintain the explicit "ONLY a single word: YES or NO" requirement.
- Country names: user-facing country autocomplete uses `lib/data/countries.dart` — avoid normalizing names outside the list unless adding to that file.
- Score update: `makeGuess()` computes scores after all players guess for a round; be careful to update scores in a single `copyWith` to avoid transient inconsistent states.

Integration points to watch when changing code
- `google_generative_ai` usage: model is constructed with `GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: ...)` in `_initializeModel()`.
- `findNearestGuess()` in `AIService` sends a free-form prompt and expects a player key in the response. Changes to player key formatting (currently `Player.id` is `UniqueKey().toString()`) could break parsing.
- `GameProvider._landmarks` currently contains hard-coded sample landmarks referenced by `currentLandmark.imagePath` — updating asset names requires updating `pubspec.yaml` assets and the files under `assets/landmarks/`.

When asked to change behavior, quick checklist
- If modifications touch AI prompts or parsing: run a manual playthrough (web or emulator) and inspect console logs from `AIService` and `APIConfig`.
- If adding new assets: update `pubspec.yaml` assets list and ensure the path matches `imagePath` in `Landmark` entries.
- If changing player ID strategy: update all places that use `Player.id` as a map key (`playerGuesses`, `playerQuestionCounts`, `playersWhoGuessed`) and validate `findNearestGuess()` parsing.

Where to look first for common tasks
- Add a screen: `lib/screens/` and wire route in `lib/main.dart` routes map.
- Add a model change: `lib/models/game_models.dart` then update `GameProvider` to use `copyWith` accordingly.
- Change AI behavior or model: `lib/services/ai_service.dart` and `lib/config/api_config.dart` (for key handling).

If anything in this file is unclear or you'd like additional examples (small PRs, test commands, or sample `.env`), tell me which area to expand and I'll update this doc.
