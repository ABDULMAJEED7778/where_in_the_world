# Where in the World? 🌍

A geography quiz party game built with Flutter where players guess countries from landmark images.

---

## 📸 Screenshots

<table>
  <tr>
    <td align="center"><b>Launch Screen</b></td>
    <td align="center"><b>Mode Selection</b></td>
    <td align="center"><b>Game Lobby</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/launch_screen.png" alt="Launch Screen" width="250"/></td>
    <td><img src="screenshots/mode_selection.png" alt="Mode Selection" width="250"/></td>
    <td><img src="screenshots/game_lobby.png" alt="Game Lobby" width="250"/></td>
  </tr>
  <tr>
    <td align="center"><b>Main Game</b></td>
    <td align="center"><b>Answer Dialog</b></td>
    <td align="center"><b>Leaderboard</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/main_game.png" alt="Main Game" width="250"/></td>
    <td><img src="screenshots/answer_dialog.png" alt="Answer Dialog" width="250"/></td>
    <td><img src="screenshots/leaderboard.png" alt="Leaderboard" width="250"/></td>
  </tr>
  <tr>
    <td align="center"><b>Online Lobby</b></td>
    <td align="center"><b>Room Creation</b></td>
    <td align="center"><b>Settings</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/online_lobby.png" alt="Online Lobby" width="250"/></td>
    <td><img src="screenshots/room_creation.png" alt="Room Creation" width="250"/></td>
    <td><img src="screenshots/settings.png" alt="Settings" width="250"/></td>
  </tr>
</table>

> 📝 **Note**: Add your screenshots to the `screenshots/` folder with the names shown above.

---

## 🎮 Game Overview

"Where in the World?" is a multiplayer party game where teams compete to identify countries from landmark images. Players take turns asking yes/no questions and making guesses to determine the correct country.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎭 **Multiple Game Modes** | Single Player, Party Mode, and Online Multiplayer |
| 👥 **Multiplayer Support** | 2-8 players can play together |
| 🎯 **Difficulty Levels** | Easy, Moderate, and Difficult |
| 🎲 **Customizable Rounds** | Set the number of rounds and questions per player |
| 🤖 **AI-Powered Answers** | Uses Google AI (Gemini) to answer yes/no questions |
| 📊 **Real-time Leaderboard** | Track scores throughout the game |
| 📝 **Question History** | View previously asked questions and answers |
| 🎵 **Audio System** | Background music and sound effects |
| 🎨 **Beautiful UI** | Modern glassmorphism design with smooth animations |

---

## 🔄 Application Flow

### Overall Game Flow

```mermaid
flowchart TD
    A[🚀 Launch Screen] --> B{Select Mode}
    B -->|Single Player| C[🎮 Game Lobby<br/>Single Player]
    B -->|Party Mode| D[🎭 Game Lobby<br/>Multiplayer]
    B -->|Online| E[🌐 Online Options]
    
    E --> F[Create Room]
    E --> G[Join Room]
    F --> H[🏠 Online Lobby<br/>Host]
    G --> H
    
    C --> I[⚙️ Configure Game]
    D --> I
    H --> I
    
    I --> J[▶️ Start Game]
    J --> K[🎯 Main Game Screen]
    K --> L{Round in Progress}
    
    L -->|Ask Question| M[❓ AI Answers]
    M --> L
    L -->|Make Guess| N{Correct?}
    
    N -->|Yes| O[🎉 Award Points]
    N -->|No| P[❌ Wrong Guess]
    
    O --> Q{More Rounds?}
    P --> Q
    
    Q -->|Yes| R[🔄 Next Round]
    R --> L
    Q -->|No| S[🏆 Game End Screen]
    S --> T[📊 Final Leaderboard]
    T --> A
```

### Turn-Based Gameplay Flow

```mermaid
flowchart LR
    subgraph Turn["🎯 Player Turn"]
        A[Player's Turn] --> B{Choose Action}
        B -->|Ask| C[Type Question]
        B -->|Guess| F[Select Country]
        C --> D[🤖 AI Response]
        D --> E{Questions Left?}
        E -->|Yes| B
        E -->|No| F
        F --> G{Correct?}
        G -->|Yes| H[🎉 +10 Points]
        G -->|No| I[Next Player]
    end
```

### Online Multiplayer Flow

```mermaid
flowchart TD
    subgraph Host["🏠 Host"]
        A1[Create Room] --> B1[Get Room Code]
        B1 --> C1[Share Code]
        C1 --> D1[Wait for Players]
        D1 --> E1[Start Game]
    end
    
    subgraph Player["👤 Player"]
        A2[Enter Room Code] --> B2[Join Room]
        B2 --> C2[Wait in Lobby]
        C2 --> D2[Game Starts]
    end
    
    subgraph Game["🎮 Online Game"]
        E1 --> F[Synchronized Gameplay]
        D2 --> F
        F --> G[Real-time Updates]
        G --> H[All Players See Same State]
    end
```

---

## 🎯 Scoring System

```mermaid
flowchart TD
    A[🎯 Player Makes Guess] --> B{Is it Correct?}
    B -->|Yes| C[🎉 Correct Guess<br/>+10 Points]
    B -->|No| D{End of Round?}
    D -->|No| E[Continue Round]
    D -->|Yes| F{Any Correct Guess?}
    F -->|Yes| G[✅ Points Awarded]
    F -->|No| H[🥈 Nearest Guess<br/>+5 Points]
    
    C --> I[📊 Update Leaderboard]
    H --> I
    G --> I
```

