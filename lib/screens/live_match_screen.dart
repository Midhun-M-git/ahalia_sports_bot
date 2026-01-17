import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/match.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'match_summary_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveMatchScreen extends StatefulWidget {
  final Match match;

  const LiveMatchScreen({super.key, required this.match});

  @override
  LiveMatchScreenState createState() => LiveMatchScreenState();
}

class LiveMatchScreenState extends State<LiveMatchScreen> {
  late Timer _matchTimer;
  final Random _random = Random();
  bool _isMatchPaused = false;
  bool _showPlayerStats = false;
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    widget.match.isLive = true;
    widget.match.isLive = true;
    _initSpeech();
    _initTts();
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

  Future<void> _startListening() async {
    try {
      if (!_isListening) {
        _isListening = true;
        setState(() {}); // Update UI to show listening state
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              _processVoiceCommand(result.recognizedWords);
              _isListening = false;
              setState(() {}); // Update UI to show stopped state
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
        setState(() {}); // Update UI to show stopped state
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

  Future<void> _processVoiceCommand(String command) async {
    try {
      final lowerCommand = command.toLowerCase();
      String commentary = '';
      int? runs;

      if (widget.match.homeTeam.sportType == 'cricket') {
        if (lowerCommand.contains('six') || (lowerCommand.contains('hit') && lowerCommand.contains('6'))) {
          runs = 6;
          commentary = 'SIX! Amazing hit!';
        } else if (lowerCommand.contains('four') || lowerCommand.contains('boundary') || (lowerCommand.contains('hit') && lowerCommand.contains('4'))) {
          runs = 4;
          commentary = 'FOUR! Great boundary!';
        } else if (lowerCommand.contains('hit') && lowerCommand.contains('run')) {
          final runMatch = RegExp(r'hit\s+(\d+)\s+run').firstMatch(lowerCommand);
          if (runMatch != null) {
            runs = int.tryParse(runMatch.group(1) ?? '0');
            commentary = '${runs} runs scored!';
          }
        } else if (lowerCommand.contains('out') || lowerCommand.contains('wicket') || lowerCommand.contains('bowled')) {
          commentary = 'WICKET! Bowler takes a wicket!';
          // Update bowling team's score
          final bowlingTeam = widget.match.homeTeam.name;
          widget.match.updateScore(bowlingTeam, 1);
        }
      } else if (widget.match.homeTeam.sportType == 'football') {
         if (lowerCommand.contains('goal') || lowerCommand.contains('scored')) {
            widget.match.incrementScore('home'); 
            commentary = 'GOAL! Fantastic goal scored!';
         }
      }

      if (runs != null && runs > 0) {
        setState(() {
          widget.match.updateScore('home', runs!);
          widget.match.addCommentary(commentary);
          _speakCommentary(commentary);
        });
      } else if (commentary.isNotEmpty) {
        setState(() {
          widget.match.addCommentary(commentary);
          _speakCommentary(commentary);
        });
      } else if (command.isNotEmpty) {
        // Treat as general commentary if no command matched
        setState(() {
          widget.match.addCommentary(command);
          _speakCommentary(command);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing voice command: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _speakCommentary(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error speaking commentary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }



  void _endMatch() {
    setState(() {
      widget.match.isLive = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MatchSummaryScreen(match: widget.match),
      ),
    );
  }

  void _updatePlayerStats(String team, String playerName, String stat, int value) {
    setState(() {
      final teamPerformance = team == 'home' 
          ? widget.match.homeTeamPerformance 
          : widget.match.awayTeamPerformance;
          
      final playerPerf = teamPerformance.firstWhere(
        (p) => p.playerName == playerName,
        orElse: () {
          // This shouldn't happen if initialization is correct, but safe fallback
          // We can't easily create a new one without position, so we might skip or find by name match
          // Ideally performance list is pre-filled.
          return teamPerformance.first; 
        },
      );
      
      // Since firstWhere with orElse returning first might be risky if list empty or wrong
      // Better to check existence:
      try {
         final specificPlayer = teamPerformance.firstWhere((p) => p.playerName == playerName);
         specificPlayer.stats[stat] = (specificPlayer.stats[stat] ?? 0) + value;
      } catch (e) {
        // Player not found in performance list, ignore
      }
    });
  }
  
  void _showManualUpdateDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isCricket = widget.match.homeTeam.sportType == 'cricket';
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Score',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              if (isCricket) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreButton('+1 Run', () => _updateMatchScore(1, '1 run scored')),
                    _buildScoreButton('+4 Runs', () => _updateMatchScore(4, 'FOUR! Great boundary!')),
                    _buildScoreButton('+6 Runs', () => _updateMatchScore(6, 'SIX! Amazing hit!')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildScoreButton('Wicket (Out)', () {
                  widget.match.addCommentary('WICKET! Batsman is out!');
                  // For simplicity in manual mode, just logging wicket, sophisticated logic usually requires selecting player
                   setState(() {});
                  Navigator.pop(context);
                }, color: Colors.red),
              ] else ...[
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreButton('Goal!', () {
                       widget.match.incrementScore('home'); // defaulting to home for manual simple button, ideally select team
                       widget.match.addCommentary('GOAL! A fantastic goal!');
                       setState(() {});
                       Navigator.pop(context);
                    }, color: Colors.green),
                     _buildScoreButton('Missed', () {
                       widget.match.addCommentary('Missed chance! The ball goes wide.');
                       setState(() {});
                       Navigator.pop(context);
                    }, color: Colors.orange),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreButton(String label, VoidCallback onPressed, {Color color = Colors.blue}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }

  void _updateMatchScore(int runs, String commentary) {
      // Defaulting manual update to home team for simplicity of the UI request
      // Ideally, the user should select which team
      setState(() {
        widget.match.updateScore('home', runs);
        widget.match.addCommentary(commentary);
        _speakCommentary(commentary);
      });
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showManualUpdateDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A237E),
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
                      '${widget.match.homeTeam.name} vs ${widget.match.awayTeam.name}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.blue.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.blue.shade500.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 3000.ms, color: Colors.blue.withOpacity(0.3)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showPlayerStats ? Icons.scoreboard : Icons.person,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPlayerStats = !_showPlayerStats;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _isMatchPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMatchPaused = !_isMatchPaused;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.stop_circle,
                            color: Colors.red,
                          ),
                          onPressed: _endMatch,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 8,
                shadowColor: Colors.blue.withOpacity(0.3),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTeamScore(widget.match.homeTeam.name, widget.match.score['home'] ?? 0),
                      Column(
                        children: [
                          const Icon(
                            Icons.sports,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'LIVE',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .fadeOut(duration: 1000.ms)
                            .fadeIn(duration: 1000.ms),
                        ],
                      ),
                      _buildTeamScore(widget.match.awayTeam.name, widget.match.score['away'] ?? 0),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn()
                .scale(),
              if (_showPlayerStats)
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
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
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.blue,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.blue,
                            tabs: const [
                              Tab(text: 'Home Team'),
                              Tab(text: 'Away Team'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildPlayerStats(widget.match.homeTeamPerformance),
                              _buildPlayerStats(widget.match.awayTeamPerformance),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.speaker_notes,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Match Commentary',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Live Commentary',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isListening ? Icons.mic : Icons.mic_none,
                                          color: _isListening ? Colors.red : Colors.blue,
                                        ),
                                        onPressed: () {
                                          if (_isListening) {
                                            _stopListening();
                                          } else {
                                            _startListening();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: widget.match.commentary.length,
                                      itemBuilder: (context, index) {
                                        final isLatest = index == 0;
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isLatest ? Colors.blue.withOpacity(0.1) : null,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isLatest ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                                            ),
                                          ),
                                          child: Text(
                                            widget.match.commentary[index],
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: isLatest ? Colors.blue.shade300 : Colors.white70,
                                              fontWeight: isLatest ? FontWeight.bold : null,
                                              shadows: isLatest ? [
                                                Shadow(
                                                  color: Colors.blue.shade500.withOpacity(0.3),
                                                  blurRadius: 4,
                                                ),
                                              ] : null,
                                            ),
                                          ),
                                        ).animate()
                                          .fadeIn()
                                          .slideX();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score) {
    return Column(
      children: [
        Text(
          teamName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            shadows: [
              Shadow(
                color: Colors.blue.shade500.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade200,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 50, 50)),
            shadows: [
              Shadow(
                color: Colors.blue.shade500.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: Colors.blue.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildPlayerStats(List<PlayerPerformance> performances) {
    if (performances.isEmpty) {
      return const Center(
        child: Text(
          'No player statistics available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: performances.length,
      itemBuilder: (context, index) {
        final performance = performances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      performance.playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        performance.position,
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: performance.stats.entries.map((stat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stat.key,
                            style: TextStyle(
                              color: Colors.blue.shade200,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stat.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ).animate()
          .fadeIn()
          .slideX();
      },
    );
  }
}
