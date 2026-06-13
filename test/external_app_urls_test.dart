import 'package:flutter_test/flutter_test.dart';
import 'package:centralny_dashboard/features/blueprints/blueprints_screen.dart';
import 'package:centralny_dashboard/features/h4ck_arsenal/h4ck_arsenal_screen.dart';
import 'package:centralny_dashboard/features/ico_atlas/ico_atlas_screen.dart';

void main() {
  test('external frame apps use public HTTPS URLs', () {
    const urls = [
      BlueprintsScreen.url,
      H4ckArsenalScreen.url,
      IcoAtlasScreen.url,
    ];

    for (final url in urls) {
      final uri = Uri.parse(url);

      expect(uri.scheme, 'https', reason: '$url must be HTTPS in production');
      expect(
        uri.host,
        isNot(anyOf('127.0.0.1', 'localhost', '0.0.0.0')),
        reason: '$url must not point to a local dev server',
      );
    }
  });
}
