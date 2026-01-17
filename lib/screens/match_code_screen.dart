import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team_manager.dart';
import 'live_match_screen.dart';
import '../models/match.dart' as sports;
import '../models/fixture.dart';

class MatchCodeScreen extends StatefulWidget {
  const MatchCodeScreen({super.key});

  @override
  State<MatchCodeScreen> createState() => _MatchCodeScreenState();
}

class _MatchCodeScreenState extends State<MatchCodeScreen> {
  final _codeController = TextEditingController();
  final _teamManager = TeamManager();
  String? _errorMessage;

  void _validateAndJoinMatch() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a match code');
      return;
    }

    final fixtures = _teamManager.getFixtures();
    Fixture? fixture;
    try {
      fixture = fixtures.firstWhere((f) => f.matchCode == code);
    } catch (e) {
      fixture = null;
    }

    if (fixture == null) {
      setState(() => _errorMessage = 'Invalid match code');
      return;
    }

    // Create a new match from the fixture
    final match = sports.Match(
      homeTeam: fixture.homeTeam,
      awayTeam: fixture.awayTeam,
      dateTime: fixture.dateTime,
      venue: fixture.venue,
      sportType: fixture.homeTeam.sportType,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LiveMatchScreen(match: match),
      ),
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
              const Color(0xFF1A237E),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter Match Code',
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
                const SizedBox(height: 40),
                  TextField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter 8-digit match code',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.blue.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.sports, color: Colors.blue),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 8,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _validateAndJoinMatch,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Join Match'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ).animate()
                  .fadeIn()
                  .slideY(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
} 