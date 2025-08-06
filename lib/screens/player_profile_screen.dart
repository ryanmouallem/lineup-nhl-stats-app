import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/player_details.dart';
import '../services/player_service.dart';
import '../providers/favorites_provider.dart';
import '../models/player.dart';

class PlayerProfileScreen extends StatefulWidget {
  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: FutureBuilder<PlayerDetails>(
        future: PlayerService().fetchPlayerDetails(args['id'].toString()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final details = snapshot.data!;
          final player = details.player;
          final regularSeasons = details.seasons.where((s) => s['gameTypeId'] == 2).toList();
          final playoffSeasons = details.seasons.where((s) => s['gameTypeId'] == 3).toList();
          final playoffTotals = _calculateTotals(playoffSeasons);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    _buildHeader(player),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              _stickyHeader('Regular Season'),
              SliverToBoxAdapter(child: _buildStatsHeader()),
              _buildSeasonList(regularSeasons),
              SliverToBoxAdapter(child: _buildTotalsRow(details.careerTotals)),
              _stickyHeader('Playoffs'),
              SliverToBoxAdapter(child: _buildStatsHeader()),
              _buildSeasonList(playoffSeasons),
              SliverToBoxAdapter(child: _buildTotalsRow(playoffTotals, isCalculated: true)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(player) => Container(
    width: double.infinity,
    padding: EdgeInsets.only(top: 40, bottom: 30),
    decoration: BoxDecoration(color: Color(0xFF033950)),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          right: 10,
          child: AnimatedFavoriteButton(playerId: player.id, player: player),
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: DecorationImage(image: NetworkImage(player.headshot), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: ClipOval(
                      child: SvgPicture.network(player.teamLogo, width: 42, height: 42, fit: BoxFit.cover),
                    ),
                  ),
                )
              ]),
              SizedBox(height: 12),
              Text(player.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(player.team, style: TextStyle(fontSize: 16, color: Colors.white70)),
              SizedBox(height: 8),
              Text('${player.height} • ${player.weight} lbs • ${player.birthCity}, ${player.birthCountry}',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    ),
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
      final team = (s['teamAbbrev'] ?? '-').toString();
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 1))
          ]),
          child: Row(children: [
            _dataCell(year),
            _dataCell(team),
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

  String _formatYear(String season) {
    final startYear = int.tryParse(season.substring(0, 4)) ?? 0;
    final endYear = (startYear + 1).toString().substring(2);
    return '${startYear.toString().substring(2)}-$endYear';
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

class AnimatedFavoriteButton extends StatefulWidget {
  final String playerId;
  final Player player;
  const AnimatedFavoriteButton({required this.playerId, required this.player});
  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _sparkController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)).animate(_scaleController);
    _sparkController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    _sparkController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        final isFav = favProvider.isFavorite(widget.playerId);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
              child: IconButton(
                iconSize: 36,
                icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber),
                onPressed: () {
                  isFav ? favProvider.removeFavorite(widget.playerId) : favProvider.addFavorite(widget.player);
                  _triggerAnimation();
                },
              ),
            ),
            Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _SparkPainter(_sparkController))))
          ],
        );
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  final Animation<double> animation;
  _SparkPainter(this.animation) : super(repaint: animation);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.amber.withOpacity(1 - animation.value)..strokeWidth = 2..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final radius = 20 * animation.value;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(dx, dy), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
