import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders logo, text, and handles button tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SplashScreen(
          onGetStarted: () {
            tapped = true;
          },
        ),
      ),
    );

    // Verify presence of title and tagline
    expect(find.text('ZANA'), findsOneWidget);
    expect(find.textContaining('Welcome to Zana'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Tap Get started button
    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
