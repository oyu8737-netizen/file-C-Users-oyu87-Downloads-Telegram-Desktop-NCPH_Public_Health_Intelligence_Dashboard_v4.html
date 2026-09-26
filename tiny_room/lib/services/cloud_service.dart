import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import '../models/placed_item.dart';
import '../state/game_state.dart';

// Firestore дахь өгөгдлийн бүтэц:
//
//   users/{uid}                  ← нэг хэрэглэгч: нэр, найзын код, өрөө, алхам
//   users/{uid}/friends/{fid}    ← найзуудын жагсаалт (хоёр талдаа бичигдэнэ)
//   friendCodes/{CODE}           ← найзын код → uid (найз хайхад)
//   admins/{uid}                 ← энд байгаа хүн Admin статистик харна
//
// Хэн юуг унших/бичих эрхтэйг `firestore.rules` файл тодорхойлно.

class UserProfile {
  final String name;
  final String friendCode;
  const UserProfile({required this.name, required this.friendCode});
}

class FriendEntry {
  final String uid;
  final String name;
  const FriendEntry(this.uid, this.name);
}

/// Найзын өрөөг харахад хэрэгтэй мэдээлэл.
class FriendRoom {
  final String name;
  final int level;
  final int streak;
  final int todaySteps;
  final int totalSteps;
  final List<PlacedItem> placed;

  const FriendRoom({
    required this.name,
    required this.level,
    required this.streak,
    required this.todaySteps,
    required this.totalSteps,
    required this.placed,
  });
}

enum AddFriendResult { added, notFound, self, already }

/// Admin хуудсанд харуулах статистик.
class AdminStats {
  final int totalUsers;
  final int activeToday;
  final int active7Days;
  final int newToday;
  final int totalSteps;

  /// Сүүлийн 7 хоногийн өдөр бүр шинээр бүртгүүлсэн хүн (хуучнаас шинэ рүү).
  final List<MapEntry<String, int>> signupsByDay;

  const AdminStats({
    required this.totalUsers,
    required this.activeToday,
    required this.active7Days,
    required this.newToday,
    required this.totalSteps,
    required this.signupsByDay,
  });
}

