import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../services/auth_service.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardButton(
              context,
              label: 'Search Players',
              onTap: () => Navigator.pushNamed(context, '/search'),
            ),
            SizedBox(height: 16),
            _buildCardButton(
              context,
              label: 'View Favourites',
              onTap: () => Navigator.pushNamed(context, '/favourites'),
            ),
            SizedBox(height: 16),
            _buildCardButton(
              context,
              label: 'Logout',
              color: Colors.redAccent,
              textColor: Colors.white,
              onTap: () async {
                final provider = Provider.of<FavoritesProvider?>(context, listen: false);
                provider?.clearFavorites();
                await AuthService().signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(BuildContext context,
      {required String label,
        required VoidCallback onTap,
        Color color = Colors.white,
        Color textColor = Colors.black}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(label,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