---

## 📱 Screen Navigation

```mermaid
stateDiagram-v2
    [*] --> LaunchScreen
    LaunchScreen --> ModeSelection
    
    ModeSelection --> SinglePlayerLobby: Single Player
    ModeSelection --> PartyModeLobby: Party Mode
    ModeSelection --> OnlineOptions: Online
    
    OnlineOptions --> CreateRoom
    OnlineOptions --> JoinRoom
    CreateRoom --> OnlineLobby
    JoinRoom --> OnlineLobby
    
    SinglePlayerLobby --> MainGame
    PartyModeLobby --> MainGame
    OnlineLobby --> OnlineGame
    
    MainGame --> GameEnd
    OnlineGame --> GameEnd
    
    GameEnd --> LaunchScreen
    GameEnd --> ModeSelection: Play Again
```

---

## 🎲 How to Play

1. **🚀 Setup**: Choose game mode, difficulty, and number of rounds
2. **👥 Add Players**: Add 2-8 players to the game (or just yourself for single player)
3. **❓ Ask Questions**: Each player can ask up to 2 yes/no questions per round. The AI will answer based on the landmark information.
4. **🌍 Make Guesses**: Players can guess the country at any time
5. **🏆 Scoring**: Correct guesses earn 10 points, nearest guesses earn 5 points
6. **🎉 Win**: The player with the highest score after all rounds wins!

---

## 📜 Game Rules

- 🎯 The player who asked the last question has priority to guess
- ❌ Cancellation of a guess after pressing the guess button is not allowed
- ✅ Players are allowed to directly guess at their turn point in the game
- 🥈 If no player guesses the right country, the player with the nearest guess gets half points

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Chrome browser (for web development)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Google AI API Setup

The game uses Google AI (Gemini) to answer questions about landmarks. You need to set up an API key:

1. **Get a Google AI API Key**:
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Create API Key"
   - Copy your API key

2. **Configure the API Key** (choose one method):

   **Method 1: Environment Variable (Recommended)**
   ```bash
   # Windows PowerShell
   $env:GOOGLE_AI_API_KEY="your-api-key-here"
   
   # Linux/Mac
   export GOOGLE_AI_API_KEY="your-api-key-here"
   ```

   **Method 2: Programmatically**
   ```dart
   // In your app initialization
   context.read<GameProvider>().updateAIApiKey('your-api-key-here');
   ```

   **Method 3: Update config file**
   - Edit `lib/config/api_config.dart` and replace `YOUR_API_KEY_HERE` with your actual API key
   - ⚠️ **Not recommended for production** - this exposes your key in code

### Running the App

For web development:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d android
```

---

## 📁 Project Structure

```
lib/
├── config/          # Configuration (API keys, etc.)
├── data/            # Static data (countries, landmarks)
├── models/          # Data models (Player, Question, Landmark, etc.)
├── providers/       # State management (GameProvider, OnlineGameProvider)
├── screens/         # UI screens
│   ├── launching_screen.dart
│   ├── mode_selection_screen.dart
│   ├── game_lobby_screen.dart
│   ├── main_game_screen.dart
│   ├── online_lobby_screen.dart
│   ├── online_game_screen.dart
│   ├── create_room_screen.dart
│   └── join_room_screen.dart
├── services/        # Services (AI, Audio, Room, Photos)
├── widgets/         # Reusable UI components
├── utils/           # Utility functions (responsive helpers)
└── main.dart        # App entry point

assets/
├── images/          # General app images
├── landmarks/       # Landmark images for the game
├── lotties/         # Lottie animation files
└── sounds/          # Audio files (music & effects)

screenshots/         # App screenshots (for README)
```

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Provider** | State management |
| **Firebase** | Backend for online multiplayer |
| **Google AI (Gemini)** | AI-powered question answering |
| **Lottie** | Beautiful animations |
| **Material Design 3** | Modern UI components |

---

## 🗺️ Architecture Diagram

```mermaid
flowchart TB
    subgraph UI["📱 UI Layer"]
        S1[Screens]
        W1[Widgets]
    end
    
    subgraph State["🔄 State Management"]
        P1[GameProvider]
        P2[OnlineGameProvider]
    end
    
    subgraph Services["⚙️ Services Layer"]
        AI[AI Service]
        Audio[Audio Service]
        Room[Room Service]
        Photos[Photos Service]
    end
    
    subgraph External["☁️ External"]
        Gemini[Google Gemini AI]
        Firebase[Firebase Realtime DB]
    end
    
    UI --> State
    State --> Services
    AI --> Gemini
    Room --> Firebase
```

---

## 🚧 Future Enhancements

- [x] ~~Online multiplayer support~~
- [x] ~~Sound effects and music~~
- [ ] More landmark categories
- [ ] Achievement system
- [ ] Custom landmark upload
- [ ] Tournament mode
- [ ] Statistics tracking
- [ ] Localization (multiple languages)

---

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the MIT License.

---

<p align="center">
  Made with ❤️ and Flutter
</p>
