import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:lineup/providers/favorites_provider.dart';
import 'package:lineup/screens/favourites_screen.dart';

void main() {
  testWidgets('tap star removes favourite', (tester) async {
    await mockNetworkImagesFor(() async {
      final fdb = FakeFirebaseFirestore();
      final uid = 'test_uid';

      await fdb.collection('users').doc(uid).collection('favorites').doc('p1').set({
        'name': 'Tap Test',
        'headshot': 'https://example.com/h.png',
        'team': 'EDM',
        'teamLogo': 'https://example.com/l.png',
        'height': "6'1\"",
        'weight': 190,
        'birthCity': 'Edmonton',
        'birthCountry': 'Canada'
      });

      final fp = FavoritesProvider(uid, firestore: fdb);
      await fp.init();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: fp,
            child: FavouritesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Tap Test'), findsOneWidget);

      final star = find.byIcon(Icons.star).first;
      await tester.tap(star);
      await tester.pumpAndSettle();

      expect(find.text('Tap Test'), findsNothing);
      expect(fp.favorites.length, 0);
    });
  });
}