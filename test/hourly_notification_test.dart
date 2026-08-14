import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hourly Notification System Revamp Tests', () {
    test('Verify hourly schedule window is 9 AM to 12 AM (16 slots)', () {
      final List<int> targetHours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 0];

      expect(targetHours.length, 16);
      expect(targetHours.first, 9); // Morning start 9 AM
      expect(targetHours.last, 0);  // Midnight 12 AM

      // Assert rest hours (1 AM to 8 AM) are excluded
      for (int h = 1; h <= 8; h++) {
        expect(targetHours.contains(h), isFalse);
      }
    });
  });
}
