import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth_provider.dart';
import 'core/data_provider.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // We initialize services directly inside the Providers lazy loaders or constructor,
  // but to prevent race conditions on startup, we do it in the provider.
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<DataProvider>(
          create: (_) => DataProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centralny Dashboard',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const AppShell();
    }

    return const AuthScreen();
  }
}
