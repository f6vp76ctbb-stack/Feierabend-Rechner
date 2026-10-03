import 'package:feierabend_rechner/design/app_designs.dart';
import 'package:feierabend_rechner/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Tester-Version: Pro + Designs frei, keine Kauf-Knöpfe', (
    tester,
  ) async {
    final store = FakePurchaseBackend();
    await tester.pumpWidget(
        await buildApp(pro: false, tester: true, purchases: store));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(
      find.text('Testversion: Pro und alle Designs sind freigeschaltet – '
          'danke fürs Testen!'),
      findsOneWidget,
    );
    expect(find.text('Pro freischalten'), findsNothing);
    expect(find.text('Käufe wiederherstellen'), findsNothing);

    // Designs lassen sich direkt wählen – ohne Kauf-Dialog.
    await tester.ensureVisible(find.text('Designs ansehen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Designs ansehen'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Wald'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wald'));
    await tester.pumpAndSettle();

    expect(store.buyCalls, 0);
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).colorScheme.primary,
      AppDesigns.forest.primary,
    );
  });
}
