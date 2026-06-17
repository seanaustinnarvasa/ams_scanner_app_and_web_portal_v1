import 'package:flutter/material.dart';

class Sizes {
  
  static dynamic getMediaQueryHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  static dynamic getMediaQueryWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static Size displaySize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double displayHeight(BuildContext context) {
    return displaySize(context).height;
  }

  static double displayWidth(BuildContext context) {
    return displaySize(context).width;
  }

}