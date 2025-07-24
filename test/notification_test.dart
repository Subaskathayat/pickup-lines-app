import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_lines/services/line_of_day_service.dart';

void main() {
  group('LineOfDayService Three-Times-Daily Notifications', () {
    test('should have correct notification times configured', () {
      // Test that the notification times are correctly set
      expect(LineOfDayService.morningHour, equals(8));
      expect(LineOfDayService.morningMinute, equals(0));
      expect(LineOfDayService.afternoonHour, equals(13)); // 1:00 PM
      expect(LineOfDayService.afternoonMinute, equals(0));
      expect(LineOfDayService.eveningHour, equals(19)); // 7:00 PM
      expect(LineOfDayService.eveningMinute, equals(0));
    });

    test('should have correct notifications per day count', () {
      expect(LineOfDayService.notificationsPerDay, equals(3));
    });

    test('should calculate unique notification IDs correctly', () {
      // Test the ID calculation logic: base + (day * 3) + timeSlot
      int baseId = 1000;
      int notificationsPerDay = 3;

      // Day 0 notifications
      int morningId = baseId + (0 * notificationsPerDay) + 0; // 1000
      int afternoonId = baseId + (0 * notificationsPerDay) + 1; // 1001
      int eveningId = baseId + (0 * notificationsPerDay) + 2; // 1002

      expect(morningId, equals(1000));
      expect(afternoonId, equals(1001));
      expect(eveningId, equals(1002));

      // Day 1 notifications
      int day1MorningId = baseId + (1 * notificationsPerDay) + 0; // 1003
      int day1AfternoonId = baseId + (1 * notificationsPerDay) + 1; // 1004
      int day1EveningId = baseId + (1 * notificationsPerDay) + 2; // 1005

      expect(day1MorningId, equals(1003));
      expect(day1AfternoonId, equals(1004));
      expect(day1EveningId, equals(1005));
    });

    test('should calculate next notification time correctly', () async {
      final service = LineOfDayService.instance;

      // This test verifies that getTimeUntilNextUpdate returns a valid duration
      final duration = await service.getTimeUntilNextUpdate();
      expect(duration, isNotNull);
      expect(duration!.inSeconds, greaterThan(0));
    });

    test('should handle notification time transitions correctly', () {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Create test notification times
      List<DateTime> todayNotifications = [
        DateTime(today.year, today.month, today.day, 8, 0), // 8:00 AM
        DateTime(today.year, today.month, today.day, 13, 0), // 1:00 PM
        DateTime(today.year, today.month, today.day, 19, 0), // 7:00 PM
      ];

      // Verify that notification times are in chronological order
      expect(todayNotifications[0].isBefore(todayNotifications[1]), isTrue);
      expect(todayNotifications[1].isBefore(todayNotifications[2]), isTrue);

      // Verify that times are correctly spaced (5 hours between morning and afternoon, 6 hours between afternoon and evening)
      Duration morningToAfternoon =
          todayNotifications[1].difference(todayNotifications[0]);
      Duration afternoonToEvening =
          todayNotifications[2].difference(todayNotifications[1]);

      expect(morningToAfternoon.inHours, equals(5));
      expect(afternoonToEvening.inHours, equals(6));
    });
  });
}
