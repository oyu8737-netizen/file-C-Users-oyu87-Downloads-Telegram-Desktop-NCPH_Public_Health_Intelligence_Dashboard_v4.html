import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state/game_state.dart';
import 'cloud_service.dart';

/// Утсан дээрх GameState ↔ Firebase cloud хоёрыг ижил байлгана.
///
/// - Нэвтрэх үед (шинэ утас, компьютер, вэб — аль ч төхөөрөмж):
///   cloud-д хадгалсан өрөө, coin, тавилгыг татаж авна. Энэ төхөөрөмж дээр
///   нэвтрэхээс өмнө алхсан алхам байвал түүнийг нэмж нэгтгэнэ.
/// - Өөрчлөлт бүрийн дараа 3 секунд хүлээгээд cloud-д хадгална
///   (тавилга чирэх үед секундэд 60 удаа бичихгүйн тулд).
/// - Гарахад энэ төхөөрөмжөөс цэвэрлэнэ (дараагийн хүн таны өрөөг харахгүй).
class CloudSync {
  final GameState game;
  final CloudService cloud;

  /// Cloud-оос өмнөх ахиц сэргээгдсэн үед дуудагдана (мэдэгдэл харуулахад).
  final VoidCallback? onRestored;

  Timer? _debounce;
  String? _uid;

  /// Нэвтэрсний дараа cloud-оос татаж нэгтгэж дуустал cloud руу бичихгүй —
  /// эс тэгвэл энэ утасны өгөгдөл account-ын өгөгдлийг дарж бичнэ.
  bool _ready = false;

  CloudSync({required this.game, required this.cloud, this.onRestored}) {
    game.addListener(_schedulePush);
    cloud.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  Future<void> _onAuthChanged() async {
    final uid = cloud.user?.uid;
    if (uid == _uid) return;
    final previous = _uid;
    _uid = uid;
    _ready = false;
    _debounce?.cancel();

    if (uid == null) {
      if (previous != null) game.reset();
      return;
    }
    await _restore(uid);
  }

  /// Cloud-оос татаж нэгтгэнэ. Интернэт тасарвал 15 секундын дараа дахин оролдоно.
  Future<void> _restore(String uid) async {
    try {
      final remote = await cloud.fetchGame();
      if (_uid != uid) return; // энэ хооронд өөр хүн нэвтэрсэн/гарсан
      if (remote != null) {
        final localEmpty = game.totalSteps == 0 && game.owned.isEmpty;
        if (localEmpty) {
          game.loadJson(remote);
        } else {
          game.mergeRemote(remote);
        }
        onRestored?.call();
      }
      _ready = true;
      await cloud.pushGame(game);
    } catch (e) {
      debugPrint('CloudSync: $e');
      Timer(const Duration(seconds: 15), () {
        if (_uid == uid && !_ready) _restore(uid);
      });
    }
  }

  void _schedulePush() {
    if (_uid == null || !_ready) return;
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
