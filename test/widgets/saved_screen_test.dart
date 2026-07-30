import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/opportunity_model.dart';
import 'package:zana_app/presentation/screens/saved/saved_screen.dart';

void main() {
  testWidgets('SavedScreen renders header and bookmarked opportunity list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockOpps = [
      OpportunityModel(
        id: '1',
        category: 'Scholarship',
        title: 'Chevening Scholarship',
        provider: 'UK Gov',
        subtitle: 'Masters · UK · Full funding',
        description: 'Description',
        eligibility: 'Eligible',
        eligibleCountries: ['UK'],
        deadline: DateTime.now().add(const Duration(days: 5)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SavedScreen(
          initialOpportunities: mockOpps,
        ),
      ),
    );

    expect(find.text('Saved opportunities'), findsOneWidget);
    expect(find.text('Chevening Scholarship'), findsOneWidget);
  });
}
