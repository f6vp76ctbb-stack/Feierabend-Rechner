// ignore_for_file: invalid_use_of_visible_for_testing_member
// Erzeugt alle Store-Grafiken aus der echten App (mit echter Schrift):
//   flutter test tool/store_assets_test.dart
// Ausgabe: assets/icon/*.png (Launcher-Icon-Quellen) und store/graphics/**.
//
// Läuft bewusst NICHT mit `flutter test` (liegt außerhalb von test/).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:feierabend_rechner/app.dart';
import 'package:feierabend_rechner/design/app_icon.dart';
import 'package:feierabend_rechner/design/app_theme.dart';
import 'package:feierabend_rechner/domain/overtime_calculator.dart';
import 'package:feierabend_rechner/features/designs/design_shop_sheet.dart';
import 'package:feierabend_rechner/features/home/home_screen.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:feierabend_rechner/features/home/widgets/countdown_ring.dart';
import 'package:feierabend_rechner/features/home/widgets/spruch_card.dart';
import 'package:feierabend_rechner/features/home/widgets/start_time_sheet.dart';
import 'package:feierabend_rechner/features/overtime/overtime_screen.dart';
import 'package:feierabend_rechner/features/pro/paywall_sheet.dart';
import 'package:feierabend_rechner/features/pro/pro_providers.dart';
import 'package:feierabend_rechner/features/profiles/profile_manage_sheet.dart';
import 'package:feierabend_rechner/features/reminders/reminder_providers.dart';
import 'package:feierabend_rechner/features/widget/widget_providers.dart';
import 'package:feierabend_rechner/services/ads_backend.dart';
import 'package:feierabend_rechner/services/notification_backend.dart';
import 'package:feierabend_rechner/services/purchase_backend.dart';
import 'package:feierabend_rechner/services/widget_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Rendering-Helfer
// ---------------------------------------------------------------------------

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
  await inter.load();
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  final iconFile = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(iconFile.readAsBytesSync())));
  await icons.load();
}

Future<void> _render(
  WidgetTester tester, {
  required Widget child,
  required Size logicalSize,
  required double pixelRatio,
  required String path,
  Future<void> Function()? prepare,
}) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.fromSize(size: logicalSize, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (prepare != null) {
    await prepare();
    await tester.pumpAndSettle();
  }
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
  // Szene abbauen, damit der nächste Aufbau frisch startet.
  await tester.pumpWidget(const SizedBox());
}

// ---------------------------------------------------------------------------
// Beispieldaten
// ---------------------------------------------------------------------------

class _FixedSpruch extends SpruchController {
  _FixedSpruch(this.index);
  final int index;
  @override
  int build() => index;
}

class _ShowcaseStore implements PurchaseBackend {
  _ShowcaseStore(this.lang);
  final String lang;

  /// Preisvorschläge wie in `store/IN_APP_KAUF_UND_WERBUNG.md`.
  static const _cents = {
    'design_supporter': 499,
    'design_midnight': 199,
    'design_sunset': 199,
    'design_ocean': 149,
    'design_forest': 99,
  };

  String _price(String id) {
    final c = _cents[id] ?? 399;
    final euros = '${c ~/ 100}', cents = (c % 100).toString().padLeft(2, '0');
    return lang == 'de' ? '$euros,$cents €' : '€$euros.$cents';
  }

  @override
  bool get isSupported => true;
  @override
  Stream<PurchaseEvent> get events => const Stream.empty();
  @override
  Future<StoreProduct?> loadProduct(String id) async =>
      StoreProduct(id: id, price: _price(id));
  @override
  Future<bool> buy(String id) async => false;
  @override
  Future<void> restore() async {}
  @override
  void dispose() {}
}

class _ShowcaseAds extends NoopAdsBackend {
  @override
  bool get isSupported => true;
}

