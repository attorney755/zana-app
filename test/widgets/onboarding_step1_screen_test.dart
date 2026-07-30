import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/onboarding/onboarding_step1_screen.dart';

void main() {
  testWidgets('OnboardingStep1Screen renders options, handles selection and skip', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    String? selectedCountry;
    bool skipped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnboardingStep1Screen(
          onContinue: (country) {
            selectedCountry = country;
          },
          onSkip: () {
            skipped = true;
          },
        ),
      ),
    );

    // Verify title and Skip button
    expect(find.text('Where are you based?'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Skip
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(skipped, isTrue);

    // Tap option and continue
    await tester.tap(find.text('KENYA'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(selectedCountry, equals('KENYA'));
  });
}
