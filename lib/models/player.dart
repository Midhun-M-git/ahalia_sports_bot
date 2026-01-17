import 'stats.dart';

class Player {
  final String name;
  final int age;
  final String position;
  final Stats stats;
  final String teamName;

  Player({
    required this.name,
    required this.age,
    required this.position,
    required this.stats,
    required this.teamName,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      position: json['position'] ?? '',
      stats: Stats.fromJson(json['stats'] ?? {}),
      teamName: json['teamName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'position': position,
      'stats': stats.toJson(),
      'teamName': teamName,
    };
  }
}
