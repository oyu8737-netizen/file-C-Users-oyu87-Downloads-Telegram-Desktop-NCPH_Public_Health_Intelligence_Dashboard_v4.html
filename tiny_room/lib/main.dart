import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_screen.dart';
import 'services/cloud_service.dart';
import 'services/step_service.dart';
import 'services/sync_service.dart';
import 'state/app_services.dart';
import 'state/game_state.dart';
import 'state/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Утсан дээр хадгалсан өгөгдлөө ачаална.
  final settings = await SettingsState.load();
  final game = await GameState.load();

  // 2. Firebase (тохируулаагүй бол null → offline горим).
  final cloud = await CloudService.init();
  if (cloud != null) CloudSync(game: game, cloud: cloud);

  // 3. Утасны алхам тоологчтой холбогдоно.
  final steps = StepSync(game);
  steps.start();

  runApp(TinyRoomApp(game: game, settings: settings, cloud: cloud, steps: steps));
}

class TinyRoomApp extends StatelessWidget {
  final GameState game;
  final SettingsState settings;
  final CloudService? cloud;
  final StepSync steps;

  const TinyRoomApp({
    super.key,
    required this.game,
    required this.settings,
    required this.cloud,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      state: settings,
      child: GameScope(
        state: game,
        child: AppServices(
          cloud: cloud,
          steps: steps,
          child: MaterialApp(
            title: 'Tiny Room',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFFB5838D),
              useMaterial3: true,
            ),
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}

/// Нэвтрээгүй бол нэвтрэх дэлгэц, нэвтэрсэн (эсвэл алгассан) бол үндсэн апп.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final cloud = AppServices.of(context).cloud;
    final settings = SettingsScope.of(context);
    if (cloud == null) return const MainShell();
    return ListenableBuilder(
      listenable: cloud,
      builder: (context, _) {
        if (cloud.signedIn || settings.authSkipped) return const MainShell();
        return AuthScreen(cloud: cloud);
      },
    );
  }
}

/// Доод талын 5 таб: Home, Room, Shop, Friends, Profile.
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
    FriendsScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Утаснаас шинэ алхам ирж coin авах бүрд доор мэдэгдэл гаргана.
    AppServices.of(context).steps.onReward = (result) {
      if (!mounted) return;
      showRewardSnack(ScaffoldMessenger.of(context), result,
          SettingsScope.strings(context));
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = SettingsScope.strings(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), label: s.navHome),
          NavigationDestination(
              icon: const Icon(Icons.chair_outlined), label: s.navRoom),
          NavigationDestination(
              icon: const Icon(Icons.storefront_outlined), label: s.navShop),
          NavigationDestination(
              icon: const Icon(Icons.people_outline), label: s.navFriends),
          NavigationDestination(
              icon: const Icon(Icons.person_outline), label: s.navProfile),
        ],
      ),
    );
  }
}