DateTime get _today {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

Map<String, Object> _sampleData(String lang, {required bool dark}) {
  final names = lang == 'de'
      ? ['Mo–Do', 'Freitag', 'Nachtschicht']
      : ['Mon–Thu', 'Friday', 'Night shift'];
  final profiles = {
    'activeId': 'p1',
    'profiles': [
      {'id': 'p1', 'name': names[0], 'config': {'work': 480, 'break': 45, 'arbzg': false}},
      {'id': 'p2', 'name': names[1], 'config': {'work': 360, 'break': 0, 'arbzg': false}},
      {'id': 'p3', 'name': names[2], 'config': {'work': 480, 'break': 30, 'arbzg': false}},
    ],
  };
  final monday = OvertimeCalculator.weekStart(_today);
  Map<String, Object> e(DateTime d, int worked) =>
      {'date': d.toIso8601String().substring(0, 10), 'worked': worked, 'target': 480};
  final overtime = [
    if (monday.isBefore(_today)) e(monday, 510), // +30
    e(monday.subtract(const Duration(days: 7)), 525), // +45
    e(monday.subtract(const Duration(days: 6)), 510), // +30
    e(monday.subtract(const Duration(days: 5)), 495), // +15
    e(monday.subtract(const Duration(days: 4)), 540), // +60
    e(monday.subtract(const Duration(days: 3)), 360), // −120 (6-Std-Tag)
    e(monday.subtract(const Duration(days: 14)), 540), // +60
    e(monday.subtract(const Duration(days: 12)), 525), // +45
    e(monday.subtract(const Duration(days: 10)), 510), // +30
  ];
  return {
    'pro_purchased': true,
    'onboarding_done': true,
    'start_minutes': 6 * 60 + 44,
    'berufsgruppe': 'Büro',
    'theme_name': dark ? 'dark' : 'light',
    'daily_target_minutes': 480,
    'profiles_v1': jsonEncode(profiles),
    'overtime_v1': jsonEncode(overtime),
  };
}

Future<Widget> _app(String lang,
    {bool dark = false, bool paywall = false, String? design}) async {
  SharedPreferences.setMockInitialValues({
    ..._sampleData(lang, dark: dark),
    if (design != null) 'designs_owned': [design],
    'design_selected': ?design,
  });
  final prefs = await SharedPreferences.getInstance();
  final now = _today.add(const Duration(hours: 12, minutes: 17));
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      nowProvider.overrideWith((ref) => Stream.value(now)),
      spruchControllerProvider.overrideWith(() => _FixedSpruch(2)),
      purchaseBackendProvider.overrideWithValue(paywall
          ? _ShowcaseStore(lang)
          : NoopPurchaseBackend()),
      adsBackendProvider
          .overrideWithValue(paywall ? _ShowcaseAds() : NoopAdsBackend()),
      notificationBackendProvider.overrideWithValue(NoopNotificationBackend()),
      widgetBackendProvider.overrideWithValue(NoopWidgetBackend()),
    ],
    child: FeierabendApp(locale: Locale(lang)),
  );
}

// ---------------------------------------------------------------------------
// Marketing-Rahmen
// ---------------------------------------------------------------------------

const _frameSize = Size(540, 960); // ×2 → 1080×1920 (9:16, Play-konform)
const _phoneSize = Size(390, 844);

TextStyle _inter(double size, double weight, Color color, {double? height}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      height: height,
      color: color,
      fontVariations: [FontVariation('wght', weight)],
    );

Widget _statusBar(bool dark) {
  final c = dark ? Colors.white : const Color(0xFF1E1E28);
  return SizedBox(
    height: 44,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Text('12:17', style: _inter(15, 600, c)),
          const Spacer(),
          Icon(Icons.signal_cellular_alt_rounded, size: 17, color: c),
          const SizedBox(width: 4),
          Icon(Icons.wifi_rounded, size: 17, color: c),
          const SizedBox(width: 4),
          Icon(Icons.battery_full_rounded, size: 17, color: c),
        ],
      ),
    ),
  );
}

