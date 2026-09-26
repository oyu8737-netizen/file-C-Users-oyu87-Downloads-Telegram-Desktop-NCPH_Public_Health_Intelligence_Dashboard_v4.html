import 'package:flutter/foundation.dart';

import '../models/furniture.dart';

/// Аппын бүх текст — монгол (mn) ба англи (en).
///
/// Дэлгэц дээр: `final s = SettingsScope.strings(context);` → `Text(s.homeTitle)`
/// Шинэ текст нэмэх бол энд `mn ? 'Монгол' : 'English'` гэж нэг мөр нэмнэ.
class S {
  final bool mn;
  const S(this.mn);

  String _t(String mongolian, String english) => mn ? mongolian : english;

  // ── Навигаци ──
  String get navHome => _t('Гэр', 'Home');
  String get navRoom => _t('Өрөө', 'Room');
  String get navShop => _t('Дэлгүүр', 'Shop');
  String get navFriends => _t('Найзууд', 'Friends');
  String get navProfile => _t('Би', 'Profile');

  // ── Нийтлэг ──
  String get cancel => _t('Болих', 'Cancel');
  String get delete => _t('Устгах', 'Delete');
  String get refresh => _t('Шинэчлэх', 'Refresh');
  String get retry => _t('Дахин оролдох', 'Retry');
  String get add => _t('Нэмэх', 'Add');
  String get copy => _t('Хуулах', 'Copy');
  String get copied => _t('Хуулагдлаа', 'Copied');
  String get networkError =>
      _t('Холболтын алдаа. Интернэтээ шалгаад дахин оролдоно уу.',
          'Connection problem. Check your internet and try again.');
  String get today => _t('өнөөдөр', 'today');
  String get coinsLabel => 'coin';
  String get streakLabel => 'streak';
  String get levelLabel => 'level';
  String get totalLabel => _t('нийт алхам', 'total steps');
  String stepsCount(int n) => _t('$n алхам', '$n steps');
  String peopleCount(int n) => _t('$n хүн', '$n people');
  String weekday(DateTime d) => (mn
      ? const ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня']
      : const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'])[d.weekday - 1];

  // ── Home ──
  String get homeTitle => _t('МИНИЙ ӨРӨӨ', 'MY LITTLE ROOM');
  String get roomEmpty => _t('Өрөө хоосон байна.\nАлхаж coin цуглуулаарай! 🚶',
      'Your room is empty.\nWalk to earn coins! 🚶');
  String dailyGoal(int now, int goal) =>
      _t('Өдрийн зорилго: $now / $goal', 'Daily goal: $now / $goal');
  String get testSteps =>
      _t('Туршилтын алхам (prototype)', 'Test steps (prototype)');

  // Алхмын эх сурвалж
  String get sourceHealth => defaultTargetPlatform == TargetPlatform.iOS
      ? 'Apple Health'
      : 'Health Connect';
  String get sourceSensor => _t('утасны мэдрэгч', 'phone sensor');
  String get stepsStarting => _t('Алхам тоологч шалгаж байна…', 'Checking step counter…');
  String get stepsUnsupported => _t(
      'Энэ төхөөрөмж дээр алхам автоматаар тоологдохгүй. Утсан дээр суулгавал алхам тань өөрөө орж ирнэ.',
      'Steps are not counted automatically on this device. Install on your phone to sync real steps.');
  String connectStepsTitle(String source) =>
      _t('$source-тэй холбох', 'Connect to $source');
  String get connectStepsBody => _t(
      'Утас тань алхмыг өдөржин тоолдог. Зөвшөөрөл өгвөл алхам бүр coin болно.',
      'Your phone counts your steps all day. Allow access and every step becomes coins.');
  String get connectSteps => _t('Алхам холбох', 'Connect steps');
  String get installHealthConnect =>
      _t('Health Connect суулгах', 'Install Health Connect');
  String stepsConnected(String source) =>
      _t('✓ $source-тэй холбогдсон', '✓ Connected to $source');
  String lastSynced(String time) =>
      _t('Сүүлд шинэчилсэн: $time', 'Last synced: $time');
  String sensorHint(bool sensor) => sensor
      ? _t('Апп нээлттэй үед алхам тоологдоно', 'Counts steps while the app is open')
      : _t('Шинэчилж байна…', 'Syncing…');
  String get stepsError =>
      _t('Алхам уншихад алдаа гарлаа', 'Could not read steps');

  // Шагнал
  String stepsEarned(int steps, int coins) => _t(
      '🚶 +$steps алхам  →  🪙 +$coins coin', '🚶 +$steps steps  →  🪙 +$coins coins');
  String goalBonusText(int c) =>
      _t('🎯 Өдрийн зорилго биеллээ! +$c coin', '🎯 Daily goal reached! +$c coins');
  String streakBonusText(int c) =>
      _t('🔥 Streak bonus +$c coin', '🔥 Streak bonus +$c coins');
  String unlockedText(String emoji, String name) =>
      _t('🎉 $emoji $name нээгдлээ!', '🎉 $emoji $name unlocked!');

  // ── Room editor ──
  String get editorTitle => _t('Өрөө засах', 'Edit room');
  String get editorEmpty =>
      _t('Доороос тавилга сонгож тавиарай', 'Pick furniture below to place it');
  String get editorHint => _t('Тавилга дээр дарж сонгоод, чирж зөөнө.',
      'Tap furniture to select it, drag to move.');
  String get rotate => _t('Эргүүлэх', 'Rotate');
  String get putAway => _t('Агуулах руу', 'Put away');
  String get colorLabel => _t('Өнгө', 'Color');
  String get originalColor => _t('Анхны өнгө', 'Original color');
  String get inventory => _t('Миний агуулах', 'My inventory');
  String get inventoryEmpty => _t('Агуулах хоосон. Дэлгүүрээс тавилга аваарай 🛒',
      'Inventory is empty. Buy furniture in the shop 🛒');

  // ── Shop ──
  String get shopTitle => _t('ДЭЛГҮҮР', 'SHOP');
  String get shopTab => _t('Дэлгүүр', 'Shop');
  String collectionTab(int have, int all) =>
      _t('Цуглуулга $have/$all', 'Collection $have/$all');
  String get owned => _t('Байгаа', 'Owned');
  String bought(String emoji, String name) => _t(
      '$emoji $name авлаа! Өрөөндөө тавиарай.', '$emoji $name bought! Place it in your room.');
  String requirement(Furniture f) {
    switch (f.unlockType) {
      case UnlockType.none:
        return '';
      case UnlockType.streak:
        return _t('${f.unlockValue} хоног дараалан идэвхтэй',
            '${f.unlockValue}-day streak');
      case UnlockType.totalSteps:
        return _t('Нийт ${f.unlockValue} алхам', '${f.unlockValue} total steps');
      case UnlockType.level:
        return 'Level ${f.unlockValue}';
    }
  }

  String get howToEarn => _t('Coin хэрхэн олох вэ?', 'How to earn coins');
  String ruleSteps(int n) =>
      _t('🚶 $n алхам тутамд 1 coin', '🚶 1 coin for every $n steps');
  String ruleGoal(int goal, int bonus) => _t(
      '🎯 Өдөрт $goal алхамд хүрвэл +$bonus bonus',
      '🎯 Reach $goal steps a day: +$bonus bonus');
  String ruleStreak(int perDay, int cap) => _t(
      '🔥 Дараалсан өдөр бүрт +$perDay × streak (дээд тал нь $cap)',
      '🔥 Each streak day: +$perDay × streak (up to $cap)');

  // ── Friends ──
  String get friendsTitle => _t('Найзууд', 'Friends');
  String get needsFirebase => _t(
      'Найзын функц ажиллахын тулд Firebase тохируулах хэрэгтэй.\n(GUIDE_FIREBASE_MN.md-г үзнэ үү)',
      'Friends need Firebase to be set up.\n(See GUIDE_FIREBASE_MN.md)');
  String get friendsNeedAccount => _t(
      'Найзуудтайгаа холбогдохын тулд account үүсгэж нэвтэрнэ үү.',
      'Create an account to connect with friends.');
  String get myFriendCode => _t('Миний найзын код', 'My friend code');
  String get shareCodeHint => _t(
      'Энэ кодыг найздаа илгээгээрэй. Найз тань кодыг оруулмагц та хоёр бие биенийхээ өрөөг харах боломжтой болно.',
      'Share this code. Once your friend enters it, you can visit each other\'s rooms.');
  String get friendCodeInput => _t('Найзын код', "Friend's code");
  String get myFriends => _t('Миний найзууд', 'My friends');
  String get noFriends => _t('Одоогоор найз алга. Код солилцоод нэмээрэй! 👋',
      'No friends yet. Swap codes to add one! 👋');
  String get visitRoom => _t('Өрөөнд нь зочлох →', 'Visit room →');
  String get removeFriend => _t('Найзаас хасах', 'Remove friend');
  String removeFriendQ(String name) =>
      _t('$name-г найзаас хасах уу?', 'Remove $name from friends?');
  String get friendAdded => _t('🎉 Найз нэмэгдлээ!', '🎉 Friend added!');
  String get friendNotFound =>
      _t('Ийм код олдсонгүй', 'No one has that code');
  String get friendSelf => _t('Энэ таны өөрийн код байна 🙂', "That's your own code 🙂");
  String get friendAlready => _t('Аль хэдийн найз болсон', 'Already friends');
  String friendRoomTitle(String name) =>
      _t('$name-ийн өрөө', "$name's room");
  String get friendRoomEmpty => _t('Өрөө нь хоосон байна', 'The room is empty');

  // ── Profile ──
  String get profileTitle => _t('Би', 'Profile');
  String toNextLevel(int n) =>
      _t('Дараагийн level хүртэл $n алхам', '$n steps to next level');
  String get last7Days => _t('Сүүлийн 7 хоног', 'Last 7 days');
  String goalLineHint(int goal) => _t(
      'Шугам = өдрийн зорилго ($goal). Баганад дарж тоог харна.',
      'Line = daily goal ($goal). Tap a bar to see the number.');
  String streakDays(int n) =>
      _t('$n хоногийн streak', '$n-day streak');
  String activeDaysText(int n) => _t(
      'Нийт $n өдөр зорилгодоо хүрсэн', 'Reached the goal on $n days');
  String get language => _t('Хэл', 'Language');
  String get testTools => _t('Туршилт (prototype)', 'Testing (prototype)');
  String get nextDay => _t('Дараагийн өдөр рүү шилжих', 'Skip to next day');
  String get resetAll => _t('Бүгдийг эхнээс нь', 'Reset everything');
  String get resetQ => _t('Бүгдийг устгах уу?', 'Delete everything?');
  String get resetBody => _t('Coin, алхам, тавилга бүгд тэглэгдэнэ.',
      'Coins, steps and furniture will be reset.');

  // ── Account ──
  String get tagline => _t('Алхах тусам өрөө чинь томордог',
      'Every step grows your little room');
  String get signIn => _t('Нэвтрэх', 'Sign in');
  String get signUp => _t('Бүртгүүлэх', 'Sign up');
  String get signOut => _t('Гарах', 'Sign out');
  String get signOutQ => _t('Гарах уу?', 'Sign out?');
  String get signOutBody => _t(
      'Таны өрөө cloud-д хадгалагдсан. Дахин нэвтрэхэд буцаж ирнэ.',
      'Your room is saved in the cloud and will be back when you sign in.');
  String get nameLabel => _t('Нэр (найзуудад харагдана)', 'Name (shown to friends)');
  String get emailLabel => _t('Имэйл', 'Email');
  String get passwordLabel => _t('Нууц үг', 'Password');
  String get passwordHint => _t('Хамгийн багадаа 6 тэмдэгт', 'At least 6 characters');
  String get forgotPassword => _t('Нууц үгээ мартсан', 'Forgot password');
  String get enterEmailFirst =>
      _t('Эхлээд имэйлээ бичнэ үү', 'Enter your email first');
  String get resetSent => _t('Нууц үг сэргээх холбоос имэйлээр илгээгдлээ',
      'Password reset link sent to your email');
  String get continueWithout =>
      _t('Account-гүй үргэлжлүүлэх', 'Continue without account');
  String get continueWithoutHint => _t(
      'Өгөгдөл зөвхөн энэ утсан дээр хадгалагдана. Найзын функц ажиллахгүй.',
      'Data stays on this device only. Friends are unavailable.');
  String get notSignedIn => _t('Нэвтрээгүй байна', 'Not signed in');
  String get notSignedInHint => _t('Нэвтэрвэл өрөө тань cloud-д хадгалагдаж, найзуудтайгаа холбогдоно',
      'Sign in to back up your room and add friends');
  String get errRequired => _t('Заавал бөглөнө', 'Required');
  String get errInvalidEmail => _t('Имэйл буруу байна', 'Invalid email');
  String get errEmailInUse =>
      _t('Энэ имэйлээр бүртгэл аль хэдийн байна', 'This email is already registered');
  String get errWeakPassword =>
      _t('Нууц үг хамгийн багадаа 6 тэмдэгт', 'Password must be at least 6 characters');
  String get errWrongLogin => _t('Имэйл эсвэл нууц үг буруу', 'Wrong email or password');
  String get errTooMany =>
      _t('Хэт олон оролдлого. Түр хүлээгээд дахин оролдоно уу.', 'Too many attempts. Try again later.');
  String get errGeneric => _t('Алдаа гарлаа', 'Something went wrong');

  // ── Admin ──
  String get adminTitle => _t('Хэрэглэгчийн статистик', 'User statistics');
  String get adminSubtitle => _t('Зөвхөн admin харна', 'Admin only');
  String get statTotalUsers => _t('Нийт хэрэглэгч', 'Total users');
  String get statActiveToday => _t('Өнөөдөр идэвхтэй', 'Active today');
  String get statActive7 => _t('7 хоногт идэвхтэй', 'Active in 7 days');
  String get statNewToday => _t('Өнөөдөр шинэ', 'New today');
  String get statAllSteps => _t('Бүх хэрэглэгчийн нийт алхам', 'Total steps of all users');
  String get statSignups7 =>
      _t('Шинэ бүртгэл — сүүлийн 7 хоног', 'New sign-ups — last 7 days');
  String get adminConsoleHint => _t(
      'Дэлгэрэнгүйг Firebase Console → Analytics хэсгээс харна (өдөр бүрийн идэвхтэй хэрэглэгч, улс, төхөөрөмж). App Store / Google Play-ээс татсан тоо тэдгээрийн өөрийн хяналтын самбарт гарна.',
      'More detail in Firebase Console → Analytics (daily active users, countries, devices). Store download counts appear in App Store Connect / Google Play Console.');
}
