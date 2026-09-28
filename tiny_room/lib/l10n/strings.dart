import 'package:flutter/foundation.dart';

import '../models/furniture.dart';
import 'app_lang.dart';

export 'app_lang.dart';

/// Аппын бүх текст — 🇲🇳 монгол, 🇬🇧 англи, 🇨🇳 хятад.
///
/// Дэлгэц дээр: `final s = SettingsScope.strings(context);` → `Text(s.homeTitle)`
/// Шинэ текст нэмэх бол `_t('Монгол', 'English', '中文')` гэж нэг мөр нэмнэ.
class S {
  final AppLang lang;
  const S(this.lang);

  String _t(String mn, String en, String zh) => switch (lang) {
        AppLang.mn => mn,
        AppLang.en => en,
        AppLang.zh => zh,
      };

  // ── Навигаци ──
  String get navHome => _t('Гэр', 'Home', '首页');
  String get navRoom => _t('Өрөө', 'Room', '房间');
  String get navShop => _t('Дэлгүүр', 'Shop', '商店');
  String get navFriends => _t('Найзууд', 'Friends', '好友');
  String get navProfile => _t('Би', 'Profile', '我的');
  String get collapseMenu => _t('Цэс хураах', 'Collapse menu', '收起菜单');
  String get expandMenu => _t('Цэс дэлгэх', 'Expand menu', '展开菜单');

  // ── Нийтлэг ──
  String get cancel => _t('Болих', 'Cancel', '取消');
  String get delete => _t('Устгах', 'Delete', '删除');
  String get refresh => _t('Шинэчлэх', 'Refresh', '刷新');
  String get retry => _t('Дахин оролдох', 'Retry', '重试');
  String get add => _t('Нэмэх', 'Add', '添加');
  String get copy => _t('Хуулах', 'Copy', '复制');
  String get copied => _t('Хуулагдлаа', 'Copied', '已复制');
  String get networkError => _t(
      'Холболтын алдаа. Интернэтээ шалгаад дахин оролдоно уу.',
      'Connection problem. Check your internet and try again.',
      '网络连接出错，请检查网络后重试。');
  String get today => _t('өнөөдөр', 'today', '今天');
  String get coinsLabel => _t('coin', 'coins', '金币');
  String get streakLabel => _t('streak', 'streak', '连续');
  String get levelLabel => _t('level', 'level', '等级');
  String get totalLabel => _t('нийт алхам', 'total steps', '总步数');
  String stepsCount(int n) => _t('$n алхам', '$n steps', '$n 步');
  String peopleCount(int n) => _t('$n хүн', '$n people', '$n 人');
  String coins(int n) => _t('$n coin', '$n coins', '$n 金币');
  String weekday(DateTime d) => switch (lang) {
        AppLang.mn => const ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'],
        AppLang.en => const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
        AppLang.zh => const ['一', '二', '三', '四', '五', '六', '日'],
      }[d.weekday - 1];

  // ── Home ──
  String get homeTitle => _t('МИНИЙ ӨРӨӨ', 'MY LITTLE ROOM', '我的小屋');
  String get greeting => _t('Сайн байна уу!', 'Hello there!', '你好！');
  String get greetingLine => _t(
      'Мөнх хөх тэнгэрийн дор өнөөдөр ч алхацгаая',
      'Fancy a stroll before your cuppa?',
      '步步高升 — 每一步都让小屋更美');
  String get roomEmpty => _t('Өрөө хоосон байна.\nАлхаж coin цуглуулаарай! 🚶',
      'Your room is empty.\nWalk to earn coins! 🚶', '房间还是空的。\n走路赚金币吧！🚶');
  String dailyGoal(int now, int goal) => _t('Өдрийн зорилго: $now / $goal',
      'Daily goal: $now / $goal', '每日目标：$now / $goal');
  String get testSteps => _t('Туршилтын алхам (prototype)',
      'Test steps (prototype)', '测试步数（原型）');