Widget _phone(Widget app, {required bool dark}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF0E0E14),
      borderRadius: BorderRadius.circular(52),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 40,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(42),
      child: SizedBox.fromSize(
        size: _phoneSize,
        child: MediaQuery(
          data: const MediaQueryData(
            size: _phoneSize,
            devicePixelRatio: 3,
            padding: EdgeInsets.only(top: 44, bottom: 20),
            viewPadding: EdgeInsets.only(top: 44, bottom: 20),
            textScaler: TextScaler.noScaling,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: app),
              Positioned(top: 0, left: 0, right: 0, child: _statusBar(dark)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _frame(String caption, Widget phone, {bool dark = false}) {
  final colors = dark
      ? const [Color(0xFF15151E), Color(0xFF2A2350), Color(0xFF4B3FB8)]
      : const [Color(0xFF4B3FB8), Color(0xFF7C5CE7), Color(0xFFFF9F6B)];
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          left: 32,
          right: 32,
          top: 58,
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: _inter(38, 800, Colors.white, height: 1.15),
          ),
        ),
        Positioned(
          top: 205,
          left: 0,
          right: 0,
          child: Center(child: phone),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Szenen
// ---------------------------------------------------------------------------

typedef _Prepare = Future<void> Function(WidgetTester tester);

class _Scene {
  const _Scene(this.file, this.de, this.en,
      {this.dark = false, this.paywall = false, this.design, this.prepare});
  final String file;
  final String de;
  final String en;
  final bool dark;
  final bool paywall;
  final String? design;
  final _Prepare? prepare;
}

BuildContext _homeCtx(WidgetTester t) => t.element(find.byType(HomeScreen));

final _scenes = <_Scene>[
  const _Scene('01-feierabend', 'Wann ist Feierabend?\nAuf einen Blick.',
      'When can you clock out?\nAt a glance.'),
  _Scene('02-startzeit', 'Startzeit antippen –\nfertig.',
      'Tap your start time –\ndone.', prepare: (t) async {
    StartTimeSheet.show(_homeCtx(t), const TimeOfDay(hour: 6, minute: 44));
  }),
  _Scene('03-profile', 'Profile für jeden\nArbeitstag', 'Profiles for every\nworkday',
      prepare: (t) async {
    ProfileManageSheet.show(_homeCtx(t));
  }),
  _Scene('04-ueberstunden', 'Überstunden\nimmer im Blick',
      'Your overtime,\nalways in view', prepare: (t) async {
    OvertimeScreen.open(_homeCtx(t));
  }),
  _Scene('05-sprueche', 'Lustige Sprüche\nfür deinen Beruf', 'Fun quotes\nfor your job',
      prepare: (t) async {
    Scrollable.ensureVisible(t.element(find.byType(SpruchCard)), alignment: 0.32);
  }),
  const _Scene('06-dunkel', 'Schön –\nauch im Dunkeln', 'Beautiful –\neven in the dark',
      dark: true),
  _Scene('07-pro', 'Einmal zahlen.\nKein Abo.', 'Pay once.\nNo subscription.',
      paywall: true, prepare: (t) async {
    PaywallSheet.show(_homeCtx(t));
  }),
  _Scene('08-designs', 'Designs\nzum Verlieben', 'Designs\nyou\'ll love',
      paywall: true, design: 'supporter', prepare: (t) async {
    DesignShopSheet.show(_homeCtx(t));
  }),
];

// ---------------------------------------------------------------------------
// Feature-Grafik
// ---------------------------------------------------------------------------

Widget _featureGraphic(String lang) {
  final de = lang == 'de';
  final light = AppTheme.light();
  return DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4B3FB8), Color(0xFF7C5CE7), Color(0xFFFF9F6B)],
        stops: [0.0, 0.55, 1.0],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconMark(size: 92),
                const SizedBox(height: 26),
                Text(de ? 'Feierabend Rechner' : 'Clock-Out Calculator',
                    style: _inter(46, 800, Colors.white, height: 1.05)),
                const SizedBox(height: 12),
                Text(
                  de
                      ? 'Wann ist Feierabend?\nAuf einen Blick.'
                      : 'When can you clock out?\nAt a glance.',
                  style: _inter(28, 500, Colors.white.withValues(alpha: 0.92),
                      height: 1.25),
                ),
              ],
            ),
          ),
          Theme(
            data: light,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: CountdownRing(
                progress: 0.63,
                size: 300,
                child: Builder(builder: (context) {
                  final t = Theme.of(context).textTheme;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(de ? 'FEIERABEND UM' : 'CLOCK-OUT AT',
                          style: t.labelLarge),
                      Text('15:29',
                          style: t.displayLarge?.copyWith(fontSize: 62)),
                      const SizedBox(height: 6),
                      Text(de ? 'noch 3 Std 12 Min' : '3 h 12 min left',
                          style: t.titleMedium),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests = Generatoren
// ---------------------------------------------------------------------------

void main() {
  setUpAll(_loadFonts);

  testWidgets('App-Icons', (tester) async {
    addTearDown(tester.view.reset);
    const s = Size(1024, 1024);
    Future<void> icon(String path, AppIconPainter p) => _render(tester,
        child: CustomPaint(painter: p),
        logicalSize: s,
        pixelRatio: 1,
        path: path);

    await icon('assets/icon/icon_full.png', const AppIconPainter());
    await icon('assets/icon/icon_background.png',
        const AppIconPainter(drawForeground: false));
    await icon('assets/icon/icon_foreground.png',
        const AppIconPainter(drawBackground: false));
    await icon(
        'assets/icon/icon_monochrome.png',
        const AppIconPainter(
            drawBackground: false, monochrome: true));
    await _render(tester,
        child: const CustomPaint(painter: AppIconPainter()),
        logicalSize: const Size(512, 512),
        pixelRatio: 1,
        path: 'store/graphics/icon-512.png');
  });

  for (final lang in ['de', 'en']) {
    testWidgets('Feature-Grafik $lang', (tester) async {
      addTearDown(tester.view.reset);
      await _render(tester,
          child: _featureGraphic(lang),
          logicalSize: const Size(1024, 500),
          pixelRatio: 1,
          path: 'store/graphics/$lang/feature-graphic.png');
    });

    for (final scene in _scenes) {
      testWidgets('Screenshot $lang ${scene.file}', (tester) async {
        addTearDown(tester.view.reset);
        final app = await _app(lang,
            dark: scene.dark, paywall: scene.paywall, design: scene.design);
        await _render(
          tester,
          child: _frame(
            lang == 'de' ? scene.de : scene.en,
            _phone(app, dark: scene.dark),
            dark: scene.dark,
          ),
          logicalSize: _frameSize,
          pixelRatio: 2,
          path: 'store/graphics/$lang/screenshots/${scene.file}.png',
          prepare: scene.prepare == null ? null : () => scene.prepare!(tester),
        );
      });
    }
  }
}
