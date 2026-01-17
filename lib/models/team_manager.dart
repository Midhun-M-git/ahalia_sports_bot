import 'team.dart';
import 'match.dart' as sports;
import 'fixture.dart';

class TeamManager {
  static final TeamManager _instance = TeamManager._internal();
  
  factory TeamManager() {
    return _instance;
  }
  
  TeamManager._internal();

  final List<Team> _teams = [];
  final List<Fixture> _fixtures = [];
  final List<String> _venues = [];
  sports.Match? _currentMatch;

  List<Team> getTeams() => List.from(_teams);
  List<Fixture> getFixtures() => List.from(_fixtures);
  List<String> getVenues() => List.from(_venues);
  sports.Match? getCurrentMatch() => _currentMatch;

  void addVenue(String venue) {
    if (!_venues.contains(venue)) {
      _venues.add(venue);
    }
  }

  void addTeam(Team team) {
    if (!_teams.any((t) => t.name.toLowerCase() == team.name.toLowerCase())) {
      _teams.add(team);
      if (_teams.length >= 2) {
        _generateFixtures();
      }
    }
  }

  void setCurrentMatch(sports.Match match) {
    _currentMatch = match;
  }

  void _generateFixtures() {
    _fixtures.clear();
    DateTime fixtureDate = DateTime.now().add(const Duration(days: 1));
    fixtureDate = DateTime(
      fixtureDate.year,
      fixtureDate.month,
      fixtureDate.day,
      14, // 2 PM
      0,
    );

    // Generate home and away fixtures for each team pair
    for (int i = 0; i < _teams.length; i++) {
      for (int j = i + 1; j < _teams.length; j++) {
        // Home fixture
        String homeMatchCode;
        do {
          homeMatchCode = Fixture.generateMatchCode();
        } while (_fixtures.any((f) => f.matchCode == homeMatchCode));

        _fixtures.add(
          Fixture(
            homeTeam: _teams[i],
            awayTeam: _teams[j],
            venue: _venues.isEmpty ? 'TBD' : _venues[_fixtures.length % _venues.length],
            dateTime: fixtureDate,
            status: 'upcoming',
            matchCode: homeMatchCode,
          ),
        );
        fixtureDate = fixtureDate.add(const Duration(days: 7));

        // Away fixture
        String awayMatchCode;
        do {
          awayMatchCode = Fixture.generateMatchCode();
        } while (_fixtures.any((f) => f.matchCode == awayMatchCode));

        _fixtures.add(
          Fixture(
            homeTeam: _teams[j],
            awayTeam: _teams[i],
            venue: _venues.isEmpty ? 'TBD' : _venues[_fixtures.length % _venues.length],
            dateTime: fixtureDate,
            status: 'upcoming',
            matchCode: awayMatchCode,
          ),
        );
        fixtureDate = fixtureDate.add(const Duration(days: 7));
      }
    }
  }
}