/// Firebase-тэй харьцах бүх зүйл нэг дор.
/// Firebase тохируулаагүй бол [init] null буцаах тул апп offline горимоор ажиллана.
class CloudService extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseAnalytics? _analytics;

  UserProfile? profile;
  bool isAdmin = false;
  StreamSubscription<User?>? _authSub;
  Future<void>? _profileLoading;

  /// Бүртгүүлж байх үед профайлыг [signUp] өөрөө (зөв нэрээр) үүсгэнэ.
  bool _signingUp = false;

  CloudService._(this._auth, this._db, this._analytics);

  static Future<CloudService?> init() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Firebase тохируулаагүй тул offline горим: $e');
      return null;
    }
    FirebaseAnalytics? analytics;
    try {
      analytics = FirebaseAnalytics.instance;
    } catch (_) {}
    final cloud = CloudService._(
        FirebaseAuth.instance, FirebaseFirestore.instance, analytics);
    cloud._authSub = cloud._auth.authStateChanges().listen(cloud._onAuth);
    return cloud;
  }

  User? get user => _auth.currentUser;
  bool get signedIn => user != null;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  static String _today() => GameState.dateKey(DateTime.now());

  // ───────────────────────── Account ─────────────────────────

  Future<void> _onAuth(User? u) async {
    if (_signingUp) return;
    if (u == null) {
      profile = null;
      isAdmin = false;
      _profileLoading = null;
    } else {
      await _ensureProfile(null);
      try {
        isAdmin = (await _db.collection('admins').doc(u.uid).get()).exists;
      } catch (_) {
        isAdmin = false;
      }
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    _signingUp = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name.trim());
      _profileLoading = null;
      await _ensureProfile(name.trim());
      isAdmin = false;
      _log(() => _analytics?.logSignUp(signUpMethod: 'email'));
    } catch (_) {
      _profileLoading = null; // дараагийн удаа дахин оролдоно
      rethrow;
    } finally {
      _signingUp = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    _log(() => _analytics?.logLogin(loginMethod: 'email'));
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// Хэрэглэгчийн профайл байхгүй бол үүсгэнэ (нэр + давтагдашгүй найзын код).
  Future<void> _ensureProfile(String? name) =>
      _profileLoading ??= _loadOrCreateProfile(name);

  Future<void> _loadOrCreateProfile(String? name) async {
    final u = user;
    if (u == null) return;
    final ref = _userDoc(u.uid);
    final snap = await ref.get();
    final data = snap.data();
    if (data != null && data['friendCode'] is String) {
      profile = UserProfile(
          name: data['name'] as String? ?? '', friendCode: data['friendCode']);
      return;
    }
    final displayName = (name?.isNotEmpty ?? false)
        ? name!
        : (u.displayName?.isNotEmpty ?? false)
            ? u.displayName!
            : (u.email ?? 'Player').split('@').first;
    final code = await _claimFriendCode(u.uid, displayName);
    await ref.set({
      'name': displayName,
      'friendCode': code,
      'createdAt': FieldValue.serverTimestamp(),
      'createdDay': _today(),
      'lastActive': _today(),
    }, SetOptions(merge: true));
    profile = UserProfile(name: displayName, friendCode: code);
  }

  /// Бусадтай давхцахгүй 6 тэмдэгттэй код (андуурагддаг 0/O, 1/I-г хассан).
  Future<String> _claimFriendCode(String uid, String name) async {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = math.Random.secure();
    for (var attempt = 0; attempt < 10; attempt++) {
      final code =
          List.generate(6, (_) => alphabet[rnd.nextInt(alphabet.length)])
              .join();
      final ref = _db.collection('friendCodes').doc(code);
      final ok = await _db.runTransaction((tx) async {
        if ((await tx.get(ref)).exists) return false;
        tx.set(ref, {'uid': uid, 'name': name});
        return true;
      });
      if (ok) return code;
    }
    throw StateError('Could not create friend code');
  }

  // ───────────────────────── Тоглоомын өгөгдөл sync ─────────────────────────

  Future<Map<String, dynamic>?> fetchGame() async {
    final u = user;
    if (u == null) return null;
    final data = (await _userDoc(u.uid).get()).data();
    final game = data?['game'];
    return game is Map ? Map<String, dynamic>.from(game) : null;
  }

  /// Утсан дээрх өгөгдлийг cloud-д хуулна. Найзууд өрөөг чинь эндээс харна.
  Future<void> pushGame(GameState g) async {
    final u = user;
    if (u == null) return;
    await _userDoc(u.uid).set({
      'game': g.toJson(),
      // Найзуудад болон admin статистикт хэрэгтэй хураангуй талбарууд:
      'level': g.level,
      'streak': g.streak,
      'todaySteps': g.todaySteps,
      'totalSteps': g.totalSteps,
      'lastActive': _today(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ───────────────────────── Найзууд ─────────────────────────

  Future<AddFriendResult> addFriendByCode(String rawCode) async {
    final u = user;
    final me = profile;
    if (u == null || me == null) return AddFriendResult.notFound;
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return AddFriendResult.notFound;
    if (code == me.friendCode) return AddFriendResult.self;

    final codeSnap = await _db.collection('friendCodes').doc(code).get();
    final data = codeSnap.data();
    if (data == null) return AddFriendResult.notFound;
    final friendUid = data['uid'] as String;
    final friendName = data['name'] as String? ?? '';
    if (friendUid == u.uid) return AddFriendResult.self;

    final mine = _userDoc(u.uid).collection('friends').doc(friendUid);
    if ((await mine.get()).exists) return AddFriendResult.already;

    // Хоёр талд нь зэрэг бичнэ → хоёулаа бие биенийхээ өрөөг харж чадна.
    final batch = _db.batch()
      ..set(mine, {'name': friendName, 'addedAt': FieldValue.serverTimestamp()})
      ..set(_userDoc(friendUid).collection('friends').doc(u.uid),
          {'name': me.name, 'addedAt': FieldValue.serverTimestamp()});
    await batch.commit();
    _log(() => _analytics?.logEvent(name: 'friend_added'));
    return AddFriendResult.added;
  }

  Stream<List<FriendEntry>> friends() {
    final u = user;
    if (u == null) return const Stream.empty();
    return _userDoc(u.uid).collection('friends').snapshots().map((s) => s.docs
        .map((d) => FriendEntry(d.id, d.data()['name'] as String? ?? ''))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> removeFriend(String friendUid) async {
    final u = user;
    if (u == null) return;
    final batch = _db.batch()
      ..delete(_userDoc(u.uid).collection('friends').doc(friendUid))
      ..delete(_userDoc(friendUid).collection('friends').doc(u.uid));
    await batch.commit();
  }

  Future<FriendRoom?> loadFriendRoom(String friendUid) async {
    final data = (await _userDoc(friendUid).get()).data();
    if (data == null) return null;
    final game = data['game'] is Map
        ? Map<String, dynamic>.from(data['game'] as Map)
        : const <String, dynamic>{};
    _log(() => _analytics?.logEvent(name: 'room_visited'));
    return FriendRoom(
      name: data['name'] as String? ?? '',
      level: (data['level'] as num?)?.toInt() ?? 1,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      // Өнөөдрийн алхам зөвхөн өнөөдөр идэвхтэй байсан бол хүчинтэй.
      todaySteps: data['lastActive'] == _today()
          ? (data['todaySteps'] as num?)?.toInt() ?? 0
          : 0,
      totalSteps: (data['totalSteps'] as num?)?.toInt() ?? 0,
      placed: ((game['placed'] as List?) ?? [])
          .map((e) => PlacedItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  // ───────────────────────── Admin ─────────────────────────

  Future<AdminStats> adminStats() async {
    final users = _db.collection('users');
    final now = DateTime.now();
    final today = _today();
    final weekAgo =
        GameState.dateKey(now.subtract(const Duration(days: 6)));

    Future<int> countOf(Query<Map<String, dynamic>> q) async =>
        (await q.count().get()).count ?? 0;

    final totals = await users.aggregate(count(), sum('totalSteps')).get();
    final dayKeys = [
      for (var i = 6; i >= 0; i--)
        GameState.dateKey(now.subtract(Duration(days: i)))
    ];
    final results = await Future.wait([
      countOf(users.where('lastActive', isEqualTo: today)),
      countOf(users.where('lastActive', isGreaterThanOrEqualTo: weekAgo)),
      for (final k in dayKeys) countOf(users.where('createdDay', isEqualTo: k)),
    ]);

    return AdminStats(
      totalUsers: totals.count ?? 0,
      totalSteps: (totals.getSum('totalSteps') ?? 0).round(),
      activeToday: results[0],
      active7Days: results[1],
      newToday: results.last,
      signupsByDay: [
        for (var i = 0; i < dayKeys.length; i++)
          MapEntry(dayKeys[i], results[2 + i])
      ],
    );
  }

  // ───────────────────────── Analytics ─────────────────────────

  void logPurchase(String furnitureId) => _log(() => _analytics?.logEvent(
      name: 'furniture_bought', parameters: {'item': furnitureId}));

  void _log(Future<void>? Function() call) {
    try {
      call()?.catchError((_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
