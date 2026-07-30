import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/presentation/screens/opportunity_detail/ready_to_apply_modal.dart';

void main() {
  testWidgets('ReadyToApplyModal renders upload icon, deadline info, and action buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    bool saveAndApplyTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ReadyToApplyModal(
          onSaveAndApply: () {
            saveAndApplyTapped = true;
          },
        ),
      ),
    );

    expect(find.text('Ready to apply?'), findsOneWidget);
    expect(find.textContaining('official MasterCard Foundation application page'), findsOneWidget);
    expect(find.text('12 days until deadline'), findsOneWidget);
    expect(find.text('June 30, 2026'), findsOneWidget);
    expect(find.text('Save & apply now'), findsOneWidget);
    expect(find.text("Apply now (don't save)"), findsOneWidget);

    await tester.tap(find.text('Save & apply now'));
    await tester.pump();

    expect(saveAndApplyTapped, isTrue);
  });
}
