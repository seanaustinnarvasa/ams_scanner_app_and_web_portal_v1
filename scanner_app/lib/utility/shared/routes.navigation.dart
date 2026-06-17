import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/navigation.menu.dart';

class Routes {
  static final Routes _instance = Routes._internal();
    Routes._internal();

  factory Routes() => _instance;
  
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  static void pushReplace(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void pushNamed(BuildContext context, String name) {
    Navigator.pushNamed(context, name);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  static void pushReplaceNav(BuildContext context, int value) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => NavigationMenu(activeIndex: value, uid: ""))
    );
  }

  static void popAndPush(BuildContext context, String value) {
    Navigator.popAndPushNamed(context, value);
  }

  static void restorePopAndPush(BuildContext context, String name) {
    Navigator.restorablePopAndPushNamed(context, name);
  }

  static void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      )
    );
  }

  /* This allows you to navigate to the next screen and
     also replace the current screen by passing the screen widget */
  static Future<dynamic> replaceScreen(Widget page, {arguments}) 
    async => Routes().navigationKey.currentState?.pushReplacement(
    MaterialPageRoute(
      builder: (_) => page,
    ),
  );

  /* This allows you to navigate to the next screen by passing the screen widget */
  static Future<dynamic> navigateToScreen(Widget page, {arguments}) 
    async => Routes().navigationKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => page,
    ),
  );

  /* For navigating back to the previous screen */
  static dynamic goBack([dynamic popValue]) {
    return Routes().navigationKey.currentState?.pop(popValue);
  }

  /* Allows you to pop to the first screen to when the app first launched.
     This is useful when you need to log out a user,
     and also remove all the screens on the navigation stack.
     I find this very useful */
  static void popToFirst() => Routes().navigationKey.currentState?.popUntil((route) 
    => route.isFirst);

}