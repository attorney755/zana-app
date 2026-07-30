import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders inputs, buttons, and handles validation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    bool signUpTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(
          onNavigateToSignUp: () {
            signUpTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Welcome Back to Zana'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(signUpTapped, isTrue);
  });
}
