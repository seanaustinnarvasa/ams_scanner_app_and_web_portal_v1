import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class Toast {

  static void show(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
        timeInSecForIosWeb: 1,
        fontSize: 16.0
        // toastLength: Toast.LENGTH_SHORT,
    );
  }

}