import 'package:flutter/material.dart';

import 'screens/collection_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_screen.dart';
import 'state/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = await GameState.load();
  runApp(TinyRoomApp(game: game));
}

class TinyRoomApp extends StatelessWidget {
  final GameState game;

  const TinyRoomApp({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GameScope(
      state: game,
      child: MaterialApp(
        title: 'Tiny Room',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFB5838D),
          useMaterial3: true,
        ),
        home: const MainShell(),
      ),
    );
  }
}

/// Доод талын 5 таб: Home, Editor, Shop, Collection, Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    EditorScreen(),
    ShopScreen(),
    CollectionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chair_outlined), label: 'Room'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.collections_outlined), label: 'Collection'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