  // Алхмын эх сурвалж
  String get sourceHealth => defaultTargetPlatform == TargetPlatform.iOS
      ? _t('Apple Health', 'Apple Health', '苹果健康')
      : 'Health Connect';
  String get sourceSensor => _t('утасны мэдрэгч', 'phone sensor', '手机传感器');
  String get stepsStarting => _t('Алхам тоологч шалгаж байна…',
      'Checking step counter…', '正在检查计步器…');
  String get stepsUnsupported => _t(
      'Энэ төхөөрөмж дээр алхам автоматаар тоологдохгүй. Утсан дээр суулгавал алхам тань өөрөө орж ирнэ.',
      'Steps are not counted automatically on this device. Install on your phone to sync real steps.',
      '此设备无法自动计步。安装到手机上即可同步真实步数。');
  String connectStepsTitle(String source) =>
      _t('$source-тэй холбох', 'Connect to $source', '连接 $source');
  String get connectStepsBody => _t(
      'Утас тань алхмыг өдөржин тоолдог. Зөвшөөрөл өгвөл алхам бүр coin болно.',
      'Your phone counts your steps all day. Allow access and every step becomes coins.',
      '手机全天都在记录步数。授权后，每一步都会变成金币。');
  String get connectSteps => _t('Алхам холбох', 'Connect steps', '连接步数');
  String get installHealthConnect =>
      _t('Health Connect суулгах', 'Install Health Connect', '安装 Health Connect');
  String stepsConnected(String source) => _t('✓ $source-тэй холбогдсон',
      '✓ Connected to $source', '✓ 已连接 $source');
  String lastSynced(String time) =>
      _t('Сүүлд шинэчилсэн: $time', 'Last synced: $time', '上次同步：$time');
  String sensorHint(bool sensor) => sensor
      ? _t('Апп нээлттэй үед алхам тоологдоно',
          'Counts steps while the app is open', '应用打开时计步')
      : _t('Шинэчилж байна…', 'Syncing…', '同步中…');
  String get stepsError =>
      _t('Алхам уншихад алдаа гарлаа', 'Could not read steps', '读取步数失败');

  // Шагнал
  String stepsEarned(int steps, int coins) => _t(
      '🚶 +$steps алхам  →  🪙 +$coins coin',
      '🚶 +$steps steps  →  🪙 +$coins coins',
      '🚶 +$steps 步  →  🪙 +$coins 金币');
  String goalBonusText(int c) => _t('🎯 Өдрийн зорилго биеллээ! +$c coin',
      '🎯 Daily goal reached! +$c coins', '🎯 完成每日目标！+$c 金币');
  String streakBonusText(int c) => _t('🔥 Streak bonus +$c coin',
      '🔥 Streak bonus +$c coins', '🔥 连续奖励 +$c 金币');
  String unlockedText(String emoji, String name) => _t(
      '🎉 $emoji $name нээгдлээ!', '🎉 $emoji $name unlocked!', '🎉 $emoji $name 已解锁！');

  // ── Room editor ──
  String get editorTitle => _t('Өрөө засах', 'Edit room', '装修房间');
  String get editorEmpty => _t('Доороос тавилга сонгож тавиарай',
      'Pick furniture below to place it', '从下方选择家具放进房间');
  String get editorHint => _t('Тавилга дээр дарж сонгоод, чирж зөөнө.',
      'Tap furniture to select it, drag to move.', '点击家具选中，拖动即可移动。');
  String get rotate => _t('Эргүүлэх', 'Rotate', '旋转');
  String get putAway => _t('Агуулах руу', 'Put away', '收起');
  String get colorLabel => _t('Өнгө', 'Color', '颜色');
  String get originalColor => _t('Анхны өнгө', 'Original color', '原色');
  String get inventory => _t('Миний агуулах', 'My inventory', '我的仓库');
  String get inventoryEmpty => _t(
      'Агуулах хоосон. Дэлгүүрээс тавилга аваарай 🛒',
      'Inventory is empty. Buy furniture in the shop 🛒',
      '仓库是空的，去商店买家具吧 🛒');

