import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/player.dart';
import 'package:intl/intl.dart';
import '../models/stats.dart';

class TeamScreen extends StatefulWidget {
  final String teamName;

  const TeamScreen({super.key, required this.teamName});

  @override
  TeamScreenState createState() => TeamScreenState();
}

class TeamScreenState extends State<TeamScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Player> players = [
    Player(
      name: "Virat Kohli",
      position: "Batsman",
      teamName: "RCB",
      age: 34,
      stats: Stats(
        matches: 200,
        runs: 6500,
        wickets: 0,
        average: 52.3,
        strikeRate: 138.5,
        catches: 80,
        stumpings: 0,
      ),
    ),
    Player(
      name: "Rohit Sharma",
      position: "Batsman",
      teamName: "MI",
      age: 36,
      stats: Stats(
        matches: 190,
        runs: 5800,
        wickets: 0,
        average: 48.5,
        strikeRate: 135.8,
        catches: 75,
        stumpings: 0,
      ),
    ),
    Player(
      name: "Jane Smith",
      position: "Bowler",
      teamName: "Team A",
      age: 28,
      stats: Stats(
        matches: 8,
        runs: 0,
        wickets: 15,
        average: 0.0,
        economy: 6.5,
        catches: 3,
      ),
    ),
    Player(
      name: "Mike Johnson",
      position: "All-Rounder",
      teamName: "Team A",
      age: 31,
      stats: Stats(
        matches: 12,
        runs: 250,
        wickets: 10,
        average: 31.25,
        economy: 7.2,
        catches: 5,
      ),
    ),
  ];

  final List<Match> matches = [
    Match(
      homeTeam: Team(name: "Team A", players: [], sportType: "cricket"),
      awayTeam: Team(name: "Team Alpha", players: [], sportType: "cricket"),
      venue: "Main Stadium",
      dateTime: DateTime.now().add(const Duration(days: 2)),
      sportType: "cricket",
    ),
    Match(
      homeTeam: Team(name: "Team A", players: [], sportType: "cricket"),
      awayTeam: Team(name: "Team Beta", players: [], sportType: "cricket"),
      venue: "City Ground",
      dateTime: DateTime.now().add(const Duration(days: 7)),
      sportType: "cricket",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText(widget.teamName,
                textStyle: const TextStyle(fontSize: 24)),
          ],
          isRepeatingAnimation: true,
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTeamHeader(),
            _buildPlayersList(),
            _buildMatchSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.sports_soccer, size: 60)
              .animate(controller: _controller)
              .scale(duration: 1.seconds, curve: Curves.easeInOut)
              .then()
              .rotate(duration: 500.milliseconds),
          const SizedBox(height: 16),
          Text(
            widget.teamName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ).animate()
            .fadeIn(duration: 600.milliseconds)
            .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Team Players",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate()
            .fadeIn(duration: 400.milliseconds)
            .slideX(),
          const SizedBox(height: 16),
          ...players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(player.name[0]),
                ),
                title: Text(player.name),
                subtitle: Text(player.position),
              ),
            ).animate()
              .fadeIn(delay: (200 * index).milliseconds)
              .slideX();
          }),
        ],
      ),
    );
  }

  Widget _buildMatchSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Matches",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate()
            .fadeIn(duration: 400.milliseconds)
            .slideX(),
          const SizedBox(height: 16),
          ...matches.asMap().entries.map((entry) {
            final index = entry.key;
            final match = entry.value;
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.sports_soccer),
                title: Text("vs ${match.awayTeam.name}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM dd, yyyy HH:mm').format(match.dateTime)),
                    Text(match.venue),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.isLive ? "LIVE" : "UPCOMING",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ).animate()
              .fadeIn(delay: (200 * index).milliseconds)
              .slideX();
          }),
        ],
      ),
    );
  }
}
