import 'package:flutter_test/flutter_test.dart';
import 'package:zana_app/main.dart';

void main() {
  testWidgets('Zana App launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('ZANA'), findsOneWidget);
  });
}
