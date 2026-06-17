import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';

class AppButton {
  static normalButton({
    required String title,
    VoidCallback? onPress,
    Color? backgroundColor = CustomColors.darkGrey,
    Color? titleColor = Colors.white,
    bool shadow = true,
    double height = 50,
    double width = double.infinity,
    double textSize = 30,
    FontWeight fontWeight = FontWeight.bold
  }) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: shadow
              ? const [
                  BoxShadow(color: CustomColors.lightGrey, blurRadius: 5),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: fontWeight,
            fontSize: textSize,
            fontFamily: App.fontSecondary,
          ),
        ),
      ),
    );
  }
}
