
class Team {
  final String name;
  final List<Map<String, dynamic>> players;
  final String sportType;
  String? captain;
  String? viceCaptain;

  Team({
    required this.name,
    required this.players,
    required this.sportType,
    this.captain,
    this.viceCaptain,
  });

  // Factory constructor from JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'] ?? '',
      players: List<Map<String, dynamic>>.from(json['players'] ?? []),
      sportType: json['sportType'] ?? '',
      captain: json['captain'],
      viceCaptain: json['viceCaptain'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'players': players,
      'sportType': sportType,
      'captain': captain,
      'viceCaptain': viceCaptain,
    };
  }
}
