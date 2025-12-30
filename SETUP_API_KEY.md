# Setting Up Google AI API Key

## Quick Fix: Set API Key in Current Terminal

**In PowerShell (run this BEFORE `flutter run`):**
```powershell
$env:GOOGLE_AI_API_KEY="your-actual-api-key-here"
```

**Then run your app:**
```powershell
flutter run -d chrome
```

## Method 1: Runtime Environment Variable (Quickest for Development)

### Windows PowerShell:
```powershell
# Set it for current session
$env:GOOGLE_AI_API_KEY="your-api-key-here"

# Verify it's set
echo $env:GOOGLE_AI_API_KEY

# Then run Flutter
flutter run -d chrome
```

### Windows CMD:
```cmd
set GOOGLE_AI_API_KEY=your-api-key-here
flutter run -d chrome
```

### Linux/Mac:
```bash
export GOOGLE_AI_API_KEY="your-api-key-here"
flutter run -d chrome
```

**Important**: You must set the variable in the SAME terminal session where you run `flutter run`.

## Method 2: Compile-Time Define (Recommended)

Pass the key directly when running:

```powershell
flutter run -d chrome --dart-define=GOOGLE_AI_API_KEY=your-api-key-here
```

## Method 3: Programmatic (For Runtime Setup)

Add this to your app initialization (e.g., in `main.dart` or when starting the game):

```dart
void main() {
  // Get the API key from somewhere (user input, secure storage, etc.)
  final apiKey = 'your-api-key-here';
  
  runApp(MyApp());
}

// Then in your GameProvider initialization:
context.read<GameProvider>().updateAIApiKey('your-api-key-here');
```

## Method 4: Permanent Windows Environment Variable

To set it permanently (so you don't need to set it each time):

1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Go to "Advanced" tab
3. Click "Environment Variables"
4. Under "User variables", click "New"
5. Variable name: `GOOGLE_AI_API_KEY`
6. Variable value: `your-api-key-here`
7. Click OK

**Note**: You'll need to restart your terminal/IDE after setting permanent variables.

## Debugging

The app now prints detailed debug information when checking for the API key. Look for:
- `=== API KEY DETECTION ===` - Shows what keys were found
- `=== AIService Constructor ===` - Shows the key being used
- `=== Model Initialization ===` - Shows if initialization succeeded

If you see "WARNING: No API key found!", the environment variable isn't being read correctly.

## Get Your API Key

1. Go to https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key






