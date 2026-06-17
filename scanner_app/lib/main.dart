import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/application/splash.activity.dart';
import 'package:nustar_turnstile_scanner/screens/asset.tag.screen.dart';
import 'package:nustar_turnstile_scanner/screens/asset.scanner.dart';
import 'package:nustar_turnstile_scanner/screens/home.screen.dart';
import 'package:nustar_turnstile_scanner/screens/qr.scanner.screen.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService.firebaseInit();
  runApp(const Main());
  // runApp(
  //   ChangeNotifierProvider(
  //     create: (_) => IdleManager(),
  //     child: const Main(),
  //   ),
  // );
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${App.nustar} ${App.merchant}",
      theme:
          ThemeData(primarySwatch: Colors.blue, fontFamily: App.fontSecondary),
      debugShowCheckedModeBanner: false,
      navigatorKey: Routes().navigationKey,
      initialRoute: Home.routeName, //WelcomeScreen.routeName
      routes: {
        SplashActivity.routeName: (context) => const SplashActivity(),
        Home.routeName: (context) => const Home(),
        AssetScannerScreen.routeName: (context) => const AssetScannerScreen(),
        AssetTagScreen.routeName: (context) => const AssetTagScreen(),
        QRScannerScreen.routeName: (context) => const QRScannerScreen(),
        QRScanResultPage.routeName: (context) => const QRScanResultPage(qrData: '', values: []),
      },
    );
  }
}
