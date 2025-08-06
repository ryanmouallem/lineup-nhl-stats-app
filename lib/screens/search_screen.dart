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
    final filteredPlayers = _allPlayers
        .where((player) => player['name'].toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Search Players', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Search by player name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(0xFF033950),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _query.isEmpty
                  ? Center(
                child: Text(
                  'Start typing to search for players',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
                  : filteredPlayers.isEmpty
                  ? Center(
                child: Text(
                  'No players found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              )
                  : ListView.separated(
                itemCount: filteredPlayers.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: SvgPicture.network(
                        'https://assets.nhle.com/logos/nhl/svg/${player['team']}_light.svg',
                        width: 36,
                        height: 36,
                        placeholderBuilder: (context) => Icon(Icons.shield, color: Colors.grey),
                      ),
                      title: Text(
                        player['name'],
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                    ),
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
