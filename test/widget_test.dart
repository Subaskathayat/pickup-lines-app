// This is a basic Flutter widget test for the Pickup Lines app.

import 'package:flutter_test/flutter_test.dart';

import 'package:pickup_lines/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlirtyTextApp());

    // Verify that the app title is displayed.
    expect(find.text('Pickup Lines'), findsOneWidget);

    // Verify that the home screen content is displayed.
    expect(find.text('Choose your style'), findsOneWidget);
    expect(find.text('Pick a category to find the perfect pickup line'),
        findsOneWidget);
  });
}
