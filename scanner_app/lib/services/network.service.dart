import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/buttons.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:app_settings/app_settings.dart';

class NetworkService {
  static final NetworkService _singleton = NetworkService._internal();
  NetworkService._internal();

  static NetworkService getInstance() => _singleton;

  static bool hasConnection = false;

  StreamController connectionChangeController = StreamController.broadcast();

  Stream get connectionChange => connectionChangeController.stream;


  static final FlutterNetworkConnectivity checkConnection =
    FlutterNetworkConnectivity(
      isContinousLookUp: true,
      lookUpDuration: const Duration(seconds: 3),
      lookUpUrl: App.nustarWebsite
  );

  static bool? isInternetAvailableOnCall;

  static bool? isInternetAvailableStreamStatus;

  static StreamSubscription<bool>? networkConnectionStream;

  static void init(BuildContext context) async {
    NetworkService.checkConnection.getInternetAvailabilityStream().listen((event) {
      NetworkService.isInternetAvailableStreamStatus = event;
      if (NetworkService.isInternetAvailableStreamStatus == false) {
        Loader.stop();
        NetworkService.showDialog(context);
        return;
      } else {
        log(App.internetFound);
      }
    });
    await checkConnection.registerAvailabilityListener();
  }

  static void check() async {
    try {
      final result = await InternetAddress.lookup(App.nustarWebsite);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log(App.internetFound);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            hasConnection = true;
        } else {
            hasConnection = false;
        }
        return;
      }
    } on SocketException catch (_) {
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: App.context!,
        type: QuickAlertType.error,
        barrierDismissible: true,
        title: App.warning,
        text: App.noInternet,
        confirmBtnText: App.goSettings,
        onConfirmBtnTap:() {
          log("go to settings!");
        },
      );
    }
  }

  static void showDialog(BuildContext context) {
    Loader.stop();
    QuickAlert.show(
      context: App.context!,
      type: QuickAlertType.warning,
      barrierDismissible: true,
      confirmBtnText: App.ok,
      title: App.warning,
      text: App.noInternet,
      widget: Column(
        children: [
          const SizedBox(height: 20),
          Buttons.themeButton(
            context: context,
            buttonName: App.goSettings,
            height: 10.h,
            width: 65.w,
            onTap: () async 
              => await AppSettings.openAppSettings(
                type: AppSettingsType.wifi
              ),
          ),
        ],
      )
    );
  }

}