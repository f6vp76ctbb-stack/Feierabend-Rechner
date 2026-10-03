import 'package:feierabend_rechner/data/settings_repository.dart';
import 'package:feierabend_rechner/domain/models/work_config.dart';
import 'package:feierabend_rechner/domain/reminder_planner.dart';
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

  test('Erinnerungen: Standard aus, 30 Min, Feierabend + Spruch an', () async {
    final o = (await makeRepo()).loadReminderOptions();
    expect(o.enabled, isFalse);
    expect(o.leads, [const Duration(minutes: 30)]);
    expect(o.atEnd, isTrue);
    expect(o.halfTime, isFalse);
    expect(o.withQuote, isTrue);
  });

  test('Erinnerungen: Round-Trip mit mehreren Vorwarnungen', () async {
    final repo = await makeRepo();
    final o = ReminderOptions(
      enabled: true,
      leads: const [Duration(hours: 1), Duration(minutes: 15)],
      halfTime: true,
      atEnd: false,
      withQuote: false,
    );
    await repo.saveReminderOptions(o);
    expect(repo.loadReminderOptions(), o);
  });

  test('Erinnerungen: alte Einzel-Vorwarnung (v1.0) wird übernommen', () async {
    final repo = await makeRepo({
      'reminders_enabled': true,
      'reminder_lead_minutes': 15,
    });
    final o = repo.loadReminderOptions();
    expect(o.enabled, isTrue);
    expect(o.leads, [const Duration(minutes: 15)]);
  });

  test('Einführung: neu = offen, Bestandsnutzer = erledigt, Round-Trip', () async {
    expect((await makeRepo()).loadOnboardingDone(), isFalse);
    expect((await makeRepo({'start_minutes': 404})).loadOnboardingDone(), isTrue);
    final repo = await makeRepo();
    await repo.saveOnboardingDone(true);
    expect(repo.loadOnboardingDone(), isTrue);
  });
}
