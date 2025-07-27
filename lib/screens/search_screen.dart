import 'package:flutter/material.dart';
import '../services/nhl_api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final NhlApiService _apiService = NhlApiService();

  List<Map<String, dynamic>> _allPlayers = [];
  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await _apiService.fetchAllPlayers();
    setState(() {
      _allPlayers = players;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredPlayers = _allPlayers
        .where((player) =>
        player['name'].toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Search Players'),
        backgroundColor: Color(0xFF0A0A0A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search by player name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033950),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: () {},
                    child: Icon(Icons.search, size: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _query.isEmpty
                  ? Center(
                child: Text(
                  'Start typing and press Search',
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
                  : filteredPlayers.isEmpty
                  ? Center(
                child: Text(
                  'No players found',
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[700]),
                ),
              )
                  : ListView.separated(
                itemCount: filteredPlayers.length,
                separatorBuilder: (_, __) => Divider(
                  color: Color(0xFF033950).withOpacity(0.2),
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];
                  return ListTile(
                    leading: SvgPicture.network(
                      'https://assets.nhle.com/logos/nhl/svg/${player['team']}_light.svg',
                      width: 32,
                      height: 32,
                      placeholderBuilder: (context) => Icon(Icons.shield, color: Colors.grey),
                    ),
                    title: Text(
                      player['name'],
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    subtitle: Text(
                      player['team'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: {
                          'name': player['name'],
                          'team': player['team'],
                          'id': player['id'],
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
