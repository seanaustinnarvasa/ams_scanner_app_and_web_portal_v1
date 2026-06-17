import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';

import 'app.data.dart';

class AppTextFormField {

  static Widget defaultInput(
    String title,
    bool isPassword,
    TextEditingController fieldController, {
      VoidCallback? onTap,
      VoidCallback? onTapKb,
      Widget? thisChild,
      String? initialValue,
      TextInputType? keyboardType,
      bool readOnly = false,
      Color inputTextColor = Colors.white,
    }
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          TextField(
            readOnly: readOnly,
            controller: fieldController, //fieldController..text = initialValue ?? App.e,
            onTap: onTapKb,
            obscureText: isPassword,
            style: TextStyle(
              color: inputTextColor,
              fontFamily: App.fontSecondary,
              fontSize: 23
            ),
            keyboardType: keyboardType ?? TextInputType.text,
            cursorColor: inputTextColor,
            decoration: InputDecoration(
              labelText: title,
              hintStyle: TextStyle(
                color: inputTextColor,
                fontFamily: App.fontSecondary
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: inputTextColor,
                  width: 1.0
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: inputTextColor,
                  width: 1.0
                ),
              ),
              focusColor: CustomColors.darkThemeColor,
              labelStyle: TextStyle(
                color: inputTextColor,
                fontFamily: App.fontSecondary,
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontFamily: App.fontSecondary,
              ),
              fillColor: inputTextColor,
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  onTap != null ? InkWell(
                    onTap: onTap,
                    child: thisChild,
                  ) : const SizedBox(),
                  const SizedBox(width: 4), 
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
        ],
      ),
    );
  }

  static Widget textInputFormField({
    TextEditingController? textField,
    String? labelValue,
    String? hintValue,
    TextInputType? keyboardValue,
    bool? fieldMask,
    bool? hasThousandOperator,
    VoidCallback? onTapField,
    bool textFieldReadOnly = false,
    dynamic themeColor = Colors.white
  }) {
    return TextFormField(
      controller: textField,
      readOnly: textFieldReadOnly,
      onTap: onTapField,
      onChanged: (value) {
        if (hasThousandOperator ?? false) {
          value = App.formNum(
            value.replaceAll(',', ''),
          );
          textField?.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(
              offset: value.length,
            ),
          );
        }
      },
      obscureText: fieldMask ?? false,
      cursorColor: themeColor,
      style: TextStyle(
        color: themeColor,
        fontFamily: App.fontSecondary,
        fontSize: 19
      ),
      decoration: InputDecoration(
        labelText: labelValue,
        hintText: hintValue,
        hintStyle: TextStyle(
          color: themeColor,
          fontFamily: App.fontSecondary,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 2.0
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: themeColor,
            width: 2.0
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: themeColor,
            width: 2.0
          ),
        ),
        focusColor: CustomColors.darkThemeColor,
        suffixIconColor: themeColor,
        prefixIconColor: themeColor,
        iconColor: themeColor,
        hoverColor: themeColor,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(
          color: themeColor,
          fontSize: 19,
          fontFamily: App.fontSecondary
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontFamily: App.fontSecondary
        ),
        fillColor: themeColor,
        isDense: true,
      ),
      keyboardType: keyboardValue,
      textInputAction: TextInputAction.done,
    );
  }

  static Widget textCustomInputFormField({
    TextEditingController? textField,
    String? labelValue,
    String? hintValue,
    TextInputType? keyboardValue,
    bool? fieldMask,
    bool? hasThousandOperator,
    String? initialValue,
  }) {
    return TextFormField(
      controller: textField?..text = initialValue ?? App.e,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: App.fontSecondary
      ),
      decoration: InputDecoration(
        labelText: labelValue,
        hintText: hintValue,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontFamily: App.fontSecondary
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.0
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.0
          ),
        ),
        focusColor: CustomColors.darkThemeColor,
        suffixIconColor: Colors.white,
        prefixIconColor: Colors.white,
        iconColor: Colors.white,
        hoverColor: Colors.white,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontFamily: App.fontSecondary
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontFamily: App.fontSecondary
        ),
        fillColor: Colors.white,
        isDense: true,
      ),
      keyboardType: keyboardValue,
      textInputAction: TextInputAction.done,
    );
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

}