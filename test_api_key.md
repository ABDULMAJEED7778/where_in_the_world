# Testing Your Google AI API Key Setup

## Step 1: Verify Environment Variable is Set

In your PowerShell terminal, run:
```powershell
$env:GOOGLE_AI_API_KEY
```

If it shows your API key, you're good! If it's empty, set it:
```powershell
$env:GOOGLE_AI_API_KEY="your-actual-api-key-here"
```

**Note**: This sets the variable for the current PowerShell session only. To make it permanent, you can:
- Add it to your Windows User Environment Variables
- Or set it each time you open a new terminal
- Or use `--dart-define` when running Flutter (see Step 2)

## Step 2: Run the App

### Option A: Using Runtime Environment Variable (Current Session)
```powershell
flutter run -d chrome
```
or
```powershell
flutter run -d windows
```

### Option B: Using Compile-Time Define (Recommended for Testing)
```powershell
flutter run -d chrome --dart-define=GOOGLE_AI_API_KEY=your-actual-api-key-here
```

## Step 3: Test the AI Feature

1. Launch the app
2. Add at least 2 players
3. Click "PLAY!"
4. When it's your turn, click "ASK"
5. Type a question like: "Is this landmark in Europe?"
6. Click "Ask AI"
7. You should see "AI is thinking..." and then get a YES/NO answer

## Troubleshooting

If you get an error about API key not configured:
- Make sure you set the environment variable in the SAME terminal where you run `flutter run`
- Or use the `--dart-define` method instead
- Or use the programmatic method: `context.read<GameProvider>().updateAIApiKey('your-key')`
