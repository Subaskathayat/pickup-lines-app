// This is a basic Flutter widget test for the Pickup Lines app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pickup_lines/main.dart';
import 'package:pickup_lines/screens/category_list_screen.dart';
import 'package:pickup_lines/models/category.dart';

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

  group('SliverAnimatedList Tests', () {
    testWidgets('CategoryListScreen displays SliverAnimatedList',
        (WidgetTester tester) async {
      // Create a test category
      final testCategory = Category(
        id: 'test',
        name: 'Test Category',
        icon: '🧪',
        texts: [
          'Test pickup line 1',
          'Test pickup line 2',
          'Test pickup line 3',
        ],
      );

      // Build the CategoryListScreen
      await tester.pumpWidget(
        MaterialApp(
          home: CategoryListScreen(category: testCategory),
        ),
      );

      // Verify that the screen displays correctly
      expect(
          find.text('Test Category'),
          findsAtLeastNWidgets(
              1)); // Allow multiple instances (app bar + header)
      expect(find.text('🧪'), findsOneWidget);
      expect(find.text('3 pickup lines'), findsOneWidget);

      // Verify that the CustomScrollView and SliverList are present
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);

      // Verify that the text cards are displayed
      expect(find.text('Test pickup line 1'), findsOneWidget);
      expect(find.text('Test pickup line 2'), findsOneWidget);
      expect(find.text('Test pickup line 3'), findsOneWidget);
    });

    testWidgets('Scroll-based animations work correctly',
        (WidgetTester tester) async {
      final testCategory = Category(
        id: 'test',
        name: 'Test Category',
        icon: '🧪',
        texts: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CategoryListScreen(category: testCategory),
        ),
      );

      // Wait for initial render
      await tester.pumpAndSettle();

      // Verify that ScrollAnimatedItem widgets are created
      expect(find.byType(ScrollAnimatedItem), findsWidgets);

      // Verify that items are displayed
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
