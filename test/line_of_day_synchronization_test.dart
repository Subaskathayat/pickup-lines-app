import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/line_of_day_service.dart';

void main() {
  group('Line of Day Synchronization Tests', () {
    late LineOfDayService lineOfDayService;

    setUp(() async {
      // Initialize SharedPreferences with mock data
      SharedPreferences.setMockInitialValues({});
      lineOfDayService = LineOfDayService.instance;
    });

    test('getAllDailyLines returns 3 lines with correct structure', () async {
      // Generate daily lines for today
      final today = DateTime.now();
      await lineOfDayService.generateDailyLines(today);

      // Get all daily lines
      final dailyLines = await lineOfDayService.getAllDailyLines();

      // Verify we have exactly 3 lines
      expect(dailyLines.length, equals(3));

      // Verify each line has the required structure
      for (int i = 0; i < dailyLines.length; i++) {
        final lineData = dailyLines[i];
        
        expect(lineData['line'], isNotNull);
        expect(lineData['category'], isNotNull);
        expect(lineData['timeSlot'], isNotNull);
        expect(lineData['time'], isNotNull);
        expect(lineData['icon'], isNotNull);
        expect(lineData['description'], isNotNull);
      }

      // Verify time slots are correct
      expect(dailyLines[0]['timeSlot'], equals('Morning'));
      expect(dailyLines[0]['time'], equals('8:00 AM'));
      expect(dailyLines[0]['icon'], equals('🌅'));

      expect(dailyLines[1]['timeSlot'], equals('Afternoon'));
      expect(dailyLines[1]['time'], equals('1:00 PM'));
      expect(dailyLines[1]['icon'], equals('🌞'));

      expect(dailyLines[2]['timeSlot'], equals('Evening'));
      expect(dailyLines[2]['time'], equals('7:00 PM'));
      expect(dailyLines[2]['icon'], equals('🌙'));
    });

    test('getAllDailyLinesWithCurrentHighlight includes current time slot info', () async {
      // Generate daily lines for today
      final today = DateTime.now();
      await lineOfDayService.generateDailyLines(today);

      // Get all daily lines with current highlight
      final result = await lineOfDayService.getAllDailyLinesWithCurrentHighlight();

      // Verify structure
      expect(result['lines'], isNotNull);
      expect(result['currentTimeSlot'], isNotNull);
      expect(result['currentTimeSlotName'], isNotNull);

      final lines = result['lines'] as List<Map<String, String?>>;
      final currentTimeSlot = result['currentTimeSlot'] as int;
      final currentTimeSlotName = result['currentTimeSlotName'] as String;

      // Verify we have 3 lines
      expect(lines.length, equals(3));

      // Verify current time slot is valid
      expect(currentTimeSlot, inInclusiveRange(0, 2));
      expect(['Morning', 'Afternoon', 'Evening'], contains(currentTimeSlotName));
    });

    test('notification content matches daily lines', () async {
      final today = DateTime.now();
      await lineOfDayService.generateDailyLines(today);

      // Get daily lines
      final dailyLines = await lineOfDayService.getAllDailyLines();

      // Get notification content for each time slot
      for (int timeSlot = 0; timeSlot < 3; timeSlot++) {
        final notificationContent = await lineOfDayService.calculateNotificationForDate(today, timeSlot);
        final dailyLineContent = dailyLines[timeSlot];

        if (notificationContent != null) {
          // Verify that notification content matches daily line content
          expect(notificationContent['line'], equals(dailyLineContent['line']));
          expect(notificationContent['category'], equals(dailyLineContent['category']));
        }
      }
    });

    test('daily lines are consistent across multiple calls', () async {
      final today = DateTime.now();
      
      // Generate daily lines multiple times
      await lineOfDayService.generateDailyLines(today);
      final firstCall = await lineOfDayService.getAllDailyLines();
      
      await lineOfDayService.generateDailyLines(today);
      final secondCall = await lineOfDayService.getAllDailyLines();

      // Verify lines are identical (same seed should produce same results)
      expect(firstCall.length, equals(secondCall.length));
      
      for (int i = 0; i < firstCall.length; i++) {
        expect(firstCall[i]['line'], equals(secondCall[i]['line']));
        expect(firstCall[i]['category'], equals(secondCall[i]['category']));
        expect(firstCall[i]['timeSlot'], equals(secondCall[i]['timeSlot']));
      }
    });

    test('different dates produce different lines', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      // Generate lines for today and tomorrow
      await lineOfDayService.generateDailyLines(today);
      await lineOfDayService.generateDailyLines(tomorrow);
      
      // Get lines for both dates
      final todayMorning = await lineOfDayService.calculateNotificationForDate(today, 0);
      final tomorrowMorning = await lineOfDayService.calculateNotificationForDate(tomorrow, 0);

      // Verify lines are different (different seeds should produce different results)
      if (todayMorning != null && tomorrowMorning != null) {
        expect(todayMorning['line'], isNot(equals(tomorrowMorning['line'])));
      }
    });
  });
}
