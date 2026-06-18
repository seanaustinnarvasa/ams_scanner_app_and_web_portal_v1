import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nustar_asset_scanner_app/providers/auth_provider.dart';
import 'package:nustar_asset_scanner_app/providers/theme_provider.dart';
import 'package:nustar_asset_scanner_app/screens/dashboard_screen.dart';
import 'package:nustar_asset_scanner_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

import 'options/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Asset Movement Log',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(primary: Color(0xFF390b16)),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(primary: Color(0xFFe7bd9c)),
            ),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return const DashboardScreen();
  }
}
