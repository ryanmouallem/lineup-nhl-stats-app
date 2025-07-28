import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/player_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final Set<String> nhlTeams = {
    'ANA','ARI','BOS','BUF','CGY','CAR','CHI','COL','CBJ','DAL','DET','EDM','FLA',
    'LAK','MIN','MTL','NSH','NJD','NYI','NYR','OTT','PHI','PIT','SJS','SEA','STL',
    'TBL','TOR','VAN','VGK','WSH','WPG'
  };

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PlayerService().fetchPlayerDetails(args['id'].toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final player = snapshot.data!;
          final allSeasons = player['seasons'] ?? [];
          final careerTotals = player['careerTotals'] ?? {};
          final regularSeasons = allSeasons.where((s) => s['gameTypeId'] == 2).toList();
          final playoffSeasons = allSeasons.where((s) => s['gameTypeId'] == 3).toList();
          final playoffTotals = _calculateTotals(playoffSeasons);

          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Stack(children: [
              _buildHeader(player),
              Positioned(top: 40, left: 10, child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )),
            ])),
            _stickyHeader('Regular Season'),
            SliverToBoxAdapter(child: _buildStatsHeader()),
            _buildSeasonList(regularSeasons),
            SliverToBoxAdapter(child: _buildTotalsRow(careerTotals)),
            _stickyHeader('Playoffs'),
            SliverToBoxAdapter(child: _buildStatsHeader()),
            _buildSeasonList(playoffSeasons),
            SliverToBoxAdapter(child: _buildTotalsRow(playoffTotals, isCalculated: true)),
          ]);
        },
      ),
    );
  }

  Widget _buildHeader(Map player) => Container(
    width: double.infinity,
    padding: EdgeInsets.only(top: 60, bottom: 30),
    decoration: BoxDecoration(color: Color(0xFF033950)),
    child: Column(children: [
      Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              image: DecorationImage(image: NetworkImage(player['headshot']), fit: BoxFit.cover)),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(child: SvgPicture.network(player['teamLogo'], width: 42, height: 42, fit: BoxFit.cover))),
        )
      ]),
      SizedBox(height: 12),
      Text(player['name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(player['team'], style: TextStyle(fontSize: 16, color: Colors.white70)),
      SizedBox(height: 8),
      Text('${player['height']} • ${player['weight']} lbs • ${player['birthCity']}, ${player['birthCountry']}',
          style: TextStyle(color: Colors.white70)),
    ]),
  );

  SliverPersistentHeader _stickyHeader(String title) => SliverPersistentHeader(
    pinned: true,
    delegate: _HeaderDelegate(title),
  );

  Widget _buildStatsHeader() => Container(
    color: Colors.grey.shade100,
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    child: Row(children: [
      _headerCell('Year'),
      _headerCell('Team'),
      _headerCell('GP'),
      _headerCell('G'),
      _headerCell('A'),
      _headerCell('P'),
      _headerCell('+/-'),
      _headerCell('PIM'),
    ]),
  );

  SliverList _buildSeasonList(List<Map<String, dynamic>> seasons) => SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      final s = seasons[index];
      final year = _formatYear(s['season']);
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 1))
          ]),
          child: Row(children: [
            _dataCell(year),
            _dataCell(s['teamAbbrev']),
            _dataCell(s['gamesPlayed']),
            _dataCell(s['goals']),
            _dataCell(s['assists']),
            _dataCell(s['points']),
            _dataCell(s['plusMinus']),
            _dataCell(s['pim']),
          ]));
    }, childCount: seasons.length),
  );

  Widget _buildTotalsRow(Map totals, {bool isCalculated = false}) => Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(color: Color(0xFF033950).withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
    child: Row(children: [
      _dataCell('Total', color: Colors.white, bold: true),
      _dataCell('', color: Colors.white),
      _dataCell((isCalculated ? totals['gp'] : totals['gamesPlayed']) ?? 0, color: Colors.white),
      _dataCell((isCalculated ? totals['g'] : totals['goals']) ?? 0, color: Colors.white),
      _dataCell((isCalculated ? totals['a'] : totals['assists']) ?? 0, color: Colors.white),
      _dataCell((isCalculated ? totals['p'] : totals['points']) ?? 0, color: Colors.white),
      _dataCell((isCalculated ? totals['pm'] : totals['plusMinus']) ?? 0, color: Colors.white),
      _dataCell((isCalculated ? totals['pim'] : totals['pim']) ?? 0, color: Colors.white),
    ]),
  );

  String _formatYear(String season) {
    final startYear = int.tryParse(season.substring(0, 4)) ?? 0;
    final endYear = (startYear + 1).toString().substring(2);
    return '${startYear.toString().substring(2)}-$endYear';
  }

  Map<String, int> _calculateTotals(List<Map<String, dynamic>> seasons) {
    int gp = 0, g = 0, a = 0, p = 0, pm = 0, pim = 0;
    for (var s in seasons) {
      gp += ((s['gamesPlayed'] ?? 0) as num).toInt();
      g += ((s['goals'] ?? 0) as num).toInt();
      a += ((s['assists'] ?? 0) as num).toInt();
      p += ((s['points'] ?? 0) as num).toInt();
      pm += ((s['plusMinus'] ?? 0) as num).toInt();
      pim += ((s['pim'] ?? 0) as num).toInt();
    }
    return {'gp': gp, 'g': g, 'a': a, 'p': p, 'pm': pm, 'pim': pim};
  }

  Widget _headerCell(String text) => Expanded(
    child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _dataCell(dynamic value, {Color color = Colors.black87, bool bold = false}) => Expanded(
    child: Text(value.toString(),
        textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: color, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
  );
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _HeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
    color: Colors.grey.shade200,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
  );

  @override
  double get maxExtent => 36;
  @override
  double get minExtent => 36;
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => oldDelegate.title != title;
}



