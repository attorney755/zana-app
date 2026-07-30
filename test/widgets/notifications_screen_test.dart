import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/core/theme/app_theme.dart';
import 'package:zana_app/data/models/notification_model.dart';
import 'package:zana_app/presentation/screens/notifications/notifications_screen.dart';

void main() {
  testWidgets('NotificationsScreen renders notifications list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    final mockNotes = [
      NotificationModel(
        id: '1',
        title: 'New opportunity',
        body: 'A new scholarship was added.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: NotificationsScreen(
          initialNotifications: mockNotes,
        ),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('New opportunity'), findsOneWidget);
  });
}
