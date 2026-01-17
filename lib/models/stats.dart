class Stats {
  final int? matches;
  final int runs;
  final int wickets;
  final double average;
  final double? strikeRate;
  final double? economy;
  final int? catches;
  final int? stumpings;
  // Add other relevant stats

  Stats({
    this.matches,
    required this.runs,
    required this.wickets,
    required this.average,
    this.strikeRate,
    this.economy,
    this.catches,
    this.stumpings,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      matches: json['matches'],
      runs: json['runs'] ?? 0,
      wickets: json['wickets'] ?? 0,
      average: json['average']?.toDouble() ?? 0.0,
      strikeRate: json['strikeRate']?.toDouble(),
      economy: json['economy']?.toDouble(),
      catches: json['catches'],
      stumpings: json['stumpings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matches': matches,
      'runs': runs,
      'wickets': wickets,
      'average': average,
      'strikeRate': strikeRate,
      'economy': economy,
      'catches': catches,
      'stumpings': stumpings,
    };
  }
} 