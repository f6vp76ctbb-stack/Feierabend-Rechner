import 'package:feierabend_rechner/domain/models/overtime_entry.dart';
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
  test('startet leer', () async {
    final c = await makeContainer();
    expect(c.read(overtimeControllerProvider), isEmpty);
    expect(c.read(overtimeBalanceProvider), 0);
  });

  test('upsert legt an, überschreibt denselben Tag', () async {
    final c = await makeContainer();
    final ctrl = c.read(overtimeControllerProvider.notifier);

    ctrl.upsert(OvertimeEntry(
        date: DateTime(2024, 1, 3), workedMinutes: 510, targetMinutes: 480));
    expect(c.read(overtimeControllerProvider), hasLength(1));
    expect(c.read(overtimeBalanceProvider), 30);

    // Gleicher Tag → Überschreiben, nicht duplizieren.
    ctrl.upsert(OvertimeEntry(
        date: DateTime(2024, 1, 3, 20), workedMinutes: 540, targetMinutes: 480));
    expect(c.read(overtimeControllerProvider), hasLength(1));
    expect(c.read(overtimeBalanceProvider), 60);
  });

  test('deleteFor entfernt den Tag', () async {
    final c = await makeContainer();
    final ctrl = c.read(overtimeControllerProvider.notifier);
    ctrl.upsert(OvertimeEntry(
        date: DateTime(2024, 1, 3), workedMinutes: 510, targetMinutes: 480));
    ctrl.deleteFor(DateTime(2024, 1, 3));
    expect(c.read(overtimeControllerProvider), isEmpty);
  });

  test('Einträge werden persistiert und neu geladen', () async {
    final c = await makeContainer();
    c.read(overtimeControllerProvider.notifier).upsert(OvertimeEntry(
        date: DateTime(2024, 1, 3), workedMinutes: 510, targetMinutes: 480));
    final prefs = await SharedPreferences.getInstance();

    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c2.dispose);
    expect(c2.read(overtimeControllerProvider), hasLength(1));
    expect(c2.read(overtimeBalanceProvider), 30);
  });
}
