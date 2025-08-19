import 'package:http/http.dart' as http;

void main() async {
  final List<String> teams = [
    'ana', 'bos', 'buf', 'cgy', 'car', 'chi', 'col',
    'cbj', 'dal', 'det', 'edm', 'fla', 'lak', 'min', 'mtl',
    'nsh', 'njd', 'nyi', 'nyr', 'ott', 'phi', 'pit', 'sjs',
    'sea', 'stl', 'tbl', 'tor', 'uta', 'van', 'vgk', 'wsh', 'wpg'
  ];
  final String season = '20242025';

  for (var team in teams) {
    final url = Uri.parse('https://api-web.nhle.com/v1/roster/$team/$season');
    final response = await http.get(url);
    print('$team: ${response.statusCode}');
  }
}
