import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/presentation/screens/settings/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders account, notifications, and support sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Areas of Interest'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.text('Email Notifications'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Send Feedback'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });
}
