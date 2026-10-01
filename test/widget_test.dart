import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app/app.dart';
import 'package:waqt/app/router/app_router.dart';

void main() {
  testWidgets('Home screen shows next prayer', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WaqtApp()));
    appRouter.go('/home');
    await tester.pumpAndSettle();

    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Maghrib'), findsWidgets);
  });
}
