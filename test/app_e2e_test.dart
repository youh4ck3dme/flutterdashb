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

void main() {
  group('Centralny Dashboard E2E Headless Tests', () {
    setUpAll(() async {
      GoogleFonts.config.allowRuntimeFetching = false;
      const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return '.';
      });
      await Isar.initializeIsarCore(download: true);
      
      // Initialize the Isar database in the real event loop before running testWidgets
      final isarService = IsarService();
      await isarService.init();
    });

    testWidgets('Complete user workflow: login, create bug, chat with AI, update profile, and logout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Start the application
      app.main();
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Tap login button
      final loginBtn = find.widgetWithText(ElevatedButton, 'Prihlásiť sa');
      expect(loginBtn, findsOneWidget);
      await tester.tap(loginBtn);
      
      // Wait for login process and transition to Dashboard
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify we are now logged in and looking at the Dashboard
      expect(find.text('Prehľad'), findsAtLeastNWidgets(1));
      expect(find.text('Nahlásiť chybu'), findsOneWidget);

      // 3. Create a new bug
      final reportBugBtn = find.widgetWithText(ElevatedButton, 'Nahlásiť chybu');
      await tester.tap(reportBugBtn);
      await tester.pumpAndSettle();

      // Fill bug form details
      final titleField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Stručný popis problému...',
      );
      final descField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Detailný popis chyby, čo sa deje...',
      );

      await tester.enterText(titleField, 'E2E Test Bug Title');
      await tester.enterText(descField, 'This bug was created automatically by our E2E test suite.');
      await tester.pumpAndSettle();

      // Submit bug
      final submitBugBtn = find.widgetWithText(ElevatedButton, 'Odoslať chybu');
      await tester.ensureVisible(submitBugBtn);
      await tester.tap(submitBugBtn);

      // Wait for the snackbar to appear asynchronously
      await _pumpUntilFound(tester, find.text('Chyba bola úspešne nahlásená'));
      await tester.pumpAndSettle(); // Wait for navigation transition to complete

      // Clear all snackbars so they don't block hit testing of inputs/buttons at the bottom
      final BuildContext context = tester.element(find.byType(app.AuthGate));
      ScaffoldMessenger.of(context).clearSnackBars();
      await tester.pumpAndSettle();

      // Verify the new bug is displayed in the list/table
      expect(find.text('E2E Test Bug Title'), findsOneWidget);

      // 4. Navigate to AI Assistant
      final aiSidebarItem = find.descendant(
        of: find.byType(ListView),
        matching: find.text('AI Asistent'),
      );
      await tester.tap(aiSidebarItem);
      await tester.pumpAndSettle();

      // Verify we are in AI Assistant view
      expect(find.text('AI Asistent'), findsAtLeastNWidgets(1));
      
      // Select the first conversation, which gets automatically loaded in mock mode
      expect(find.text('Optimalizácia Isar databázy'), findsOneWidget);

      // Find prompt input and type a question
      final aiInputField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Položte otázku...',
      );
      await tester.enterText(aiInputField, 'How do I optimize local storage?');
      await tester.pumpAndSettle();

      // Send the message
      final sendBtn = find.byIcon(LucideIcons.send);
      await tester.tap(sendBtn);
      await tester.pump();

      // Wait for mock AI response to load asynchronously
      await _pumpUntilFound(tester, find.textContaining('Toto je simulovaná odpoveď na:'));
      await tester.pumpAndSettle();

      // Verify mock response is visible on the screen
      expect(find.textContaining('How do I optimize local storage?'), findsAtLeastNWidgets(1));

      // 5. Navigate to Settings
      final settingsSidebarItem = find.descendant(
        of: find.byType(ListView),
        matching: find.text('Nastavenia'),
      );
      await tester.tap(settingsSidebarItem);
      await tester.pumpAndSettle();

      // Verify settings screen is active
      expect(find.text('Nastavenia'), findsAtLeastNWidgets(1));
      expect(find.text('Môj profil'), findsOneWidget);

      // Update Full Name in settings
      final nameField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Meno a priezvisko...',
      );
      await tester.enterText(nameField, 'E2E Updated User Name');
      await tester.pumpAndSettle();

      // Click save profile button
      final saveSettingsBtn = find.widgetWithText(ElevatedButton, 'Uložiť zmeny');
      await tester.ensureVisible(saveSettingsBtn);
      await tester.tap(saveSettingsBtn);

      // Wait for success snackbar asynchronously
      await _pumpUntilFound(tester, find.text('Profil úspešne uložený'));
      await tester.pumpAndSettle();

      // Clear all snackbars
      ScaffoldMessenger.of(context).clearSnackBars();
      await tester.pumpAndSettle();

      // 6. Sign out
      final logoutBtn = find.byIcon(LucideIcons.logOut);
      await tester.tap(logoutBtn.first);
      await tester.pumpAndSettle();

      // Verify we are back to the AuthScreen
      expect(find.text('Prihlásenie'), findsOneWidget);
    });

    testWidgets('Side menu navigation tabs render successfully', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      app.main();
      await tester.pumpAndSettle();

      // Perform login
      final emailField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'you@example.com',
      );
      final passwordField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '••••••••',
      );
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final loginBtn = find.widgetWithText(ElevatedButton, 'Prihlásiť sa');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify side navigation is populated with all sections
      final sidebarListView = find.byType(ListView).first;
      expect(find.descendant(of: sidebarListView, matching: find.text('Prehľad')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('Projekty')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('Zoznam chýb')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('Analytika')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('AI Asistent')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('Nastavenia')), findsOneWidget);
      expect(find.descendant(of: sidebarListView, matching: find.text('Changelog')), findsOneWidget);
    });
  });
}
