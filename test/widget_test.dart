import 'package:feierabend_rechner/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home zeigt Feierabend-Überschrift und Eingaben', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FeierabendApp()),
    );
    await tester.pump();

    expect(find.text('Feierabend'), findsOneWidget);
    expect(find.text('FEIERABEND UM'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Arbeitszeit'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
  });

  testWidgets('Pause-Zeile öffnet das Einstell-Overlay', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FeierabendApp()),
    );
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Übernehmen'), findsOneWidget);
  });
}
