import 'dart:async';
import 'package:flutter/material.dart';

import '../utility/shared/app.data.dart';

class IdleManager with ChangeNotifier {
  
  static final IdleManager _instance = IdleManager._internal();
  factory IdleManager() => _instance;

  IdleManager._internal();

  Timer? _timer;

  void startSessionTimer(VoidCallback onTimeout, BuildContext context) {
    _timer?.cancel();

    // _timer = Timer(Duration(seconds: 30), () {
    _timer = Timer(const Duration(minutes: 5), () {
      onTimeout();
    });
  }

  void resetTimer(VoidCallback onTimeout, BuildContext context) {
    _timer?.cancel();
    startSessionTimer(onTimeout, context);
  }

  void showIdle(BuildContext context) async {
    App.showWarningExpiredSession(context);
  }

}