  // ── Shop ──
  String get shopTitle => _t('ДЭЛГҮҮР', 'SHOP', '商店');
  String get shopTab => _t('Дэлгүүр', 'Shop', '商店');
  String collectionTab(int have, int all) => _t(
      'Цуглуулга $have/$all', 'Collection $have/$all', '收藏 $have/$all');
  String get owned => _t('Байгаа', 'Owned', '已拥有');
  String bought(String emoji, String name) => _t(
      '$emoji $name авлаа! Өрөөндөө тавиарай.',
      '$emoji $name bought! Place it in your room.',
      '已购买 $emoji $name！快放进房间吧。');
  String requirement(Furniture f) => switch (f.unlockType) {
        UnlockType.none => '',
        UnlockType.streak => _t('${f.unlockValue} хоног дараалан идэвхтэй',
            '${f.unlockValue}-day streak', '连续 ${f.unlockValue} 天'),
        UnlockType.totalSteps => _t('Нийт ${f.unlockValue} алхам',
            '${f.unlockValue} total steps', '累计 ${f.unlockValue} 步'),
        UnlockType.level => _t('Level ${f.unlockValue}',
            'Level ${f.unlockValue}', '等级 ${f.unlockValue}'),
      };

  String get howToEarn =>
      _t('Coin хэрхэн олох вэ?', 'How to earn coins', '如何赚金币？');
  String ruleSteps(int n) => _t('🚶 $n алхам тутамд 1 coin',
      '🚶 1 coin for every $n steps', '🚶 每 $n 步 = 1 金币');
  String ruleGoal(int goal, int bonus) => _t(
      '🎯 Өдөрт $goal алхамд хүрвэл +$bonus bonus',
      '🎯 Reach $goal steps a day: +$bonus bonus',
      '🎯 每天达到 $goal 步：奖励 +$bonus');
  String ruleStreak(int perDay, int cap) => _t(
      '🔥 Дараалсан өдөр бүрт +$perDay × streak (дээд тал нь $cap)',
      '🔥 Each streak day: +$perDay × streak (up to $cap)',
      '🔥 连续每天：+$perDay × 连续天数（最多 $cap）');

  // ── Friends ──
  String get friendsTitle => _t('Найзууд', 'Friends', '好友');
  String get needsFirebase => _t(
      'Найзын функц ажиллахын тулд Firebase тохируулах хэрэгтэй.\n(docs/04_firebase.md-г үзнэ үү)',
      'Friends need Firebase to be set up.\n(See docs/04_firebase.md)',
      '好友功能需要先配置 Firebase。\n（参见 docs/04_firebase.md）');
  String get friendsNeedAccount => _t(
      'Найзуудтайгаа холбогдохын тулд account үүсгэж нэвтэрнэ үү.',
      'Create an account to connect with friends.',
      '请先注册并登录，才能添加好友。');
  String get myFriendCode => _t('Миний найзын код', 'My friend code', '我的好友码');
  String get shareCodeHint => _t(
      'Энэ кодыг найздаа илгээгээрэй. Найз тань кодыг оруулмагц та хоёр бие биенийхээ өрөөг харах боломжтой болно.',
      "Share this code. Once your friend enters it, you can visit each other's rooms.",
      '把这个码发给朋友。朋友输入后，你们就可以互相参观房间了。');
  String get friendCodeInput => _t('Найзын код', "Friend's code", '好友码');
  String get myFriends => _t('Миний найзууд', 'My friends', '我的好友');
  String get noFriends => _t('Одоогоор найз алга. Код солилцоод нэмээрэй! 👋',
      'No friends yet. Swap codes to add one! 👋', '还没有好友，交换好友码来添加吧！👋');
  String get visitRoom => _t('Өрөөнд нь зочлох →', 'Visit room →', '参观房间 →');
  String get removeFriend => _t('Найзаас хасах', 'Remove friend', '删除好友');
  String removeFriendQ(String name) => _t('$name-г найзаас хасах уу?',
      'Remove $name from friends?', '确定删除好友 $name 吗？');
  String get friendAdded => _t('🎉 Найз нэмэгдлээ!', '🎉 Friend added!', '🎉 已添加好友！');
  String get friendNotFound =>
      _t('Ийм код олдсонгүй', 'No one has that code', '找不到这个好友码');
  String get friendSelf => _t('Энэ таны өөрийн код байна 🙂',
      "That's your own code 🙂", '这是你自己的好友码 🙂');
  String get friendAlready =>
      _t('Аль хэдийн найз болсон', 'Already friends', '已经是好友了');
  String friendRoomTitle(String name) =>
      _t('$name-ийн өрөө', "$name's room", '$name 的房间');
  String get friendRoomEmpty =>
      _t('Өрөө нь хоосон байна', 'The room is empty', '房间还是空的');

