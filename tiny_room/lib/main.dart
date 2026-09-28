import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'l10n/strings.dart';
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

/// Аль ч газраас доод мэдэгдэл (SnackBar) харуулахад.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Утсан дээр хадгалсан өгөгдлөө ачаална.
  final settings = await SettingsState.load();
  final game = await GameState.load();

  // 2. Firebase (тохируулаагүй бол null → offline горим).
  //    Нэвтрэхэд cloud-д хадгалсан өрөө, coin автоматаар сэргээгдэнэ.
  final cloud = await CloudService.init();
  if (cloud != null) {
    CloudSync(
      game: game,
      cloud: cloud,
      onRestored: () => messengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text(S(settings.lang).restored))),
    );
  }

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
          // Хэл солигдоход аппын өнгө ч тухайн улсынх болно.
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) => MaterialApp(
              title: 'Tiny Room',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: messengerKey,
              theme: ThemeData(
                colorSchemeSeed: settings.lang.vibe.seed,
                useMaterial3: true,
              ),
              home: const AuthGate(),
            ),
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

/// 5 хэсэгтэй үндсэн цэс: Гэр, Өрөө, Дэлгүүр, Найзууд, Би.
///
/// - Том дэлгэц (компьютер, таблет): зүүн талд цэс. ☰ товчоор хураана/дэлгэнэ.
/// - Утас: доод цэс. Доош гүйлгэхэд нуугдаж, дээш гүйлгэхэд гарч ирнэ.
///   "Би" хэсгээс цэсний бичгийг нууж жижигрүүлж болно.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Энэ өргөнөөс дээш бол хажуугийн цэс харуулна.
  static const wideBreakpoint = 720.0;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _barVisible = true;

  static const _screens = [
    HomeScreen(),
    EditorScreen(),
    ShopScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];

  static const _icons = [
    (Icons.home_outlined, Icons.home),
    (Icons.chair_outlined, Icons.chair),
    (Icons.storefront_outlined, Icons.storefront),
    (Icons.people_outline, Icons.people),
    (Icons.person_outline, Icons.person),
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

  List<String> _labels(S s) =>
      [s.navHome, s.navRoom, s.navShop, s.navFriends, s.navProfile];

  void _select(int i) => setState(() {
        _index = i;
        _barVisible = true;
      });

  /// Утсан дээр: гүйлгэх чиглэлээр доод цэсийг нууж/харуулна.
  bool _onScroll(UserScrollNotification n) {
    if (n.depth != 0) return false;
    if (n.direction == ScrollDirection.reverse && _barVisible) {
      setState(() => _barVisible = false);
    } else if (n.direction == ScrollDirection.forward && !_barVisible) {
      setState(() => _barVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final s = SettingsScope.strings(context);
    final labels = _labels(s);
    final wide = MediaQuery.sizeOf(context).width >= MainShell.wideBreakpoint;
    final body = IndexedStack(index: _index, children: _screens);

    if (wide) {
      final expanded = settings.menuExpanded;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: expanded,
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: expanded ? null : NavigationRailLabelType.none,
              leading: IconButton(
                key: const ValueKey('menu_toggle'),
                tooltip: expanded ? s.collapseMenu : s.expandMenu,
                icon: Icon(expanded ? Icons.menu_open : Icons.menu),
                onPressed: settings.toggleMenu,
              ),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i].$1),
                    selectedIcon: Icon(_icons[i].$2),
                    label: Text(labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: body,
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _barVisible
            ? NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _select,
                height: settings.menuExpanded ? 72 : 56,
                labelBehavior: settings.menuExpanded
                    ? NavigationDestinationLabelBehavior.alwaysShow
                    : NavigationDestinationLabelBehavior.alwaysHide,
                destinations: [
                  for (var i = 0; i < labels.length; i++)
                    NavigationDestination(
                      icon: Icon(_icons[i].$1),
                      selectedIcon: Icon(_icons[i].$2),
                      label: labels[i],
                    ),
                ],
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}
