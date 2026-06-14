import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:centralny_dashboard/core/config.dart';
import 'package:centralny_dashboard/features/blueprints/blueprints_screen.dart';
import 'package:centralny_dashboard/features/h4ck_arsenal/h4ck_arsenal_screen.dart';
import 'package:centralny_dashboard/features/ico_atlas/ico_atlas_screen.dart';

void main() {
  group('Project integrity guardrails', () {
    test('runtime config defaults are safe when secrets are not injected', () {
      expect(AppConfig.isConfigured, isFalse);
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.firebaseApiKey, isEmpty);
      expect(AppConfig.wordpressPublicSiteUrl, isEmpty);
    });

    test('all public frame integrations use production HTTPS URLs', () {
      const urls = {
        'Blueprints': BlueprintsScreen.url,
        'H4CK Arsenal': H4ckArsenalScreen.url,
        'IČO Atlas': IcoAtlasScreen.url,
      };

      for (final entry in urls.entries) {
        final uri = Uri.parse(entry.value);

        expect(uri.scheme, 'https', reason: '${entry.key} must use HTTPS');
        expect(uri.host, isNotEmpty, reason: '${entry.key} must have a host');
        expect(
          uri.host,
          isNot(anyOf('localhost', '127.0.0.1', '0.0.0.0')),
          reason: '${entry.key} must not point to a local dev server',
        );
      }
    });

    test('application source does not ship localhost frame URLs', () {
      final offenders = <String>[];
      final libDir = Directory('lib');
      final localUrlPattern = RegExp(r'(localhost|127\.0\.0\.1|0\.0\.0\.0)');

      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final content = entity.readAsStringSync();
        if (localUrlPattern.hasMatch(content)) {
          offenders.add(entity.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Production source must not include local-only URLs',
      );
    });

    test('Slovak and English localization files expose the same keys', () {
      final en = _readJsonObject('lib/l10n/intl_en.arb');
      final sk = _readJsonObject('lib/l10n/intl_sk.arb');

      final enKeys = en.keys.where((key) => !key.startsWith('@@')).toSet();
      final skKeys = sk.keys.where((key) => !key.startsWith('@@')).toSet();

      expect(skKeys.difference(enKeys), isEmpty);
      expect(enKeys.difference(skKeys), isEmpty);
    });

    test(
      'GitHub Actions workflow protects analyze, tests, build, and deploy',
      () {
        final workflow = File('.github/workflows/ci_cd.yml').readAsStringSync();

        expect(workflow, contains('actions/checkout@v5'));
        expect(workflow, contains('actions/setup-java@v5'));
        expect(workflow, contains('subosito/flutter-action@v2'));
        expect(workflow, contains('flutter analyze'));
        expect(
          workflow,
          contains('flutter test --dart-define=INTEGRATION_TEST=true'),
        );
        expect(
          workflow,
          contains(
            'flutter build web --release --dart-define-from-file=.ci/flutter-secrets.json',
          ),
        );
        expect(workflow, contains('dart run tool/patch_isar_web.dart'));
        expect(workflow, contains('vercel deploy build/web --prod --yes'));
      },
    );

    test('deploy workflow requires every public build secret by name', () {
      final workflow = File('.github/workflows/ci_cd.yml').readAsStringSync();
      const requiredSecrets = [
        'VERCEL_ORG_ID',
        'VERCEL_PROJECT_ID',
        'VERCEL_TOKEN',
        'VITE_SUPABASE_URL',
        'VITE_SUPABASE_PUBLISHABLE_KEY',
        'VITE_FIREBASE_API_KEY',
        'VITE_FIREBASE_AUTH_DOMAIN',
        'VITE_FIREBASE_PROJECT_ID',
        'VITE_FIREBASE_STORAGE_BUCKET',
        'VITE_FIREBASE_MESSAGING_SENDER_ID',
        'VITE_FIREBASE_APP_ID',
        'VITE_FIREBASE_MEASUREMENT_ID',
        'VITE_WORDPRESS_PUBLIC_SITE_URL',
      ];

      for (final secret in requiredSecrets) {
        expect(workflow, contains(secret), reason: '$secret must be wired');
      }
    });

    test(
      'Vercel and Firebase hosting configs preserve SPA fallback routing',
      () {
        final vercel = _readJsonObject('vercel.json');
        final firebase = _readJsonObject('firebase.json');

        final routes = vercel['routes'] as List<dynamic>;
        expect(routes, isNotEmpty);
        expect(routes.last, containsPair('src', '/(.*)'));
        expect(routes.last, containsPair('dest', '/index.html'));

        final hosting = firebase['hosting'] as Map<String, dynamic>;
        expect(hosting['public'], 'build/web');
        expect(
          hosting['rewrites'],
          contains(containsPair('destination', '/index.html')),
        );
      },
    );

    test('local secret files are ignored by git', () {
      final gitignore = File('.gitignore').readAsStringSync();

      expect(gitignore, contains('.vercel'));
      expect(gitignore, contains('.env*'));
    });

    test('pubspec remains private and web-ready', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains("publish_to: 'none'"));
      expect(pubspec, contains('uses-material-design: true'));
      expect(pubspec, contains('firebase_auth:'));
      expect(pubspec, contains('supabase_flutter:'));
      expect(pubspec, contains('url_launcher:'));
    });
  });
}

Map<String, dynamic> _readJsonObject(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}
