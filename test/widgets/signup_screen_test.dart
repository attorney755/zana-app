import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/auth/signup_screen.dart';

void main() {
  testWidgets('SignUpScreen renders inputs, confirm password, Google Sign In, and password strength', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    bool loginTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SignUpScreen(
          onNavigateToLogin: () {
            loginTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Student / Seeker'), findsOneWidget);
    expect(find.text('Founder / Partner'), findsOneWidget);

    // Type password to trigger strength indicator
    await tester.enterText(find.widgetWithText(TextFormField, 'At least 6 characters'), 'Pass123!');
    await tester.pumpAndSettle();

    expect(find.text('Strong password'), findsOneWidget);

    // Ensure Log In link is visible and tap
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(loginTapped, isTrue);
  });
}
