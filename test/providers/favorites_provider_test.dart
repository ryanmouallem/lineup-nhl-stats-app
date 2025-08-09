import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:lineup/providers/favorites_provider.dart';
import 'package:lineup/models/player.dart';

void main() {
  test('Favorites add and remove', () async {
    final fdb = FakeFirebaseFirestore();
    final uid = 'test_uid';

    await fdb.collection('users').doc(uid).collection('favorites').doc('p1').set({
      'name': 'Test Player',
      'headshot': 'https://example.com/headshot.png',
      'team': 'EDM',
      'teamLogo': 'https://example.com/logo.png',
      'height': "6'1\"",
      'weight': 190,
      'birthCity': 'Edmonton',
      'birthCountry': 'Canada'
    });

    final fp = FavoritesProvider(uid, firestore: fdb);
    await fp.init();
    expect(fp.favorites.length, 1);
    expect(fp.isFavorite('p1'), true);

    final p2 = Player(
      id: 'p2',
      name: 'Second Player',
      headshot: 'https://example.com/h2.png',
      team: 'TOR',
      teamLogo: 'https://example.com/tlogo.png',
      height: "6'0\"",
      weight: 180,
      birthCity: 'Toronto',
      birthCountry: 'Canada',
    );

    await fp.addFavorite(p2);
    expect(fp.favorites.length, 2);
    expect(fp.isFavorite('p2'), true);

    await fp.removeFavorite('p1');
    expect(fp.isFavorite('p1'), false);

    await fp.clearFavorites();
    expect(fp.favorites.length, 0);
  });
}
