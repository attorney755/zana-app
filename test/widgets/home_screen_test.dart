import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/opportunity_model.dart';
import 'package:zana_app/data/models/user_model.dart';
import 'package:zana_app/presentation/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders dynamic greeting, categories, search bar, and opportunity cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockUser = UserModel(
      uid: '123',
      email: 'kevin@example.com',
      fullName: 'Kevin',
      country: 'Rwanda',
      interests: ['Scholarship'],
    );

    final mockOpps = [
      OpportunityModel(
        id: '1',
        category: 'Scholarship',
        title: 'MasterCard Foundation Scholars',
        provider: 'MasterCard',
        subtitle: 'Full funding · Masters · Rwanda',
        description: 'Description',
        eligibility: 'Eligible',
        eligibleCountries: ['Rwanda'],
        deadline: DateTime.now().add(const Duration(days: 12)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomeScreen(
          initialUser: mockUser,
          initialOpportunities: mockOpps,
          initialUnreadCount: 0,
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Search opportunities...'), findsOneWidget);
    expect(find.text('Browse by category'), findsOneWidget);
    expect(find.text('Recent opportunities matching your interest'), findsOneWidget);
    expect(find.text('MasterCard Foundation Scholars'), findsWidgets);
  });

  testWidgets('HomeScreen displays empty state when user interests do not match opportunities', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockUser = UserModel(
      uid: '123',
      email: 'kevin@example.com',
      fullName: 'Kevin',
      country: 'Rwanda',
      interests: ['NonMatchingInterest'],
      fieldOfStudy: 'NonMatchingField',
    );

    final mockOpps = [
      OpportunityModel(
        id: '1',
        category: 'Scholarship',
        title: 'MasterCard Foundation Scholars',
        provider: 'MasterCard',
        subtitle: 'Full funding · Masters · Rwanda',
        description: 'Description',
        eligibility: 'Eligible',
        eligibleCountries: ['Rwanda'],
        deadline: DateTime.now().add(const Duration(days: 12)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomeScreen(
          initialUser: mockUser,
          initialOpportunities: mockOpps,
          initialUnreadCount: 0,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No opportunities match your interest right now'), findsOneWidget);
  });
}
