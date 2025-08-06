class Player {
  final String id;
  final String name;
  final String team;
  final String teamLogo;
  final String headshot;
  final String height;
  final int weight;
  final String birthCity;
  final String birthCountry;

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.teamLogo,
    required this.headshot,
    required this.height,
    required this.weight,
    required this.birthCity,
    required this.birthCountry,
  });

  factory Player.fromMap(Map<String, dynamic> map) => Player(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    team: map['team'] ?? '',
    teamLogo: map['teamLogo'] ?? '',
    headshot: map['headshot'] ?? '',
    height: map['height'] ?? '',
    weight: (map['weight'] is int) ? map['weight'] : int.tryParse(map['weight'].toString()) ?? 0,
    birthCity: map['birthCity'] ?? '',
    birthCountry: map['birthCountry'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'team': team,
    'teamLogo': teamLogo,
    'headshot': headshot,
    'height': height,
    'weight': weight,
    'birthCity': birthCity,
    'birthCountry': birthCountry,
  };
}
