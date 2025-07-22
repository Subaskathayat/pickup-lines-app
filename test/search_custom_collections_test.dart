import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickup_lines/services/custom_lines_service.dart';
import 'package:pickup_lines/screens/search_screen.dart';

void main() {
  group('Search Custom Collections Tests', () {
    late CustomLinesService customLinesService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      customLinesService = CustomLinesService.instance;
    });

    test('CustomLinesService should add and retrieve custom lines', () async {
      // Add some test custom lines
      await customLinesService.addCustomLine(
          'Are you a magician? Because you just made my heart disappear!');
      await customLinesService.addCustomLine(
          'Do you have a map? I keep getting lost in your eyes.');
      await customLinesService
          .addCustomLine('Are you WiFi? Because I\'m feeling a connection.');

      // Retrieve custom lines
      final customLines = await customLinesService.getCustomLines();

      expect(customLines.length, 3);
      expect(
          customLines,
          contains(
              'Are you a magician? Because you just made my heart disappear!'));
      expect(customLines,
          contains('Do you have a map? I keep getting lost in your eyes.'));
      expect(customLines,
          contains('Are you WiFi? Because I\'m feeling a connection.'));
    });

    test('SearchResult should support custom collection flag', () {
      // Test regular category result
      final regularResult = SearchResult(
        text: 'Test pickup line',
        category: 'Funny',
        categoryIcon: '😄',
        index: 0,
      );
      expect(regularResult.isCustomCollection, false);

      // Test custom collection result
      final customResult = SearchResult(
        text: 'Custom pickup line',
        category: 'My Collection',
        categoryIcon: '✏️',
        index: 0,
        isCustomCollection: true,
      );
      expect(customResult.isCustomCollection, true);
    });

    test('Custom lines should be searchable', () async {
      // Add test custom lines
      await customLinesService.addCustomLine(
          'You must be a camera, because every time I look at you, I smile.');
      await customLinesService.addCustomLine(
          'Are you a parking ticket? Because you have fine written all over you.');

      final customLines = await customLinesService.getCustomLines();

      // Test search functionality
      final query = 'camera';
      final matchingLines = customLines
          .where((line) => line.toLowerCase().contains(query.toLowerCase()))
          .toList();

      expect(matchingLines.length, 1);
      expect(matchingLines.first, contains('camera'));
    });

    tearDown(() async {
      // Clean up after each test
      await customLinesService.clearAllCustomLines();
    });
  });
}
