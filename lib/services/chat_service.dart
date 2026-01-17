import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/team_manager.dart';
import '../models/team.dart';
import '../models/match.dart' as sports;
import '../screens/tournament_screen.dart';
import '../models/fixture.dart';

class ChatService {
  final String sportType;
  final TeamManager teamManager = TeamManager();
  List<Map<String, dynamic>> currentTeamPlayers = [];
  bool isAddingPlayers = false;
  String? currentTeamName;
  final Function(List<Team>, List<Fixture>) onShowTournament;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  
  ChatService(this.sportType, {required this.onShowTournament}) {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await Permission.microphone.request();
    await _speechToText.initialize();
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
    }
  }

  final Map<String, List<String>> positions = {
    'cricket': ['Batsman', 'Bowler', 'All-Rounder', 'Wicket-Keeper'],
    'football': ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'],
  };

  Future<String> getChatResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lowerMessage = message.toLowerCase();

    // ... (other command handlers remain same)

    if (lowerMessage.contains('add venue')) {
      final venue = message.substring(message.toLowerCase().indexOf('venue') + 5).trim();
      if (venue.isEmpty) {
        return 'Please specify a venue name. Example: "Add venue Ahalia Stadium"';
      }
      teamManager.addVenue(venue);
      return 'Added "$venue" to venues list!';
    }

    // ... (venue list and score handlers remain same)

    if (lowerMessage.contains('show')) {
      if (lowerMessage.contains('teams')) {
        return _showAllTeams();
      }
      if (lowerMessage.contains('fixtures') || lowerMessage.contains('tournament')) {
        final response = _showFixtures();
        if (teamManager.getTeams().length >= 2) {
          onShowTournament(teamManager.getTeams(), teamManager.getFixtures());
        }
        return response;
      }
    }
    
    // ... (rest remains same)

    return '''Hi! I'm your Ahalia ${sportType.toUpperCase()} Bot. I can help you:
1. Create a team (say "create team TEAM_NAME")
2. Add a venue (say "add venue VENUE_NAME")
3. Show all teams (say "show teams")
4. Show tournament & fixtures (say "show tournament")

How would you like to proceed?''';
  }

  String _handlePlayerAddition(String message) {
    if (message.toLowerCase() == 'done') {
      if (currentTeamPlayers.isEmpty) {
        return 'Please add at least one player to the team.';
      }
      
      final newTeam = Team(
        name: currentTeamName!,
        players: List.from(currentTeamPlayers),
        sportType: sportType,
      );
      teamManager.addTeam(newTeam);
      
      isAddingPlayers = false;
      currentTeamName = null;

      final response = '''Team created successfully!

${_formatTeam(newTeam)}

${teamManager.getTeams().length >= 2 ? "Type 'show tournament' to view all teams and fixtures!" : "Create one more team to generate tournament fixtures!"}''';
      
      currentTeamPlayers.clear();
      return response;
    }

    String name = '';
    String position = '';
    bool parsingSuccess = false;

    // Try comma-separated format first
    if (message.contains(',')) {
      final parts = message.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2 && positions[sportType]!.contains(parts[1])) {
        name = parts[0];
        position = parts[1];
        parsingSuccess = true;
      }
    }

    // Fallback: Check if message ends with a known position (for voice without comma)
    if (!parsingSuccess) {
      final lowerMessage = message.toLowerCase();
      for (final validPos in positions[sportType]!) {
        if (lowerMessage.endsWith(validPos.toLowerCase())) {
          // Found a match at the end
          // Extract name: everything before the position
          final namePart = message.substring(0, message.length - validPos.length).trim();
          if (namePart.isNotEmpty) {
             name = namePart;
             position = validPos; // Use the properly cased validPos
             parsingSuccess = true;
             break;
          }
        }
      }
    }

    if (!parsingSuccess) {
      return '''Invalid format. Please use: Name, Position (or say "Name Position")
Example: ${sportType == 'cricket' ? 'Virat Kohli Batsman' : 'Messi Forward'}

Available positions:
${positions[sportType]?.join(', ')}''';
    }

    currentTeamPlayers.add({
      'name': name,
      'position': position,
      'rating': 8.0,
    });

    return '''Added $name as $position!

Current team "$currentTeamName":
${_formatPlayerList(currentTeamPlayers)}

Add another player or type 'done' to finish.''';
  }

  String _showAllTeams() {
    final teams = teamManager.getTeams();
    if (teams.isEmpty) {
      return 'No teams created yet. Start by saying "create team TEAM_NAME"!';
    }

    return '''${sportType.toUpperCase()} Teams:

${teams.map((team) => _formatTeam(team)).join('\n\n')}''';
  }

  String _showFixtures() {
    final fixtures = teamManager.getFixtures();
    if (fixtures.isEmpty) {
      return '''No fixtures yet. Create at least 2 teams to generate fixtures.
${_showAllTeams()}''';
    }

    return ''' 🏆 ${sportType.toUpperCase()} Tournament Fixtures:

${fixtures.map((fixture) => _formatFixture(fixture)).join('\n\n')}

Opening tournament view...''';
  }

  String _formatTeam(Team team) {
    return '''Team: ${team.name}
Captain: ${team.captain}
${team.viceCaptain?.isNotEmpty == true ? 'Vice Captain: ${team.viceCaptain}\n' : ''}
Players:
${_formatPlayerList(team.players)}''';
  }

  String _formatPlayerList(List<Map<String, dynamic>> players) {
    return players.map((p) => "• ${p['name']} (${p['position']})").join('\n');
  }

  String _formatFixture(Fixture fixture) {
    final dateStr = DateFormat('MMM dd, yyyy HH:mm').format(fixture.dateTime);
    return '''${fixture.homeTeam.name} 🆚 ${fixture.awayTeam.name}
 📅 $dateStr
 🏟️ ${fixture.venue}''';
  }

  String _extractTeamName(String message) {
    final teamIndex = message.toLowerCase().indexOf('team');
    if (teamIndex != -1 && teamIndex + 5 < message.length) {
      return message.substring(teamIndex + 5).trim();
    }
    return '';
  }
}