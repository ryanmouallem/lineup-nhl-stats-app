import 'dart:convert';
import 'package:http/http.dart' as http;

class NhlApiService {
  final String baseUrl = 'https://api-web.nhle.com/v1/roster';
  final String season = '20252026';

  final List<String> teams = [
    'ana', 'bos', 'buf', 'cgy', 'car', 'chi', 'col',
    'cbj', 'dal', 'det', 'edm', 'fla', 'lak', 'min', 'mtl',
    'nsh', 'njd', 'nyi', 'nyr', 'ott', 'phi', 'pit', 'sjs',
    'sea', 'stl', 'tbl', 'tor', 'uta', 'van', 'vgk', 'wsh', 'wpg'
  ];

  Future<List<Map<String, dynamic>>> fetchAllPlayers() async {
    final results = await Future.wait(teams.map((team) async {
      final url = Uri.parse('$baseUrl/$team/$season');
      List<Map<String, dynamic>> teamPlayers = [];
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> forwards = data['forwards'] ?? [];
          List<dynamic> defensemen = data['defensemen'] ?? [];
          List<dynamic> goalies = data['goalies'] ?? [];
          List<dynamic> roster = [...forwards, ...defensemen, ...goalies];
          for (var player in roster) {
            teamPlayers.add({
              'id': player['id'],
              'name':
              '${player['firstName']['default']} ${player['lastName']['default']}',
              'team': team.toUpperCase(),
            });
          }
        } else {
          print('Failed to load roster for $team: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching roster for $team: $e');
      }
      return teamPlayers;
    }));

    final allPlayers = results.expand((list) => list).toList();
    print('Total players loaded: ${allPlayers.length}');
    return allPlayers;
  }
}
