import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/user_model.dart';
import 'package:zana_app/presentation/screens/profile/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders user info, details, and stats cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockUser = UserModel(
      uid: '123',
      email: 'kevin@example.com',
      fullName: 'Ishimwe Kevin',
      country: 'Rwanda',
      fieldOfStudy: 'Business Administration',
      educationLevel: 'Undergraduate (Final year)',
      savedOpportunityIds: ['1', '2', '3'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProfileScreen(
          initialUser: mockUser,
        ),
      ),
    );

    expect(find.text('IK'), findsOneWidget);
    expect(find.text('Ishimwe Kevin'), findsOneWidget);
    expect(find.text('Applications'), findsWidgets);
    expect(find.text('Shortlisted'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Skills & Interests'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}
