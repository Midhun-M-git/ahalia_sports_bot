import 'player.dart';

class FantasyTeam {
  final String name;
  final String captainId;
  final String viceCaptainId;
  final List<Player> players;
  final double totalPoints;
  final int maxPlayers;
  final Map<String, int> positionLimits;

  FantasyTeam({
    required this.name,
    required this.captainId,
    required this.viceCaptainId,
    required this.players,
    required this.totalPoints,
    this.maxPlayers = 11,
    required this.positionLimits,
  });

  bool canAddPlayer(Player player) {
    if (players.length >= maxPlayers) return false;
    
    // Count current players in this position
    int positionCount = players
        .where((p) => p.position == player.position)
        .length;
    
    // Check if adding this player would exceed position limits
    return positionCount < (positionLimits[player.position] ?? 0);
  }

  double calculateTotalPoints() {
    return players.fold(0, (sum, player) {
      double points = player.stats.average;
      if (player.name == captainId) points *= 2;
      if (player.name == viceCaptainId) points *= 1.5;
      return sum + points;
    });
  }
}

class Contest {
  final String name;
  final double entryFee;
  final int totalSpots;
  final int filledSpots;
  final List<Prize> prizes;
  final bool isGuaranteed;

  Contest({
    required this.name,
    required this.entryFee,
    required this.totalSpots,
    required this.filledSpots,
    required this.prizes,
    required this.isGuaranteed,
  });
}

class Prize {
  final int rank;
  final double amount;

  Prize({
    required this.rank,
    required this.amount,
  });
}
