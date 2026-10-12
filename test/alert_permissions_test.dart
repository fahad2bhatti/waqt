import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/native/device_health.dart';
import 'package:waqt/features/onboarding/data/alert_permissions.dart';

void main() {
  Map<WaqtPermission, bool> allOn() => {
    for (final permission in alertPermissions) permission: true,
  };

  group('nextMissingAlert', () {
    test('returns null when everything is granted', () {
      expect(nextMissingAlert(allOn()), isNull);
    });

    test('asks notifications first', () {
      final status = allOn()
        ..[WaqtPermission.notifications] = false
        ..[WaqtPermission.battery] = false;
      expect(nextMissingAlert(status), WaqtPermission.notifications);
    });

    test('follows the fixed order', () {
      final status = allOn()
        ..[WaqtPermission.fullScreenIntent] = false
        ..[WaqtPermission.battery] = false;
      expect(nextMissingAlert(status), WaqtPermission.fullScreenIntent);
    });

    test('treats a missing entry as not granted', () {
      expect(nextMissingAlert(const {}), WaqtPermission.notifications);
    });

    test('ignores permissions the Azan does not need', () {
      final status = allOn()
        ..[WaqtPermission.overlay] = false
        ..[WaqtPermission.usageAccess] = false;
      expect(nextMissingAlert(status), isNull);
    });
  });
}
