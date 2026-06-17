import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/screens/signin.screen.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/print.receipt.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
// import 'package:nustar_turnstile_scanner/services/network.service.dart';

class SplashActivity extends StatefulWidget {
  static String routeName = App.splashScreen;
  const SplashActivity({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SplashActivityState createState() => _SplashActivityState();
}

class _SplashActivityState extends State<SplashActivity> {
  var selectedItem = App.splash;

  @override
  void initState() {
    initApplication();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  void initApplication() async {
    // App.checkAppPermissions();
    setState(() {
      App.context = context;
      // App.isIdle = true;
      // App.showEnvMode = true; ///TODO: -- REMOVE IF PROD
    });
    // NetworkService.init(context);
    App.initJSONresponse(App.lausuarioacepta); //App.pinchar);
    App.memberCurrentDeviceID = await App.getDeviceID() ?? App.na;
    // telpoConnect();
    if (App.memberCurrentDeviceID != null) {
      debugPrint("${App.currentDeviceId} ${App.memberCurrentDeviceID}");
      // App.captureDeviceID(context);
      // ThermalPrinter.wiseasyConnectToPrinter(context);
      Routes.navigateToScreen(const SignInScreen());
    } else {
      log(App.deviceNotFound);
    }
  }

  Future<void> telpoConnect() async {
    final bool connected = await ThermalPrinter.telpoFlutterChannel.connect();
    if (!connected) {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: true,
        confirmBtnText: App.ok,
        title: App.e,
        text: "Telpo ${App.deviceNotFound}"
      );
      log(App.telpoNotFound);
      return;
    }
    setState(() => App.telpoServiceConnected = true);
    log(App.telpoConnected);
  }
  
}