import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:centralny_dashboard/main.dart' as app;

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
    if (tester.any(finder)) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for widget: $finder');
}

Future<void> _pumpFor(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 300),
]) async {
  final frames = (duration.inMilliseconds / 50).ceil().clamp(1, 200);
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _setDesktopViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
}

Future<void> _loginWithPassword(WidgetTester tester) async {
  app.main();
  await _pumpUntilFound(tester, find.text('Prihlásenie'));

  final emailField = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == 'you@example.com',
  );
  final passwordField = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == '••••••••',
  );

  expect(emailField, findsOneWidget);
  expect(passwordField, findsOneWidget);

  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password123');
  await _pumpFor(tester);

  final loginBtn = find.widgetWithText(ElevatedButton, 'Prihlásiť sa');
  expect(loginBtn, findsOneWidget);
  await tester.tap(loginBtn);
  await _pumpUntilFound(tester, find.text('Prehľad'));
}

Future<void> _tapSidebarItem(WidgetTester tester, String label) async {
  final sidebarListView = find.byType(ListView).first;

  for (var attempt = 0; attempt < 10; attempt++) {
    final item = find.descendant(
      of: sidebarListView,
      matching: find.text(label),
    );
    if (item.evaluate().isNotEmpty) {
      final tile = find
          .ancestor(of: item, matching: find.byType(InkWell))
          .first;
      await tester.tap(tile);
      await _pumpFor(tester);
      return;
    }

    await tester.drag(sidebarListView, const Offset(0, -220));
    await _pumpFor(tester);
  }

  throw TestFailure('Timed out waiting for sidebar item: $label');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Centralny Dashboard desktop integration tests', () {
    setUpAll(() {
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    testWidgets(
      'complete user workflow: login, create bug, chat with AI, update profile, and logout',
      (WidgetTester tester) async {
        await _setDesktopViewport(tester);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await _loginWithPassword(tester);

        expect(find.text('Prehľad'), findsAtLeastNWidgets(1));
        expect(find.text('Nahlásiť chybu'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Nahlásiť chybu'));
        await _pumpFor(tester);

        await tester.enterText(
          find.byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.hintText == 'Stručný popis problému...',
          ),
          'Integration Test Bug Title',
        );
        await tester.enterText(
          find.byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.hintText == 'Detailný popis chyby, čo sa deje...',
          ),
          'This bug was created automatically by the integration test suite.',
        );
        await _pumpFor(tester);

        final submitBugBtn = find.widgetWithText(
          ElevatedButton,
          'Odoslať chybu',
        );
        await tester.ensureVisible(submitBugBtn);
        await tester.tap(submitBugBtn);
        await _pumpUntilFound(
          tester,
          find.text('Chyba bola úspešne nahlásená'),
        );

        final context = tester.element(find.byType(app.AuthGate));
        ScaffoldMessenger.of(context).clearSnackBars();
        await _pumpFor(tester);

        expect(find.text('Integration Test Bug Title'), findsOneWidget);

        await _tapSidebarItem(tester, 'AI Asistent');
        await _pumpUntilFound(tester, find.text('Optimalizácia Isar databázy'));

        final aiInputField = find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.hintText == 'Položte otázku...',
        );
        await tester.enterText(
          aiInputField,
          'How do I optimize local storage?',
        );
        await _pumpFor(tester);
        await tester.tap(find.byIcon(LucideIcons.send));
        await _pumpUntilFound(
          tester,
          find.textContaining('Toto je simulovaná odpoveď na:'),
        );

        await _tapSidebarItem(tester, 'Nastavenia');
        await _pumpUntilFound(tester, find.text('Môj profil'));

        await tester.enterText(
          find.byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.hintText == 'Meno a priezvisko...',
          ),
          'Integration Updated User Name',
        );
        await _pumpFor(tester);

        final saveSettingsBtn = find.widgetWithText(
          ElevatedButton,
          'Uložiť zmeny',
        );
        await tester.ensureVisible(saveSettingsBtn);
        await tester.tap(saveSettingsBtn);
        await _pumpUntilFound(tester, find.text('Profil úspešne uložený'));

        ScaffoldMessenger.of(context).clearSnackBars();
        await _pumpFor(tester);

        final logoutIcon = find.byIcon(LucideIcons.logOut);
        await tester.ensureVisible(logoutIcon.last);
        await tester.tap(logoutIcon.last);
        await _pumpUntilFound(tester, find.text('Prihlásenie'));

        expect(find.text('Prihlásenie'), findsOneWidget);
      },
    );

    testWidgets('side menu tabs render successfully', (
      WidgetTester tester,
    ) async {
      await _setDesktopViewport(tester);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await _loginWithPassword(tester);

      final sidebarListView = find.byType(ListView).first;
      for (final label in [
        'Prehľad',
        'Projekty',
        'Zoznam chýb',
        'CRM',
        'Email Sender',
        'Blueprints',
        'IČO Atlas',
        'H4CK Arsenal',
      ]) {
        expect(
          find.descendant(of: sidebarListView, matching: find.text(label)),
          findsOneWidget,
          reason: '$label should be visible before scrolling',
        );
      }

      await tester.drag(sidebarListView, const Offset(0, -360));
      await _pumpFor(tester);

      for (final label in [
        'Analytika',
        'AI Asistent',
        'Nastavenia',
        'Changelog',
      ]) {
        expect(
          find.descendant(of: sidebarListView, matching: find.text(label)),
          findsOneWidget,
          reason: '$label should be visible after scrolling',
        );
      }
    });
  });
}
