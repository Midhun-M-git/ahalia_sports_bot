import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/match.dart';

class MatchSummaryScreen extends StatelessWidget {
  final Match match;

  const MatchSummaryScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final homeScore = match.score['home'] ?? 0;
    final awayScore = match.score['away'] ?? 0;
    final winner = homeScore > awayScore ? match.homeTeam : match.awayTeam;
    final isTie = homeScore == awayScore;

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
                    const Text(
                      'Match Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                    const SizedBox(width: 48),
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
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTeamScore(match.homeTeam.name, homeScore),
                          Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isTie ? 'MATCH TIED' : '${winner.name} WINS!',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PressStart2P',
                                ),
                              ),
                            ],
                          ),
                          _buildTeamScore(match.awayTeam.name, awayScore),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn()
                .scale(),
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
                            _buildPlayerStats(match.homeTeamPerformance),
                            _buildPlayerStats(match.awayTeamPerformance),
                          ],
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
    );
  }

  Widget _buildTeamScore(String teamName, int score) {
    return Column(
      children: [
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'PressStart2P',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'PressStart2P',
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
                        fontFamily: 'PressStart2P',
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
                          fontFamily: 'PressStart2P',
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
                              fontFamily: 'PressStart2P',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stat.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'PressStart2P',
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
