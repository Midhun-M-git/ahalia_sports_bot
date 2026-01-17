import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/fixtures_screen.dart';
import 'models/team_manager.dart';
import 'screens/match_code_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahalia Sports Bot',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blue.shade300,
          surface: const Color(0xFF1A1A2E),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.rajdhani(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: Colors.white.withOpacity(0.9),
          ),
          bodyLarge: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: Colors.white.withOpacity(0.9),
          ),
          bodyMedium: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.blue.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
      ),
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
              Colors.blue.shade900.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                'Welcome to Ahalia Sports Bot',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.2),
              const SizedBox(height: 60),
              _buildOptionCard(
                context,
                'Organize Match',
                Icons.add_moderator,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SportsSelectionScreen()),
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
              const SizedBox(height: 20),
              _buildOptionCard(
                context,
                'View Match',
                Icons.visibility,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MatchCodeScreen()),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      color: Colors.white.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SportsSelectionScreen extends StatelessWidget {
  const SportsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sport'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select your sport:',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slide(begin: const Offset(0, -0.2), duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSportCard(
                    context,
                    'Cricket',
                    Icons.sports_cricket,
                    'cricket',
                  ),
                  const SizedBox(width: 20),
                  _buildSportCard(
                    context,
                    'Football',
                    Icons.sports_soccer,
                    'football',
                  ),
                ],
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 600))
                .slide(begin: const Offset(0, -0.2), duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  final teamManager = TeamManager();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FixturesScreen(
                        fixtures: teamManager.getFixtures(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('View Fixtures'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 900))
                .slide(begin: const Offset(0, -0.2), duration: const Duration(milliseconds: 500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportCard(
    BuildContext context,
    String title,
    IconData icon,
    String sportType,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(sportType: sportType),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        ShimmerEffect(
          duration: const Duration(seconds: 3),
          color: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }
}
