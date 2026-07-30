import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/opportunity_detail/opportunity_detail_screen.dart';

void main() {
  testWidgets('OpportunityDetailScreen renders program details and apply button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const OpportunityDetailScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Opportunity Details'), findsOneWidget);
    expect(find.text('MasterCard Foundation Scholars Program'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Apply Now'), findsOneWidget);
  });
}
