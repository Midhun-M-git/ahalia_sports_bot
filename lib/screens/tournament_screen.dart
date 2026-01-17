import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team_manager.dart';
import '../models/team.dart';
import '../models/match.dart';
import 'live_match_screen.dart';
import 'package:intl/intl.dart';
import '../models/fixture.dart';

class TournamentScreen extends StatelessWidget {
  final List<Team> teams;
  final List<Fixture> fixtures;

  const TournamentScreen({
    super.key,
    required this.teams,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tournament'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Teams'),
              Tab(text: 'Fixtures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTeamsView(context),
            _buildFixturesView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              team.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              'Captain: ${team.captain}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: team.players.length,
                itemBuilder: (context, playerIndex) {
                  final player = team.players[playerIndex];
                  return ListTile(
                    title: Text(player['name']),
                    subtitle: Text(player['position']),
                    leading: CircleAvatar(
                      child: Text(
                        player['name'][0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ).animate()
          .fadeIn()
          .slideX();
      },
    );
  }

  Widget _buildFixturesView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        final fixture = fixtures[index];
        final matchDate = DateFormat('MMM dd, yyyy').format(fixture.dateTime);
        final matchTime = DateFormat('HH:mm').format(fixture.dateTime);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              final match = Match(
                homeTeam: fixture.homeTeam,
                awayTeam: fixture.awayTeam,
                venue: fixture.venue,
                dateTime: fixture.dateTime,
                sportType: 'cricket', // Default to cricket since this is a cricket tournament app
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveMatchScreen(match: match),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fixture.homeTeam.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          fixture.awayTeam.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(matchDate),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(matchTime),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(fixture.venue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (fixture.homeTeam.players.isEmpty || fixture.awayTeam.players.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Both teams must have players before starting a match.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final match = Match(
                        homeTeam: fixture.homeTeam,
                        awayTeam: fixture.awayTeam,
                        venue: fixture.venue,
                        dateTime: fixture.dateTime,
                        sportType: 'cricket', // Default to cricket since this is a cricket tournament app
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveMatchScreen(match: match),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sports),
                    label: const Text('Start Match'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate()
          .fadeIn()
          .slideY();
      },
    );
  }
}
