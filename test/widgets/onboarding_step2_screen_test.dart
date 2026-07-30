import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/onboarding/onboarding_step2_screen.dart';

void main() {
  testWidgets('OnboardingStep2Screen renders fields and handles selection', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    List<String>? selectedInterests;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnboardingStep2Screen(
          onContinue: (interests) {
            selectedInterests = interests;
          },
        ),
      ),
    );

    expect(find.text('Field of interest?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Technology'));
    await tester.pump();

    await tester.tap(find.text('Health'));
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(selectedInterests, containsAll(['Technology', 'Health']));
  });
}