  // ── Profile ──
  String get profileTitle => _t('Би', 'Profile', '我的');
  String toNextLevel(int n) => _t('Дараагийн level хүртэл $n алхам',
      '$n steps to next level', '距离下一级还差 $n 步');
  String get last7Days => _t('Сүүлийн 7 хоног', 'Last 7 days', '最近 7 天');
  String goalLineHint(int goal) => _t(
      'Шугам = өдрийн зорилго ($goal). Баганад дарж тоог харна.',
      'Line = daily goal ($goal). Tap a bar to see the number.',
      '横线 = 每日目标（$goal）。点击柱子查看数值。');
  String streakDays(int n) =>
      _t('$n хоногийн streak', '$n-day streak', '连续 $n 天');
  String activeDaysText(int n) => _t('Нийт $n өдөр зорилгодоо хүрсэн',
      'Reached the goal on $n days', '共 $n 天完成目标');
  String get language => _t('Хэл', 'Language', '语言');
  String get languageVibeHint => _t(
      'Хэл солиход өрөөний загвар, өнгө нь тухайн улсынх болно 🏔️☕🏮',
      'Switching language also changes the room style and colors 🏔️☕🏮',
      '切换语言时，房间风格和配色也会随之改变 🏔️☕🏮');
  String get menuLabels => _t('Цэсний бичиг харуулах', 'Show menu labels', '显示菜单文字');
  String get menuLabelsHint => _t(
      'Унтраавал цэс жижиг, зөвхөн дүрстэй болно',
      'Turn off for a compact, icon-only menu',
      '关闭后菜单只显示图标，更简洁');
  String get testTools =>
      _t('Туршилт (prototype)', 'Testing (prototype)', '测试（原型）');
  String get nextDay =>
      _t('Дараагийн өдөр рүү шилжих', 'Skip to next day', '跳到第二天');
  String get resetAll => _t('Бүгдийг эхнээс нь', 'Reset everything', '全部重置');
  String get resetQ => _t('Бүгдийг устгах уу?', 'Delete everything?', '确定全部删除吗？');
  String get resetBody => _t('Coin, алхам, тавилга бүгд тэглэгдэнэ.',
      'Coins, steps and furniture will be reset.', '金币、步数和家具都会被清空。');

