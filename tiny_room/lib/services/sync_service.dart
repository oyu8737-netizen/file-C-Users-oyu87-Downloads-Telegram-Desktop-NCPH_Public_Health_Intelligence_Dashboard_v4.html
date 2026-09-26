import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state/game_state.dart';
import 'cloud_service.dart';

/// Утсан дээрх GameState ↔ Firebase cloud хоёрыг ижил байлгана.
///
/// - Нэвтрэх үед: cloud дээр илүү их алхамтай хувилбар байвал түүнийг авна
///   (шинэ утас авсан ч өрөө чинь алга болохгүй).
/// - Өөрчлөлт бүрийн дараа 3 секунд хүлээгээд cloud-д хадгална
///   (тавилга чирэх үед секундэд 60 удаа бичихгүйн тулд).
class CloudSync {
  final GameState game;
  final CloudService cloud;

  Timer? _debounce;
  String? _uid;

  CloudSync({required this.game, required this.cloud}) {
    game.addListener(_schedulePush);
    cloud.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  Future<void> _onAuthChanged() async {
    final uid = cloud.user?.uid;
    if (uid == _uid) return;
    final previous = _uid;
    _uid = uid;

    if (uid == null) {
      // Гарсан бол дараагийн хүн таны өрөөг харахгүйн тулд цэвэрлэнэ.
      // (Өгөгдөл cloud-д хадгалагдсан тул дахин нэвтрэхэд буцаж ирнэ.)
      if (previous != null) game.reset();
      return;
    }

    try {
      final remote = await cloud.fetchGame();
      final remoteSteps = (remote?['totalSteps'] as num?)?.toInt() ?? -1;
      final localEmpty = game.totalSteps == 0 && game.owned.isEmpty;
      if (remote != null && (localEmpty || remoteSteps >= game.totalSteps)) {
        game.loadJson(remote);
      } else {
        await cloud.pushGame(game);
      }
    } catch (e) {
      debugPrint('CloudSync: $e');
    }
  }

  void _schedulePush() {
    if (_uid == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () {
      cloud.pushGame(game).catchError((Object e) => debugPrint('push: $e'));
    });
  }

  void dispose() {
    _debounce?.cancel();
    game.removeListener(_schedulePush);
    cloud.removeListener(_onAuthChanged);
  }
}
