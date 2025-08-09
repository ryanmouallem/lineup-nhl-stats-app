import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:lineup/providers/favorites_provider.dart';
import 'package:lineup/screens/favourites_screen.dart';

void main() {
  testWidgets('renders favourites list', (tester) async {
    await mockNetworkImagesFor(() async {
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

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: fp,
            child: FavouritesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Player'), findsOneWidget);
      expect(find.text('EDM'), findsOneWidget);
    });
  });
}
