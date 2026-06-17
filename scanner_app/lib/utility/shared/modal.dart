import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nustar_turnstile_scanner/components/sizes.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/buttons.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:nustar_turnstile_scanner/utility/shared/text.field.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Modal {
  static final Modal _instance = Modal._internal();
    Modal._internal();

  factory Modal() => _instance;
  
  static Future<dynamic> modalInfo(
    BuildContext context,
    String msgValue,
    String msgBtn
  ) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        message: 
          Text(
            msgValue,
            style: 
              const TextStyle(
                color: Colors.black,
                fontFamily: App.fontSecondary,
                fontSize: 16.0
              ),
          ),
        cancelButton: CupertinoActionSheetAction(
          child: Text(msgBtn),
          onPressed: () => Routes.pop(context),
        ),
      ),
    );
  }

  static modalLoader(
    BuildContext context,
    String title,
    String subject
  ) async {
    return showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(subject),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: 
                const SizedBox(
                  height: 50,
                  width: 50,
                ),
              onPressed: () => Routes.pop(context),
            ),
          ],
        );
      },
    );
  }

  static Future<void> textInputDialog(
    BuildContext context, {
    required String messageValue,
    String? membershipID,
    String? transactionID,
    String? compsRedeemValue,
    String? transactedAmountValue,
    String? pointsToRedeemValue,
    String? voucherValue,
    String? cardHolderName,
    bool? isCompNumber = true,
    VoidCallback? whenPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            messageValue.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: App.fontSecondary,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              membershipID != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: const Text(
                          '${App.playerId}:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          membershipID,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.normal
                          ),
                        )
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
                ],
              ) : const SizedBox(),
              cardHolderName != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          '${App.nameKey}:'.capitalize(),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: Sizes.displayWidth(context),
                    padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      cardHolderName.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  )
                ],
              ) : const SizedBox(),
              transactionID != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: const Text(
                          '${App.invoiceNumber}:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          transactionID,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ) : const SizedBox(),
              transactedAmountValue != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: const Text(
                          '${App.transactedAmount}:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          transactedAmountValue,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ) : const SizedBox(),
              pointsToRedeemValue != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.bottomLeft,
                        child: const Text(
                          '${App.pointsToRedeem}:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                        alignment: FractionalOffset.bottomRight,
                        child: Text(
                          pointsToRedeemValue.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ) : const SizedBox(),
              compsRedeemValue != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: const Text(
                          '${App.compsToRedeem}:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          compsRedeemValue.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ) : const SizedBox(),
              voucherValue != null ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       Container(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                        alignment: FractionalOffset.centerLeft,
                        child: Text(
                          '${isCompNumber == false ? App.compId : App.voucher}:',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: Sizes.displayWidth(context),
                    padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      voucherValue.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  )
                ],
              ) : const SizedBox(),
            ],
          ),
          actions: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Buttons.inkBtn(
                  onTap: whenPressed,
                  buttonText: App.yes,
                  height: 12.h,
                  width: 35.w
                ),
                const SizedBox(width: 3),
                Buttons.inkBtn(
                  onTap: () => Routes.goBack(),
                  buttonText: App.cancel,
                  height: 12.h,
                  width: 35.w
                ),
              ],
            )
          ],
        );
      }
    );
  }

  static Future<void> inputFieldDialog(
    BuildContext context, {
    required String modalTitle,
    TextEditingController? inputField,
    String? submitButtonName,
    VoidCallback? whenPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            modalTitle.capitalize(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: App.fontSecondary,
              fontWeight: FontWeight.normal
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextFormField.defaultInput(
                App.password,
                true,
                inputField!,
                keyboardType: TextInputType.text,
                inputTextColor: Colors.black,
                thisChild: const SizedBox(),
              ),
            ]
          ),
          actions: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Buttons.inkBtn(
                  onTap: whenPressed,
                  buttonText: submitButtonName ?? App.yes,
                  height: 10.h,
                  width: 35.w
                ),
                const SizedBox(width: 3),
                Buttons.inkBtn(
                  onTap: () => Routes.goBack(),
                  buttonText: App.cancel,
                  height: 10.h,
                  width: 35.w
                ),
              ],
            )
          ],
        );
      }
    );
  }

}