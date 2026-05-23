import 'package:flutter_test/flutter_test.dart';

import 'package:guva/main.dart';

void main() {
  testWidgets('renders Ask Uganda splash on first frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AskUgandaApp());

    // Splash content
    expect(find.text('Ask Uganda'), findsOneWidget);
    expect(
      find.text(
        'A patient, multilingual assistant for every government service.',
      ),
      findsOneWidget,
    );

    // Splash advances after its timer; we let it complete and let
    // animations settle without asserting the destination, which depends
    // on persisted preferences and is exercised in integration tests.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
