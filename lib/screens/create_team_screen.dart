import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/stats.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateTeamScreen extends StatefulWidget {
  final String sportType;
  final Function(Team) onTeamCreated;

  const CreateTeamScreen({
    super.key, 
    required this.sportType,
    required this.onTeamCreated,
  });

  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Player> selectedPlayers = [];
  String? captainId;
  String? viceCaptainId;
  
  // Position limits for cricket
  final Map<String, int> positionLimits = {
    'Batsman': 5,
    'Bowler': 5,
    'All-Rounder': 3,
    'Wicket-Keeper': 1,
  };

  // Sample players data
  final List<Player> availablePlayers = [
    Player(
      name: "Virat Kohli",
      position: "Batsman",
      teamName: "RCB",
      stats: Stats(
        matches: 200,
        runs: 6500,
        wickets: 0,
        average: 52.3,
        strikeRate: 138.5,
        catches: 80,
        stumpings: 0,
      ),
      age: 34,
    ),
    Player(
      name: "Rohit Sharma",
      position: "Batsman",
      teamName: "MI",
      stats: Stats(
        matches: 190,
        runs: 5800,
        wickets: 0,
        average: 48.5,
        strikeRate: 135.8,
        catches: 75,
        stumpings: 0,
      ),
      age: 36,
    ),
    Player(
      name: "Jasprit Bumrah",
      position: "Bowler",
      teamName: "MI",
      stats: Stats(
        matches: 150,
        runs: 200,
        wickets: 180,
        average: 22.5,
        strikeRate: 90.2,
        economy: 6.8,
        catches: 25,
      ),
      age: 29,
    ),
    Player(
      name: "MS Dhoni",
      position: "Wicket-Keeper",
      teamName: "CSK",
      stats: Stats(
        matches: 250,
        runs: 4500,
        wickets: 0,
        average: 38.5,
        strikeRate: 140.2,
        catches: 150,
        stumpings: 80,
      ),
      age: 42,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _playerPositionController = TextEditingController();
  final List<Map<String, String>> _players = [];
  final _teamManager = TeamManager();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _currentInputField = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teamNameController.dispose();
    _playerNameController.dispose();
    _playerPositionController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  bool canSelectMorePlayers(String position) {
    final currentCount = selectedPlayers
        .where((p) => p.position == position)
        .length;
    return currentCount < (positionLimits[position] ?? 0);
  }

  void _handlePlayerSelection(Player player) {
    setState(() {
      if (selectedPlayers.contains(player)) {
        selectedPlayers.remove(player);
        if (captainId == player.name) captainId = null;
        if (viceCaptainId == player.name) viceCaptainId = null;
      } else if (canSelectMorePlayers(player.position)) {
        selectedPlayers.add(player);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum ${player.position}s already selected'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _createTeam() {
    if (selectedPlayers.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select 11 players'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (captainId == null || viceCaptainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select captain and vice-captain'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final team = Team(
      name: 'New Team',
      players: selectedPlayers.map((player) => {
        'name': player.name,
        'age': player.age,
        'position': player.position,
        'teamName': player.teamName,
        'stats': player.stats.toJson(),
      }).toList(),
      sportType: widget.sportType,
      captain: captainId,
      viceCaptain: viceCaptainId,
    );

    widget.onTeamCreated(team);
    Navigator.pop(context);
  }

  Player createPlayer(String name, int age, String position, String teamName) {
    // Create default stats for new player
    Stats playerStats = Stats(
      runs: 0,
      wickets: 0,
      average: 0.0,
    );

    return Player(
      name: name,
      age: age,
      position: position,
      stats: playerStats,
      teamName: teamName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Create Team',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'WK'),
                    Tab(text: 'BAT'),
                    Tab(text: 'AR'),
                    Tab(text: 'BOWL'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlayerList('Wicket-Keeper'),
                    _buildPlayerList('Batsman'),
                    _buildPlayerList('All-Rounder'),
                    _buildPlayerList('Bowler'),
                  ],
                ),
              ),
              _buildVoiceInputSection(),
              _buildSelectedPlayersPreview(),
              _buildCreateTeamButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerList(String position) {
    final players = availablePlayers.where((p) => p.position == position).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = selectedPlayers.contains(player);
        final isCaptain = captainId == player.name;
        final isViceCaptain = viceCaptainId == player.name;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Text(
                player.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              player.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              '${player.teamName} • ${player.position}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  IconButton(
                    icon: Icon(
                      Icons.sports_cricket,
                      color: isCaptain ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isCaptain) {
                          captainId = null;
                        } else {
                          captainId = player.name;
                          if (isViceCaptain) viceCaptainId = null;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: isViceCaptain ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isViceCaptain) {
                          viceCaptainId = null;
                        } else {
                          viceCaptainId = player.name;
                          if (isCaptain) captainId = null;
                        }
                      });
                    },
                  ),
                ],
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) => _handlePlayerSelection(player),
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn()
          .scale();
      },
    );
  }

  Widget _buildVoiceInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Voice Commands',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Say "select [player name]" to select a player\n'
            'Say "captain [player name]" to make captain\n'
            'Say "vice captain [player name]" to make vice captain',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening('playerSelection');
              }
            },
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.white,
            ),
            label: Text(
              _isListening ? 'Stop Listening' : 'Start Voice Input',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isListening ? Colors.red : Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlayersPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamCount('WK', selectedPlayers.where((p) => p.position == 'Wicket-Keeper').length),
              _buildTeamCount('BAT', selectedPlayers.where((p) => p.position == 'Batsman').length),
              _buildTeamCount('AR', selectedPlayers.where((p) => p.position == 'All-Rounder').length),
              _buildTeamCount('BOWL', selectedPlayers.where((p) => p.position == 'Bowler').length),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedPlayers.length}/11 Players Selected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: selectedPlayers.length == 11 ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCount(String position, int count) {
    return Column(
      children: [
        Text(
          position,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateTeamButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _createTeam,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Create Team',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _initSpeech() async {
    try {
      await Permission.microphone.request();
      final available = await _speechToText.initialize();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing speech: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _startListening(String fieldName) async {
    try {
      if (!_isListening) {
        _isListening = true;
        _currentInputField = fieldName;
        setState(() {});
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              _processVoiceInput(result.recognizedWords);
              _isListening = false;
              setState(() {});
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _isListening = false;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting speech recognition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopListening() {
    try {
      if (_isListening) {
        _speechToText.stop();
        _isListening = false;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping speech recognition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _processVoiceInput(String text) {
    final lowerText = text.toLowerCase();
    
    if (_currentInputField == 'playerSelection') {
      if (lowerText.startsWith('select ')) {
        final playerName = text.substring(7).trim();
        final player = availablePlayers.firstWhere(
          (p) => p.name.toLowerCase() == playerName.toLowerCase(),
          orElse: () => null,
        );
        if (player != null) {
          _handlePlayerSelection(player);
        }
      } else if (lowerText.startsWith('captain ')) {
        final playerName = text.substring(8).trim();
        final player = availablePlayers.firstWhere(
          (p) => p.name.toLowerCase() == playerName.toLowerCase(),
          orElse: () => null,
        );
        if (player != null && selectedPlayers.contains(player)) {
          setState(() {
            captainId = player.name;
            if (viceCaptainId == player.name) viceCaptainId = null;
          });
        }
      } else if (lowerText.startsWith('vice captain ')) {
        final playerName = text.substring(13).trim();
        final player = availablePlayers.firstWhere(
          (p) => p.name.toLowerCase() == playerName.toLowerCase(),
          orElse: () => null,
        );
        if (player != null && selectedPlayers.contains(player)) {
          setState(() {
            viceCaptainId = player.name;
            if (captainId == player.name) captainId = null;
          });
        }
      }
    }
  }

  void _addPlayer() {
    if (_playerNameController.text.isNotEmpty && _playerPositionController.text.isNotEmpty) {
      setState(() {
        _players.add({
          'name': _playerNameController.text,
          'position': _playerPositionController.text,
        });
        _playerNameController.clear();
        _playerPositionController.clear();
      });
    }
  }

  void _createTeam() {
    if (_formKey.currentState!.validate() && _players.isNotEmpty) {
      final team = Team(
        name: _teamNameController.text,
        sportType: 'cricket',
        players: _players,
      );
      _teamManager.addTeam(team);
      Navigator.pop(context);
    }
  }
}
