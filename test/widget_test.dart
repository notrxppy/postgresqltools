import 'package:flutter_test/flutter_test.dart';
import 'package:postgresql_tools/main.dart';

void main() {
  testWidgets('Home page loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app starts with the home page.
    expect(find.text('PostgreSQL Tools'), findsOneWidget);
    expect(find.text('Welcome to PostgreSQL Tools'), findsOneWidget);
  });

  testWidgets('Feature cards are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that feature cards are displayed
    expect(find.text('SQL Compiler'), findsOneWidget);
    expect(find.text('PL/SQL Converter'), findsOneWidget);
    expect(find.text('Query History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
