import 'package:feierabend_rechner/domain/models/profile.dart';
import 'package:feierabend_rechner/domain/models/work_config.dart';
import 'package:feierabend_rechner/features/home/state/home_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('Profile Serialisierung', () {
    test('toJson/fromJson Round-Trip', () {
      const profile = Profile(
        id: 'abc',
        name: 'Nachtschicht',
        config: WorkConfig(
          work: Duration(hours: 8),
          breakTime: Duration(minutes: 30),
          arbzgAutoBreak: true,
        ),
      );
      expect(Profile.fromJson(profile.toJson()), profile);
    });
  });

  group('ProfilesController', () {
    test('startet mit einem Standard-Profil', () async {
      final c = await makeContainer();
      final state = c.read(profilesControllerProvider);
      expect(state.profiles, hasLength(1));
      expect(state.active.name, 'Standard');
      // workConfigProvider spiegelt das aktive Profil.
      expect(c.read(workConfigProvider), const WorkConfig());
    });

    test('addProfile legt an und aktiviert', () async {
      final c = await makeContainer();
      final ctrl = c.read(profilesControllerProvider.notifier);
      final id = ctrl.addProfile('Freitag');
      final state = c.read(profilesControllerProvider);
      expect(state.profiles, hasLength(2));
      expect(state.activeId, id);
      expect(state.active.name, 'Freitag');
    });

    test('setWork ändert nur das aktive Profil', () async {
      final c = await makeContainer();
      final ctrl = c.read(profilesControllerProvider.notifier);
      final standardId = c.read(profilesControllerProvider).activeId;
      ctrl.addProfile('Teilzeit');
      ctrl.setWork(const Duration(hours: 4));

      final state = c.read(profilesControllerProvider);
      final teilzeit = state.active;
      final standard =
          state.profiles.firstWhere((p) => p.id == standardId);
      expect(teilzeit.config.work, const Duration(hours: 4));
      expect(standard.config.work, const Duration(hours: 8));
    });

    test('deleteProfile entfernt und wählt Ersatz aktiv', () async {
      final c = await makeContainer();
      final ctrl = c.read(profilesControllerProvider.notifier);
      final standardId = c.read(profilesControllerProvider).activeId;
      final freitagId = ctrl.addProfile('Freitag'); // jetzt aktiv
      ctrl.deleteProfile(freitagId);

      final state = c.read(profilesControllerProvider);
      expect(state.profiles, hasLength(1));
      expect(state.activeId, standardId);
    });

    test('letztes Profil kann nicht gelöscht werden', () async {
      final c = await makeContainer();
      final ctrl = c.read(profilesControllerProvider.notifier);
      final id = c.read(profilesControllerProvider).activeId;
      ctrl.deleteProfile(id);
      expect(c.read(profilesControllerProvider).profiles, hasLength(1));
    });

    test('Profile werden persistiert und neu geladen', () async {
      final c = await makeContainer();
      c.read(profilesControllerProvider.notifier).addProfile('Schicht');
      final prefs = await SharedPreferences.getInstance();

      // Neuer Container mit denselben (persistierten) Prefs.
      final c2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c2.dispose);
      final names = c2
          .read(profilesControllerProvider)
          .profiles
          .map((p) => p.name)
          .toList();
      expect(names, containsAll(['Standard', 'Schicht']));
    });
  });
}
