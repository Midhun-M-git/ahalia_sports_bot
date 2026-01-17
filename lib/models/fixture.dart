import '../models/team.dart';
import 'dart:math';

class Fixture {
  final Team homeTeam;
  final Team awayTeam;
  final DateTime dateTime;
  final String venue;
  final String status;
  final String matchCode;

  Fixture({
    required this.homeTeam,
    required this.awayTeam,
    required this.dateTime,
    required this.venue,
    required this.status,
    String? matchCode,
  }) : matchCode = matchCode ?? generateMatchCode();

  static String generateMatchCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
