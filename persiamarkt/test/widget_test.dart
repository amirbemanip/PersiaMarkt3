// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:persia_markt/providers/app_provider.dart';
import 'package:persia_markt/main.dart'; // Correct package name

void main() {
  testWidgets('App starts with SplashView and navigates to MainTabBarView', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap MyApp with ChangeNotifierProvider to make AppProvider available for testing.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that SplashView is shown initially.
    expect(find.text('PersiaMarkt'), findsOneWidget);
    expect(find.text('خرید آسان محصولات ایرانی در آلمان'), findsOneWidget);

    // Wait for the splash screen animation to finish (e.g., 2 seconds delay + transition).
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that after the delay, the app has navigated to the main view.
    // We can check for a widget that is unique to the main view, like 'خانه' label.
    expect(find.text('خانه'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
