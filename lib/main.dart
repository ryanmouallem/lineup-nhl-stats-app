import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/favorites_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/search_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(LineupApp());
}

class LineupApp extends StatelessWidget {
  const LineupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final user = snapshot.data;

        if (user == null || user.uid.isEmpty) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lineup',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: LoginScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/signup') return MaterialPageRoute(builder: (_) => SignupScreen());
              return MaterialPageRoute(builder: (_) => LoginScreen());
            },
          );
        }

        return ChangeNotifierProvider(
          create: (_) => FavoritesProvider(user.uid)..init(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lineup',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: LandingScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/login') return MaterialPageRoute(builder: (_) => LoginScreen());
              if (settings.name == '/signup') return MaterialPageRoute(builder: (_) => SignupScreen());
              if (settings.name == '/landing') return MaterialPageRoute(builder: (_) => LandingScreen());
              if (settings.name == '/search') return MaterialPageRoute(builder: (_) => SearchScreen());
              if (settings.name == '/favourites') return MaterialPageRoute(builder: (_) => FavouritesScreen());

              if (settings.name == '/profile') {
                final args = settings.arguments;
                if (args == null || args is! Map || !args.containsKey('id')) {
                  return MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: Center(child: Text('Missing or invalid player ID')),
                    ),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => PlayerProfileScreen(),
                  settings: settings,
                );
              }

              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(child: Text('404 Page Not Found')),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
