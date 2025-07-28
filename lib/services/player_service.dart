import 'dart:convert';
import 'package:http/http.dart' as http;

class PlayerService {
  final String baseUrl = 'https://api-web.nhle.com/v1/player';

  Future<Map<String, dynamic>> fetchPlayerDetails(String playerId) async {
    final info = await _fetchInfo(playerId);
    final seasons = _extractNHLSeasons(info);
    final totals = info['careerTotals']?['regularSeason'] ?? {};

    return {
      'id': playerId,
      'name': '${info['firstName']['default']} ${info['lastName']['default']}',
      'team': info['currentTeamAbbrev'] ?? '',
      'teamLogo': info['teamLogo'] ?? '',
      'headshot': info['headshot'] ?? '',
      'height': '${info['heightInInches'] ?? ''}"',
      'weight': info['weightInPounds'] ?? 0,
      'birthCity': info['birthCity']?['default'] ?? '',
      'birthCountry': info['birthCountry'] ?? '',
      'seasons': seasons,
      'careerTotals': {
        'gamesPlayed': totals['gamesPlayed'] ?? 0,
        'goals': totals['goals'] ?? 0,
        'assists': totals['assists'] ?? 0,
        'points': totals['points'] ?? 0,
        'plusMinus': totals['plusMinus'] ?? 0,
        'pim': totals['pim'] ?? 0,
      }
    };
  }

  Future<Map<String, dynamic>> _fetchInfo(String playerId) async {
    final url = Uri.parse('$baseUrl/$playerId/landing');
    try {
      final r = await http.get(url);
      if (r.statusCode == 200) return json.decode(r.body);
    } catch (_) {}
    return {};
  }

  List<Map<String, dynamic>> _extractNHLSeasons(Map<String, dynamic> data) {
    final Set<String> nhlTeams = {
      'ANA','ARI','BOS','BUF','CGY','CAR','CHI','COL','CBJ','DAL','DET','EDM','FLA',
      'LAK','MIN','MTL','NSH','NJD','NYI','NYR','OTT','PHI','PIT','SJS','SEA','STL',
      'TBL','TOR','VAN','VGK','WSH','WPG'
    };

    List<Map<String, dynamic>> rows = [];
    for (var s in data['seasonTotals'] ?? []) {
      final team = s['teamAbbrev'] ?? s['teamAbbrevs'] ?? '';
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
