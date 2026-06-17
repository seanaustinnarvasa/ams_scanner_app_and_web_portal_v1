import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

class Buttons {

  static Widget themeButton({
    required BuildContext context,
    required String buttonName,
    required double height,
    required double width,
    VoidCallback? onTap,
    Color? splashHoverColor
  }) {
    return inkBtn(
      onTap: onTap,
      buttonText: buttonName,
      height: height,
      width: width
    );
  }

  static Widget smallPreviousBtn({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.white, size: 13
                    ),
                  ),
                  TextSpan(
                    text: App.back.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: App.fontSecondary,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget inkBtn({
    VoidCallback? onTap,
    required String buttonText,
    required double height,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              CustomColors.themeColor
            ]
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withAlpha(100),
              offset: const Offset(1, 1),
              blurRadius: 8,
              spreadRadius: 2
            )
          ],
          color: Colors.white
        ),
        child: Text(
          buttonText.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: App.fontSecondary,
            fontSize: 18,
            color: Colors.white
          ),
        ),
      )
    );
  }
  
}