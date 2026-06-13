import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:isar/isar.dart';
import 'package:centralny_dashboard/main.dart' as app;
import 'package:centralny_dashboard/core/isar_service.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
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
  group('Centralny Dashboard E2E Headless Tests', () {
    setUpAll(() async {
      GoogleFonts.config.allowRuntimeFetching = false;
      const MethodChannel channel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            return '.';
          });
      await Isar.initializeIsarCore(download: true);

      // Initialize the Isar database in the real event loop before running testWidgets
      final isarService = IsarService();
      await isarService.init();
    });

    testWidgets(
      'Complete user workflow: login, create bug, chat with AI, update profile, and logout',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Start the application
        app.main();
        await _pumpUntilFound(tester, find.text('Prihlásenie'));

        // Verify we are on the login screen
        expect(find.text('Prihlásenie'), findsOneWidget);
        expect(find.text('Registrácia'), findsOneWidget);

        // 2. Fill login details (mocked automatically under INTEGRATION_TEST flag)
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

        // Tap login button
        final loginBtn = find.widgetWithText(ElevatedButton, 'Prihlásiť sa');
        expect(loginBtn, findsOneWidget);
        await tester.tap(loginBtn);

        // Wait for login process and transition to Dashboard
        await _pumpUntilFound(tester, find.text('Prehľad'));

        // Verify we are now logged in and looking at the Dashboard
        expect(find.text('Prehľad'), findsAtLeastNWidgets(1));
        expect(find.text('Nahlásiť chybu'), findsOneWidget);

        // 3. Create a new bug
        final reportBugBtn = find.widgetWithText(
          ElevatedButton,
          'Nahlásiť chybu',
        );
        await tester.tap(reportBugBtn);
        await _pumpFor(tester);

        // Fill bug form details
        final titleField = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Stručný popis problému...',
        );
        final descField = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Detailný popis chyby, čo sa deje...',
        );

        await tester.enterText(titleField, 'E2E Test Bug Title');
        await tester.enterText(
          descField,
          'This bug was created automatically by our E2E test suite.',
        );
        await _pumpFor(tester);

        // Submit bug
        final submitBugBtn = find.widgetWithText(
          ElevatedButton,
          'Odoslať chybu',
        );
        await tester.ensureVisible(submitBugBtn);
        await tester.tap(submitBugBtn);

        // Wait for the snackbar to appear asynchronously
        await _pumpUntilFound(
          tester,
          find.text('Chyba bola úspešne nahlásená'),
        );
        await _pumpFor(tester);

        // Clear all snackbars so they don't block hit testing of inputs/buttons at the bottom
        final BuildContext context = tester.element(find.byType(app.AuthGate));
        ScaffoldMessenger.of(context).clearSnackBars();
        await _pumpFor(tester);

        // Verify the new bug is displayed in the list/table
        expect(find.text('E2E Test Bug Title'), findsOneWidget);

        // 4. Navigate to AI Assistant
        await _tapSidebarItem(tester, 'AI Asistent');
        await _pumpUntilFound(tester, find.text('Optimalizácia Isar databázy'));

        // Verify we are in AI Assistant view
        expect(find.text('AI Asistent'), findsAtLeastNWidgets(1));

        // Select the first conversation, which gets automatically loaded in mock mode
        expect(find.text('Optimalizácia Isar databázy'), findsOneWidget);

        // Find prompt input and type a question
        final aiInputField = find.byWidgetPredicate(
          (w) =>
              w is TextField && w.decoration?.hintText == 'Položte otázku...',
        );
        await _pumpUntilFound(tester, aiInputField);
        await tester.enterText(
          aiInputField,
          'How do I optimize local storage?',
        );
        await _pumpFor(tester);

        // Send the message
        final sendBtn = find.byIcon(LucideIcons.send);
        await tester.tap(sendBtn);
        await tester.pump();

        // Wait for mock AI response to load asynchronously
        await _pumpUntilFound(
          tester,
          find.textContaining('Toto je simulovaná odpoveď na:'),
        );
        await _pumpFor(tester);

        // Verify mock response is visible on the screen
        expect(
          find.textContaining('How do I optimize local storage?'),
          findsAtLeastNWidgets(1),
        );

        // 5. Navigate to Settings
        await _tapSidebarItem(tester, 'Nastavenia');
        await _pumpUntilFound(tester, find.text('Môj profil'));

        // Verify settings screen is active
        expect(find.text('Nastavenia'), findsAtLeastNWidgets(1));
        expect(find.text('Môj profil'), findsOneWidget);

        // Update Full Name in settings
        final nameField = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Meno a priezvisko...',
        );
        await tester.enterText(nameField, 'E2E Updated User Name');
        await _pumpFor(tester);

        // Click save profile button
        final saveSettingsBtn = find.widgetWithText(
          ElevatedButton,
          'Uložiť zmeny',
        );
        await tester.ensureVisible(saveSettingsBtn);
        await tester.tap(saveSettingsBtn);

        // Wait for success snackbar asynchronously
        await _pumpUntilFound(tester, find.text('Profil úspešne uložený'));
        await _pumpFor(tester);

        // Clear all snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
        await _pumpFor(tester);

        // 6. Sign out
        final logoutIcon = find.byIcon(LucideIcons.logOut);
        await tester.ensureVisible(logoutIcon.last);
        await tester.tap(logoutIcon.last);
        await _pumpUntilFound(tester, find.text('Prihlásenie'));

        // Verify we are back to the AuthScreen
        expect(find.text('Prihlásenie'), findsOneWidget);
      },
    );

    testWidgets('Side menu navigation tabs render successfully', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      app.main();
      await _pumpUntilFound(tester, find.text('Prihlásenie'));

      // Perform login
      final emailField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'you@example.com',
      );
      final passwordField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '••••••••',
      );
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await _pumpFor(tester);

      final loginBtn = find.widgetWithText(ElevatedButton, 'Prihlásiť sa');
      await tester.tap(loginBtn);
      await _pumpUntilFound(tester, find.text('Prehľad'));

      // Verify side navigation is populated with all sections
      final sidebarListView = find.byType(ListView).first;
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Prehľad')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Projekty')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sidebarListView,
          matching: find.text('Zoznam chýb'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('CRM')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sidebarListView,
          matching: find.text('Email Sender'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Blueprints')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('IČO Atlas')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sidebarListView,
          matching: find.text('H4CK Arsenal'),
        ),
        findsOneWidget,
      );
      await tester.drag(sidebarListView, const Offset(0, -360));
      await _pumpFor(tester);
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Analytika')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sidebarListView,
          matching: find.text('AI Asistent'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Nastavenia')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sidebarListView, matching: find.text('Changelog')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Google Sign-In workflow: click login, redirect to Dashboard, view profile, and logout',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Start the application
        app.main();
        await _pumpUntilFound(tester, find.text('Prihlásenie'));

        // Verify we are on the login screen
        expect(find.text('Prihlásenie'), findsOneWidget);

        // Find the Google Sign-In button
        final googleLoginBtn = find.widgetWithText(
          OutlinedButton,
          'Pokračovať cez Google',
        );
        expect(googleLoginBtn, findsOneWidget);

        // Tap Google Login button
        await tester.tap(googleLoginBtn);

        // Wait for login process and transition to Dashboard
        await _pumpUntilFound(tester, find.text('Prehľad'));

        // Verify we are now logged in and looking at the Dashboard
        expect(find.text('Prehľad'), findsAtLeastNWidgets(1));

        // Verify the user profile card has the correct Google Test User name
        expect(find.text('Google Test User'), findsOneWidget);

        // Clear all snackbars
        final BuildContext context = tester.element(find.byType(app.AuthGate));
        ScaffoldMessenger.of(context).clearSnackBars();
        await _pumpFor(tester);

        // Sign out
        final logoutIcon = find.byIcon(LucideIcons.logOut);
        await tester.ensureVisible(logoutIcon.last);
        await tester.tap(logoutIcon.last);
        await _pumpUntilFound(tester, find.text('Prihlásenie'));

        // Verify we are back to the AuthScreen
        expect(find.text('Prihlásenie'), findsOneWidget);
      },
    );
  });
}
