import 'package:flutter_test/flutter_test.dart';
import 'package:lineup/models/player.dart';

void main() {
  test('Player fromMap parses', () {
    final map = {
      'id': '8478402',
      'name': 'Connor McDavid',
      'team': 'EDM',
      'headshot': 'https://example.com/h.png',
      'teamLogo': 'https://example.com/t.svg',
      'height': '6\'1\"',
      'weight': 195,
      'birthCity': 'Richmond Hill',
      'birthCountry': 'Canada'
    };
    final p = Player.fromMap(map);
    expect(p.id, '8478402');
    expect(p.team, 'EDM');
    expect(p.name.isNotEmpty, true);
  });
}
