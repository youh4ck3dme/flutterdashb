import 'package:flutter_test/flutter_test.dart';
import 'package:centralny_dashboard/core/google_cloud_access.dart';

void main() {
  group('Google Cloud access guard', () {
    test('allows only the approved paid Google/Firebase profile', () {
      expect(hasGoogleCloudAccess('u0352652320@gmail.com'), isTrue);
      expect(hasGoogleCloudAccess(' U0352652320@GMAIL.COM '), isTrue);
      expect(hasGoogleCloudAccess('test@example.com'), isFalse);
      expect(hasGoogleCloudAccess(null), isFalse);
    });
  });
}
