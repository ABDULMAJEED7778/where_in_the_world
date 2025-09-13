# Where in the World? 🌍

A geography quiz party game built with Flutter where players guess countries from landmark images.

## Game Overview

"Where in the World?" is a multiplayer party game where teams compete to identify countries from landmark images. Players take turns asking yes/no questions and making guesses to determine the correct country.

## Features

- **Multiplayer Support**: 2-8 players can play together
- **Multiple Difficulty Levels**: Easy, Moderate, and Difficult
- **Customizable Rounds**: Set the number of rounds and questions per player
- **Real-time Leaderboard**: Track scores throughout the game
- **Question History**: View previously asked questions and answers
- **Beautiful UI**: Modern design with smooth animations

## How to Play

1. **Setup**: Choose game mode, difficulty, and number of rounds
2. **Add Players**: Add 2-8 players to the game
3. **Ask Questions**: Each player can ask up to 2 yes/no questions per round
4. **Make Guesses**: Players can guess the country at any time
5. **Scoring**: Correct guesses earn 10 points, nearest guesses earn 5 points
6. **Win**: The player with the highest score after all rounds wins!

## Game Rules

- The player who asked the last question has priority to guess
- Cancellation of a guess after pressing the guess button is not allowed
- Players are allowed to directly guess at their turn point in the game
- If no player guesses the right country, the player with the nearest guess gets half points

## Getting Started

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

### Running the App

For web development:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d android
```

## Project Structure

```
lib/
├── models/          # Data models (Player, Question, Landmark, etc.)
├── providers/       # State management (GameProvider)
├── screens/         # UI screens (Launching, Lobby, Main Game)
├── widgets/         # Reusable UI components
└── main.dart        # App entry point

assets/
├── images/          # General app images
└── landmarks/       # Landmark images for the game
```

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **Material Design 3**: Modern UI components
- **Custom Animations**: Smooth transitions and effects

## Future Enhancements

- [ ] Online multiplayer support
- [ ] More landmark categories
- [ ] Sound effects and music
- [ ] Achievement system
- [ ] Custom landmark upload
- [ ] Tournament mode
- [ ] Statistics tracking

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.