  // ── Account ──
  String get tagline => _t('Алхах тусам өрөө чинь томордог',
      'Every step grows your little room', '每走一步，小屋就更温馨');
  String get signIn => _t('Нэвтрэх', 'Sign in', '登录');
  String get signUp => _t('Бүртгүүлэх', 'Sign up', '注册');
  String get signOut => _t('Гарах', 'Sign out', '退出登录');
  String get signOutQ => _t('Гарах уу?', 'Sign out?', '确定退出登录吗？');
  String get signOutBody => _t(
      'Таны өрөө cloud-д хадгалагдсан. Аль ч төхөөрөмж дээр дахин нэвтрэхэд буцаж ирнэ.',
      'Your room is saved in the cloud and comes back when you sign in on any device.',
      '你的房间已保存在云端，在任何设备上登录都会恢复。');
  String get nameLabel => _t('Нэр (найзуудад харагдана)',
      'Name (shown to friends)', '昵称（好友可见）');
  String get emailLabel => _t('Имэйл', 'Email', '邮箱');
  String get passwordLabel => _t('Нууц үг', 'Password', '密码');
  String get passwordHint =>
      _t('Хамгийн багадаа 6 тэмдэгт', 'At least 6 characters', '至少 6 个字符');
  String get forgotPassword => _t('Нууц үгээ мартсан', 'Forgot password', '忘记密码');
  String get enterEmailFirst =>
      _t('Эхлээд имэйлээ бичнэ үү', 'Enter your email first', '请先输入邮箱');
  String get resetSent => _t('Нууц үг сэргээх холбоос имэйлээр илгээгдлээ',
      'Password reset link sent to your email', '重置密码链接已发送到你的邮箱');
  String get continueWithout => _t('Account-гүй үргэлжлүүлэх',
      'Continue without account', '不登录，直接使用');
  String get continueWithoutHint => _t(
      'Өгөгдөл зөвхөн энэ төхөөрөмж дээр хадгалагдана. Найзын функц ажиллахгүй.',
      'Data stays on this device only. Friends are unavailable.',
      '数据只保存在本设备，无法使用好友功能。');
  String get notSignedIn => _t('Нэвтрээгүй байна', 'Not signed in', '未登录');
  String get notSignedInHint => _t(
      'Нэвтэрвэл өрөө тань cloud-д хадгалагдаж, өөр утаснаас ч үргэлжлүүлж болно',
      'Sign in to back up your room and continue on any device',
      '登录后房间会备份到云端，换手机也能继续');
  String get restored => _t('☁️ Өмнөх өрөө, coin тань сэргээгдлээ!',
      '☁️ Your room and coins were restored!', '☁️ 已恢复你的房间和金币！');
  String get cloudSaved => _t('☁️ Cloud-д хадгалагдаж байна',
      '☁️ Saved to the cloud', '☁️ 已同步到云端');
  String get errRequired => _t('Заавал бөглөнө', 'Required', '必填');
  String get errInvalidEmail =>
      _t('Имэйл буруу байна', 'Invalid email', '邮箱格式不正确');
  String get errEmailInUse => _t('Энэ имэйлээр бүртгэл аль хэдийн байна',
      'This email is already registered', '该邮箱已注册');
  String get errWeakPassword => _t('Нууц үг хамгийн багадаа 6 тэмдэгт',
      'Password must be at least 6 characters', '密码至少需要 6 个字符');
  String get errWrongLogin => _t('Имэйл эсвэл нууц үг буруу',
      'Wrong email or password', '邮箱或密码错误');
  String get errTooMany => _t(
      'Хэт олон оролдлого. Түр хүлээгээд дахин оролдоно уу.',
      'Too many attempts. Try again later.',
      '尝试次数过多，请稍后再试。');
  String get errGeneric => _t('Алдаа гарлаа', 'Something went wrong', '出错了');

  // ── Admin ──
  String get adminTitle =>
      _t('Хэрэглэгчийн статистик', 'User statistics', '用户统计');
  String get adminSubtitle => _t('Зөвхөн admin харна', 'Admin only', '仅管理员可见');
  String get statTotalUsers => _t('Нийт хэрэглэгч', 'Total users', '总用户');
  String get statActiveToday => _t('Өнөөдөр идэвхтэй', 'Active today', '今日活跃');
  String get statActive7 => _t('7 хоногт идэвхтэй', 'Active in 7 days', '7 天活跃');
  String get statNewToday => _t('Өнөөдөр шинэ', 'New today', '今日新增');
  String get statAllSteps => _t('Бүх хэрэглэгчийн нийт алхам',
      'Total steps of all users', '所有用户总步数');
  String get statSignups7 => _t('Шинэ бүртгэл — сүүлийн 7 хоног',
      'New sign-ups — last 7 days', '新注册 — 最近 7 天');
  String get recentSignups =>
      _t('Сүүлийн бүртгэлүүд', 'Recent sign-ups', '最近注册的用户');
  String get noSignups => _t('Одоогоор бүртгэл алга', 'No sign-ups yet', '暂无注册');
  String get adminConsoleHint => _t(
      'Бүх бүртгэлийг Firebase Console → Authentication → Users болон Firestore → registrations хэсгээс харна. Өдөр бүрийн идэвхтэй хэрэглэгч, улс, төхөөрөмжийг Analytics хэсгээс харна.',
      'See every sign-up in Firebase Console → Authentication → Users and Firestore → registrations. Daily active users, countries and devices are under Analytics.',
      '在 Firebase 控制台 → Authentication → Users 和 Firestore → registrations 中查看所有注册。每日活跃用户、国家和设备见 Analytics。');
}
