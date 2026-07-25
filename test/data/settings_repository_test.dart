import 'package:feierabend_rechner/data/settings_repository.dart';
import 'package:feierabend_rechner/domain/models/work_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsRepository> makeRepo([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  test('loadWorkConfig ist null, wenn nichts gespeichert ist', () async {
    final repo = await makeRepo();
    expect(repo.loadWorkConfig(), isNull);
  });

  test('WorkConfig speichern und wieder laden (Round-Trip)', () async {
    final repo = await makeRepo();
    const config = WorkConfig(
      work: Duration(hours: 6),
      breakTime: Duration(minutes: 30),
      arbzgAutoBreak: true,
    );
    await repo.saveWorkConfig(config);
    expect(repo.loadWorkConfig(), config);
  });

  test('Startzeit-Minuten Round-Trip', () async {
    final repo = await makeRepo();
    await repo.saveStartMinutes(6 * 60 + 44);
    expect(repo.loadStartMinutes(), 404);
  });

  test('Berufsgruppe Round-Trip', () async {
    final repo = await makeRepo();
    expect(repo.loadBerufsgruppe(), isNull);
    await repo.saveBerufsgruppe('Handwerk');
    expect(repo.loadBerufsgruppe(), 'Handwerk');
  });

  test('Theme-Name Round-Trip', () async {
    final repo = await makeRepo();
    expect(repo.loadThemeName(), isNull);
    await repo.saveThemeName('dark');
    expect(repo.loadThemeName(), 'dark');
  });

  test('Soll pro Tag Round-Trip', () async {
    final repo = await makeRepo();
    expect(repo.loadDailyTargetMinutes(), isNull);
    await repo.saveDailyTargetMinutes(480);
    expect(repo.loadDailyTargetMinutes(), 480);
  });
}
