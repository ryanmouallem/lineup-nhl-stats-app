import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/player_details.dart';

class PlayerService {
  final String baseUrl = 'https://api-web.nhle.com/v1/player';

  Future<PlayerDetails> fetchPlayerDetails(String playerId) async {
    final info = await _fetchInfo(playerId);
    final seasons = _extractNHLSeasons(info);
    final totals = info['careerTotals']?['regularSeason'] ?? {};
    final player = Player.fromMap({
      'id': playerId,
      'name': '${info['firstName']['default']} ${info['lastName']['default']}',
      'team': info['currentTeamAbbrev'] ?? '',
      'teamLogo': info['teamLogo'] ?? '',
      'headshot': info['headshot'] ?? '',
      'height': '${info['heightInInches'] ?? ''}"',
      'weight': info['weightInPounds'] ?? 0,
      'birthCity': info['birthCity']?['default'] ?? '',
      'birthCountry': info['birthCountry'] ?? '',
    });

    return PlayerDetails(
      player: player,
      seasons: seasons,
      careerTotals: {
        'gamesPlayed': totals['gamesPlayed'] ?? 0,
        'goals': totals['goals'] ?? 0,
        'assists': totals['assists'] ?? 0,
        'points': totals['points'] ?? 0,
        'plusMinus': totals['plusMinus'] ?? 0,
        'pim': totals['pim'] ?? 0,
      },
    );
  }

  Future<Map<String, dynamic>> _fetchInfo(String playerId) async {
    final url = Uri.parse('$baseUrl/$playerId/landing');
    final r = await http.get(url);
    if (r.statusCode == 200) return json.decode(r.body);
    return {};
  }

  List<Map<String, dynamic>> _extractNHLSeasons(Map<String, dynamic> data) {
    final Map<String, String> teamMap = {
      'Anaheim Ducks': 'ANA',
      'Arizona Coyotes': 'ARI',
      'Boston Bruins': 'BOS',
      'Buffalo Sabres': 'BUF',
      'Calgary Flames': 'CGY',
      'Carolina Hurricanes': 'CAR',
      'Chicago Blackhawks': 'CHI',
      'Colorado Avalanche': 'COL',
      'Columbus Blue Jackets': 'CBJ',
      'Dallas Stars': 'DAL',
      'Detroit Red Wings': 'DET',
      'Edmonton Oilers': 'EDM',
      'Florida Panthers': 'FLA',
      'Los Angeles Kings': 'LAK',
      'Minnesota Wild': 'MIN',
      'Montreal Canadiens': 'MTL',
      'Nashville Predators': 'NSH',
      'New Jersey Devils': 'NJD',
      'New York Islanders': 'NYI',
      'New York Rangers': 'NYR',
      'Ottawa Senators': 'OTT',
      'Philadelphia Flyers': 'PHI',
      'Pittsburgh Penguins': 'PIT',
      'San Jose Sharks': 'SJS',
      'Seattle Kraken': 'SEA',
      'St. Louis Blues': 'STL',
      'Tampa Bay Lightning': 'TBL',
      'Toronto Maple Leafs': 'TOR',
      'Vancouver Canucks': 'VAN',
      'Vegas Golden Knights': 'VGK',
      'Washington Capitals': 'WSH',
      'Winnipeg Jets': 'WPG'
    };

    final Set<String> nhlTeams = teamMap.values.toSet();
    final currentYear = DateTime.now().year;
    List<Map<String, dynamic>> rows = [];

    for (var s in data['seasonTotals'] ?? []) {
      final seasonYear = int.tryParse(s['season'].toString().substring(0, 4)) ?? 0;

      final rawTeam = (s['teamAbbrev'] ??
          s['teamAbbrevs'] ??
          s['teamName']?['default'] ??
          s['teamCommonName']?['default'] ??
          (seasonYear == currentYear ? data['currentTeamAbbrev'] : '-') ??
          '-').toString();

      final team = teamMap[rawTeam] ?? rawTeam;

      final league = s['leagueAbbrev'] ?? '';
      if (league == 'NHL' || nhlTeams.contains(team)) {
        rows.add({
          'season': s['season'].toString(),
          'teamAbbrev': team,
          'gameTypeId': s['gameTypeId'] ?? 2,
          'gamesPlayed': s['gamesPlayed'] ?? 0,
          'goals': s['goals'] ?? 0,
          'assists': s['assists'] ?? 0,
          'points': s['points'] ?? 0,
          'plusMinus': s['plusMinus'] ?? 0,
          'pim': s['pim'] ?? 0,
        });
      }
    }
    return rows;
  }
}
