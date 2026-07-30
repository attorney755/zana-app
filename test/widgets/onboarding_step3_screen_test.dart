import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/onboarding/onboarding_step3_screen.dart';

void main() {
  testWidgets('OnboardingStep3Screen renders education levels and handles selection', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    String? selectedLevel;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnboardingStep3Screen(
          onGetStarted: (level) {
            selectedLevel = level;
          },
        ),
      ),
    );

    expect(find.text('Education level?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Graduate'));
    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(selectedLevel, equals('Graduate'));
  });
}
