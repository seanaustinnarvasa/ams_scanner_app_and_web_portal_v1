import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:nustar_asset_scanner_app/providers/theme_provider.dart';
import 'package:nustar_asset_scanner_app/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

import 'options/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'NUSTAR Asset Scanner',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: const ColorScheme.light(primary: Color(0xFF390b16)),
              // scaffoldBackgroundColor: const Color(0xFF390b16),
              // colorSchemeSeed: const Color(0xFF390b16),
              // textTheme: GoogleFonts.interTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(primary: Color(0xFFe7bd9c)),
              // scaffoldBackgroundColor: const Color(0xFFe7bd9c),
              // colorSchemeSeed: const Color(0xFFe7bd9c),
              // textTheme: GoogleFonts.interTextTheme(),
            ),
            themeMode: themeProvider.themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
