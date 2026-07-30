import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/user_model.dart';
import 'package:zana_app/presentation/screens/profile/edit_profile_screen.dart';

void main() {
  testWidgets('EditProfileScreen renders form fields and save button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    bool saveTapped = false;

    final mockUser = UserModel(
      uid: '123',
      email: 'kevin@example.com',
      fullName: 'Ishimwe Kevin',
      country: 'Rwanda',
      fieldOfStudy: 'Business Admin',
      educationLevel: 'Undergraduate',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: EditProfileScreen(
          initialUser: mockUser,
          onSaveChanges: () {
            saveTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Ishimwe Kevin'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('Field of study'), findsOneWidget);
    expect(find.text('Education level'), findsOneWidget);
    expect(find.text('Deadline reminders'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(saveTapped, isTrue);
  });
}
