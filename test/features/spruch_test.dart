import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('next() wiederholt nie den direkt vorherigen Spruch', () async {
    final c = await makeContainer();
    final ctrl = c.read(spruchControllerProvider.notifier);

    var prev = c.read(spruchProvider);
    for (var i = 0; i < 50; i++) {
      ctrl.next();
      final now = c.read(spruchProvider);
      expect(now, isNotEmpty);
      expect(now, isNot(prev), reason: 'Spruch $i wiederholt den vorherigen');
      prev = now;
    }
  });

  test('Berufsgruppe wechseln liefert einen Spruch aus der neuen Gruppe',
      () async {
    final c = await makeContainer();
    c.read(berufsgruppeProvider.notifier).set('IT');
    final spruch = c.read(spruchProvider);
    expect(spruch, isNotEmpty);
  });
}
