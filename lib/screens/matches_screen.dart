import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'create_team_screen.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/team.dart';

// Models for fantasy cricket contests
class Prize {
  final int rank;
  final double amount;
  Prize({required this.rank, required this.amount});
}

class Contest {
  final String name;
  final double entryFee;
  final int totalSpots;
  final int filledSpots;
  final List<Prize> prizes;
  final bool isGuaranteed;

  Contest({
    required this.name,
    required this.entryFee,
    required this.totalSpots,
    required this.filledSpots,
    required this.prizes,
    required this.isGuaranteed,
  });
}

class MatchWithContests {
  final Match match;
  final double prizePool;
  final List<Contest> contests;
  final String status;

  MatchWithContests({
    required this.match,
    required this.prizePool,
    required this.contests,
    required this.status,
  });
}

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample matches data
  final List<MatchWithContests> matches = [
    MatchWithContests(
      match: Match(
        homeTeam: Team(
          name: "RCB",
          players: [],
          sportType: 'cricket',
        ),
        awayTeam: Team(
          name: "CSK",
          players: [],
          sportType: 'cricket',
        ),
        venue: "M. Chinnaswamy Stadium",
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        sportType: 'cricket',
      ),
      status: "Upcoming",
      prizePool: 25000000,
      contests: [
        Contest(
          name: "Grand Contest",
          entryFee: 49,
          totalSpots: 100000,
          filledSpots: 50000,
          prizes: [
            Prize(rank: 1, amount: 1000000),
            Prize(rank: 2, amount: 500000),
            Prize(rank: 3, amount: 250000),
          ],
          isGuaranteed: true,
        ),
        Contest(
          name: "Head to Head",
          entryFee: 99,
          totalSpots: 2,
          filledSpots: 0,
          prizes: [
            Prize(rank: 1, amount: 180),
          ],
          isGuaranteed: false,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches')
            .animate()
            .fadeIn()
            .slideX(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cricket'),
            Tab(text: 'Football'),
            Tab(text: 'Basketball'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesList(),
          const Center(child: Text('Coming Soon')),
          const Center(child: Text('Coming Soon')),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildMatchHeader(match),
              _buildContestsList(match),
            ],
          ),
        ).animate()
          .fadeIn(delay: (200 * index).milliseconds)
          .slideY();
      },
    );
  }

  Widget _buildMatchHeader(MatchWithContests matchData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, HH:mm').format(matchData.match.dateTime),
                style: const TextStyle(color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  matchData.status,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamInfo(matchData.match.homeTeam.name),
              const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTeamInfo(matchData.match.awayTeam.name),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            matchData.match.venue,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String teamName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Text(
            teamName[0],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          teamName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate()
      .fadeIn()
      .scale();
  }

  Widget _buildContestsList(MatchWithContests matchData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${(matchData.prizePool / 100000).toStringAsFixed(1)}L',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              ElevatedButton(
                onPressed: () => _createTeam(matchData.match),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'CREATE TEAM',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ...matchData.contests.map((contest) => _buildContestCard(contest)),
      ],
    );
  }

  void _createTeam(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTeamScreen(
          sportType: match.sportType,
          onTeamCreated: (team) {
            // Handle the created team
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Team created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContestCard(Contest contest) {
    final progressPercent = contest.filledSpots / contest.totalSpots;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _joinContest(contest),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prize Pool: ₹${contest.prizes[0].amount}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Entry: ₹${contest.entryFee}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPercent > 0.9 ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${contest.filledSpots}/${contest.totalSpots} spots'),
                  if (contest.isGuaranteed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Guaranteed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn()
      .slideX();
  }

  void _joinContest(Contest contest) {
    // TODO: Implement contest joining logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Contest'),
        content: Text(
          'Entry Fee: ₹${contest.entryFee}\nPrize Pool: ₹${contest.prizes[0].amount}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement payment and team selection
              Navigator.pop(context);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
