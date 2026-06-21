import 'package:flutter_test/flutter_test.dart';
import 'package:credit_manager/main.dart';

void main() {
  testWidgets('App renders home page with title', (WidgetTester tester) async {
    await tester.pumpWidget(const DebtManagerApp());

    expect(find.text('Student Debt Manager'), findsOneWidget);
    expect(find.text('No entries yet. Tap + to add a person.'), findsOneWidget);
  });
}
