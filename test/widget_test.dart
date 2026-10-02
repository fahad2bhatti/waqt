import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/app/app.dart';
import 'package:waqt/app/router/app_router.dart';
import 'package:waqt/core/storage/prefs.dart';

void main() {
  testWidgets('Home screen shows next prayer', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const WaqtApp(),
      ),
    );
    appRouter.go('/home');
    await tester.pumpAndSettle();

    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Maghrib'), findsWidgets);
  });
}
