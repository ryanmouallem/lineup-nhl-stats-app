import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class FavoritesProvider extends ChangeNotifier {
  final String uid;
  final FirebaseFirestore _firestore;
  List<Player> _favorites = [];

  List<Player> get favorites => List.unmodifiable(_favorites);

  FavoritesProvider(this.uid, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;


  Future<void> init() async {
    if (uid.isEmpty) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    _favorites = snapshot.docs.map((doc) {
      final data = doc.data();
      return Player(
        id: doc.id,
        name: data['name'],
        headshot: data['headshot'],
        team: data['team'],
        teamLogo: data['teamLogo'],
        height: data['height'],
        weight: data['weight'],
        birthCity: data['birthCity'],
        birthCountry: data['birthCountry'],
      );
    }).toList();

    notifyListeners();
  }

  bool isFavorite(String playerId) {
    return _favorites.any((p) => p.id == playerId);
  }

  Future<void> addFavorite(Player player) async {
    if (isFavorite(player.id)) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(player.id)
        .set({
      'name': player.name,
      'headshot': player.headshot,
      'team': player.team,
      'teamLogo': player.teamLogo,
      'height': player.height,
      'weight': player.weight,
      'birthCity': player.birthCity,
      'birthCountry': player.birthCountry
    });

    _favorites.add(player);
    notifyListeners();
  }

  Future<void> removeFavorite(String playerId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(playerId)
        .delete();

    _favorites.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _favorites.clear();
    notifyListeners();
  }
}
