import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/opportunity_model.dart';
import 'package:zana_app/presentation/screens/explore/explore_screen.dart';

void main() {
  testWidgets('ExploreScreen renders categories, search, and opportunity cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockOpps = [
      OpportunityModel(
        id: '1',
        category: 'Internship',
        title: 'Google STEP Internship',
        provider: 'Google',
        subtitle: 'Technology · Global · Paid',
        description: 'Description',
        eligibility: 'Eligible',
        eligibleCountries: ['Global'],
        deadline: DateTime.now().add(const Duration(days: 30)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ExploreScreen(
          initialOpportunities: mockOpps,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Explore Opportunities'), findsOneWidget);
    expect(find.text('Search opportunities...'), findsOneWidget);
    expect(find.text('Google STEP Internship'), findsOneWidget);
  });
}
