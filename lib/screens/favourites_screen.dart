import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/player.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider?>(context);
    final favorites = favoritesProvider?.favorites ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Favourites', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: favorites.isEmpty
          ? Center(child: Text('No favourites added yet', style: TextStyle(fontSize: 16, color: Colors.black54)))
          : ListView.separated(
        padding: EdgeInsets.all(12),
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final Player player = favorites[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(player.headshot)),
              title: Text(player.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(player.team, style: TextStyle(color: Colors.black54)),
              trailing: favoritesProvider == null
                  ? null
                  : Consumer<FavoritesProvider>(
                builder: (context, favProvider, _) {
                  final isFav = favProvider.isFavorite(player.id);
                  return IconButton(
                    icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
                    onPressed: () {
                      isFav ? favProvider.removeFavorite(player.id) : favProvider.addFavorite(player);
                    },
                  );
                },
              ),
              onTap: () => Navigator.pushNamed(context, '/profile', arguments: {'id': player.id}),
            ),
          );
        },
      ),
    );
  }
}
