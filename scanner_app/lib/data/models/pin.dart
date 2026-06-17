import 'package:flutter/material.dart';

enum PinCodeFieldShape { box, underline, circle }

class Pin {
  final Color keysColor;
  final Color? textColor;

  const Pin.defaults({
    this.textColor = Colors.blue,
    this.keysColor = Colors.black,
  });

  factory Pin({
    Color? textColor,
    Color? keysColor,
  }) {
    const defaultValues = Pin.defaults();
    return Pin.defaults(
      textColor: textColor ?? defaultValues.textColor,
      keysColor: keysColor ?? defaultValues.keysColor,
    );
  }
}