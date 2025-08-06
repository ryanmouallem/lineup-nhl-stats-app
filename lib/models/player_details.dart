import 'player.dart';

class PlayerDetails {
  final Player player;
  final List<Map<String, dynamic>> seasons;
  final Map<String, dynamic> careerTotals;

  PlayerDetails({
    required this.player,
    required this.seasons,
    required this.careerTotals,
  });
}
