import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app/app.dart';

void main() {
  testWidgets('Home screen shows next prayer', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WaqtApp()));
    await tester.pumpAndSettle();

    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Maghrib'), findsWidgets);
  });
}
