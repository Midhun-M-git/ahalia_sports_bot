import 'team.dart';

class PlayerPerformance {
  final String playerName;
  final String position;
  final Map<String, dynamic> stats;

  PlayerPerformance({
    required this.playerName,
    required this.position,
    required this.stats,
  });
}

class Match {
  final Team homeTeam;
  final Team awayTeam;
  final String venue;
  final DateTime dateTime;
  final String sportType;
  bool isLive;
  final Map<String, int> score;
  final List<String> commentary;
  final List<PlayerPerformance> homeTeamPerformance;
  final List<PlayerPerformance> awayTeamPerformance;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.venue,
    required this.dateTime,
    required this.sportType,
    this.isLive = false,
  })  : score = {'home': 0, 'away': 0},
        commentary = [],
        homeTeamPerformance = [],
        awayTeamPerformance = [];

  void incrementScore(String team) {
    if (score.containsKey(team)) {
      score[team] = (score[team] ?? 0) + 1;
    }
  }

  void updateScore(String team, int points) {
    if (score.containsKey(team)) {
      score[team] = (score[team] ?? 0) + points;
    }
  }

  void addCommentary(String comment) {
    commentary.insert(0, comment);
  }

  void updatePlayerPerformance(String team, PlayerPerformance performance) {
    final performances = team == 'home' ? homeTeamPerformance : awayTeamPerformance;
    
    // Try to find existing player performance
    final existingIndex = performances.indexWhere(
      (p) => p.playerName == performance.playerName,
    );

    if (existingIndex != -1) {
      // Update existing player's stats
      final existing = performances[existingIndex];
      final updatedStats = Map<String, dynamic>.from(existing.stats);
      
      performance.stats.forEach((key, value) {
        if (updatedStats.containsKey(key)) {
          updatedStats[key] = (updatedStats[key] as num) + (value as num);
        } else {
          updatedStats[key] = value;
        }
      });

      performances[existingIndex] = PlayerPerformance(
        playerName: existing.playerName,
        position: existing.position,
        stats: updatedStats,
      );
    } else {
      // Add new player performance
      performances.add(performance);
    }
  }

  Map<String, dynamic> getInitialStats(String sportType) {
    if (sportType == 'cricket') {
      return {
        'runs': 0,
        'balls': 0,
        'wickets': 0,
        'fours': 0,
        'sixes': 0,
        'economy': 0.0,
      };
    } else {
      return {
        'goals': 0,
        'assists': 0,
        'shots': 0,
        'passes': 0,
        'tackles': 0,
        'saves': 0,
      };
    }
  }
}
