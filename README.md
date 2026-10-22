# Ahalia Sports Bot

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4E73DF?style=for-the-badge)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

A campus sports event coordination and tournament management mobile application built for Ahalia college athletics. Provides live match fixture scheduling, department scoring tables, and athlete registries.

---

## Event Management Pipeline

```mermaid
graph TD
    Admin[Athletics Committee Admin] --> EventConfig[Event Creation and Fixture Generation]
    EventConfig --> Bracket[Single and Double Elimination Tournament Brackets]
    Bracket --> Schedule[Venue and Time Slot Allocation]
    
    Schedule --> CentralStore[(Event Data Registry)]
    CentralStore --> LiveMatch[Scoring Officials Live Score Entry]
    LiveMatch --> PointTable[Dynamic Department Leaderboard Calculation]
    
    CentralStore --> StudentApp[Student and Athlete Mobile Interface]
    PointTable --> StudentApp
```

---

## Features

- **Tournament Bracket Generation**: Automated round-robin and knockout tournament scheduling for college sports.
- **Live Scoreboard Updates**: Real-time point tracking for football, cricket, badminton, and track events.
- **Departmental Point Standings**: Cumulative points calculation across academic departments for overall trophies.
- **Athlete Registration**: Direct verification of student participants by department and college ID.
- **Venue and Schedule Notifications**: Clear timetable tracking venue, court assignment, and start times.

---

## Tech Stack

| Component | Technology |
| :--- | :--- |
| Frontend | Flutter (Dart) |
| Architecture | Feature-First Clean Separation |
| State Management | Provider |
| Persistence | Local Storage & REST API Integrations |

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/Midhun-M-git/ahalia_sports_bot.git
   cd ahalia_sports_bot
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Launch on device or emulator:
   ```bash
   flutter run
   ```

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
