import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/data/models/application_model.dart';
import 'package:zana_app/data/models/opportunity_model.dart';
import 'package:zana_app/data/models/user_model.dart';
import 'package:zana_app/presentation/screens/applications/applications_screen.dart';

void main() {
  testWidgets('ApplicationsScreen renders 5 tabs and initial applications', (WidgetTester tester) async {
    final sampleUser = UserModel(
      uid: 'test_uid_123',
      email: 'test@example.com',
      fullName: 'Attorney',
      savedOpportunityIds: ['opp_1'],
    );

    final sampleApps = [
      ApplicationModel(
        id: 'app_1',
        opportunityId: 'opp_1',
        opportunityTitle: 'MasterCard Foundation Scholars',
        companyName: 'MasterCard Foundation',
        applicantUid: 'test_uid_123',
        coverLetter: 'I am excited to apply.',
        availability: 'Immediate',
        status: 'Applied',
      ),
    ];

    final sampleSaved = [
      OpportunityModel(
        id: 'opp_1',
        category: 'Scholarship',
        title: 'MasterCard Foundation Scholars',
        provider: 'MasterCard Foundation',
        subtitle: 'Full funding · Masters',
        description: 'Description text',
        eligibility: 'Eligibility text',
        eligibleCountries: ['Rwanda'],
        deadline: DateTime.now().add(const Duration(days: 10)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationsScreen(
          initialUser: sampleUser,
          initialApplications: sampleApps,
          initialSavedOpportunities: sampleSaved,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Applications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Applied'), findsNWidgets(2)); // Tab title + Badge
    expect(find.text('Interview'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('MasterCard Foundation Scholars'), findsOneWidget);
  });
}
