import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:telpo_flutter_sdk/telpo_flutter_sdk.dart';

class ThermalPrinter {
  static final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  static final telpoFlutterChannel = TelpoFlutterChannel();

  static Future<void> wiseasyConnectToPrinter(
    BuildContext context
  ) async {
    List<BluetoothDevice> devices = [];
    devices = await printer.getBondedDevices();
    printer.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          log("printNow printer device state: connected");
        break;
        case BlueThermalPrinter.DISCONNECTED:
          log("printer device state: disconnected");
        break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          log("printer device state: disconnect requested");
        break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          log("printer device state: printer turning off");
        break;
        case BlueThermalPrinter.STATE_OFF:
          log("printer device state: printer off");
        break;
        case BlueThermalPrinter.STATE_ON:
          log("printer device state: printer on");
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          log("printer device state: printer turning on");
        break;
        case BlueThermalPrinter.ERROR:
          log("printer device state: error");
        break;
        default:
          log("printer state: $state");
        break;
      }
    });
    devices.forEach((device) {
      printer.connect(device);
    });
  }

  static Future<void> init(
    BuildContext context,
    bool printNow, {
    required String receiptTitle,
    String? membershipID,
    String? invoiceNumber,
    String? pointsEarned,
    String? updatedPoints,
    String? transactedAmount,
    String? pointsToRedeem,
    String? pointsBalance,
    String? cardTier
  }) async {
    wiseasyPrinting(
      context,
      printNow,
      receiptTitle,
      membershipID,
      invoiceNumber,
      pointsEarned,
      updatedPoints,
      transactedAmount,
      pointsToRedeem,
      pointsBalance,
      cardTier
    );
  }

  static void wiseasyPrinting(
    context,
    printNow,
    String receiptTitle,
    String? membershipId,
    String? transactionId,
    String? pointsEarned,
    String? updatedPoints,
    String? transactedAmount,
    String? pointsToRedeem,
    String? pointsBalance,
    String? cardTier
  ) async {
    /* PRINT FORMAT
      SIZE
      0- normal size text
      1- only bold text
      2- bold with medium text
      3- bold with large text
      ALIGN
      0- ESC_ALIGN_LEFT
      1- ESC_ALIGN_CENTER
      2- ESC_ALIGN_RIGHT
    */
    printer.isConnected.then((isConnected) async {
      if (isConnected ?? false) {
        printer.printNewLine();
        printer.printCustom(receiptTitle, 4, 1);
        printer.printNewLine();

        if (membershipId != null) {
          printer.printCustom("${App.membershipId}:", 2, 1);
          printer.printCustom(membershipId, 2, 1);
          printer.printNewLine();
        }

        if (transactionId != null) {
          printer.printCustom("${App.invoiceNumber}:", 2, 1);
          printer.printCustom(transactionId, 2, 1);
          printer.printNewLine();
        }

        if (pointsEarned != null) {
          printer.printCustom("${App.pointsEarned}:", 2, 1);
          printer.printCustom(pointsEarned, 2, 1);
          printer.printNewLine();
        }

        if (updatedPoints != null) {
          printer.printCustom("${App.updatedPtS}:", 2, 1);
          printer.printCustom(updatedPoints, 2, 1);
          printer.printNewLine();
        }

        if (transactedAmount != null) {
          printer.printCustom("${App.transactedAmount}:", 2, 1);
          printer.printCustom(transactedAmount, 2, 1);
          printer.printNewLine();
        }

        if (pointsToRedeem != null) {
          printer.printCustom("${App.pointsRedeemed}:", 2, 1);
          printer.printCustom(pointsToRedeem, 2, 1);
          printer.printNewLine();
        }

        if (pointsBalance != null) {
          printer.printCustom("${App.updatedPtS}:", 2, 1);
          printer.printCustom(pointsBalance, 2, 1);
          printer.printNewLine();
        }

        if (cardTier != null) {
          printer.printCustom("${App.cardTier}:", 2, 1);
          printer.printCustom(cardTier, 2, 1);
          printer.printNewLine();
        }

        printer.printNewLine();
        printer.printNewLine();
        printer.printNewLine();
        printer.printNewLine();

        printer.paperCut();

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.printSuccess
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          text: App.printFailed
        );
      }
    });
  }

  static Future<void> telpoCheckStatus(BuildContext context) async {
    final TelpoStatus status = await ThermalPrinter.telpoFlutterChannel.checkStatus();
    // ignore: use_build_context_synchronously
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      barrierDismissible: true,
      confirmBtnText: App.ok,
      title: App.info,
      text: status.name
    );
  }

  static Future<void> telpoPrinting({
    required BuildContext context,
    required String receiptTitle,
    String? membershipID,
    String? invoiceNumber,
    String? pointsEarned,
    String? updatedPoints,
    String? transactedAmount,
    String? pointsToRedeem,
    String? pointsBalance,
    String? cardTier,
    String? dateTime,
    String? compID,
    String? redeemedDescription,
    String? amount,
  }) async {
    final sheet = TelpoPrintSheet();
    final highSpacing = PrintData.space(line: 5);
    final lowerSpacing = PrintData.space(line: 2);
    final primaryHeaderTitle = PrintData.text(
      App.nustarNewTitle, //App.nustarResortCasino,
      alignment: PrintAlignment.center,
      fontSize: PrintedFontSize.size44
    );

    sheet.addElement(primaryHeaderTitle);
    sheet.addElement(highSpacing);

    if (App.memberCurrentTenantName != null) {
      printAddTextContent(sheet, "${App.merchant.capitalize()}:\n${App.memberCurrentTenantName}");
      sheet.addElement(lowerSpacing);
    }

    if (cardTier != null) {
      printAddTextContent(sheet, "${App.cardTier}:\n$cardTier");
      sheet.addElement(lowerSpacing);
    }

    if (membershipID != null) {
      printAddTextContent(sheet, "${App.playerId}:\n$membershipID");
      sheet.addElement(lowerSpacing);
    }

    if (invoiceNumber != null) {
      printAddTextContent(sheet, "${App.invoiceNumber}:\n$invoiceNumber");
      sheet.addElement(lowerSpacing);
    }

    if (pointsToRedeem != null) {
      printAddTextContent(sheet, "${App.pointsRedeemed}:\n$pointsToRedeem");
      sheet.addElement(lowerSpacing);
    }

    if (pointsEarned != null) {
      printAddTextContent(sheet, "${App.pointsEarned}:\n$pointsEarned");
      sheet.addElement(lowerSpacing);
    }

    if (compID != null) {
      printAddTextContent(sheet, "${App.compId}:\n$compID"); //redemptionNumber
      sheet.addElement(lowerSpacing);
    }

    if (redeemedDescription != null) {
      printAddTextContent(sheet, "${App.redeemedDescription}:\n$redeemedDescription");
      sheet.addElement(lowerSpacing);
    }

    if (amount != null) {
      printAddTextContent(sheet, "${App.amountPrm.capitalize()}:\n$amount");
      sheet.addElement(lowerSpacing);
    }
    
    if (dateTime != null && receiptTitle == App.pointsRedemption || receiptTitle == App.compsRedemption) {
      printAddTextContent(sheet, "${App.redemptionDateTime}:\n$dateTime");
      sheet.addElement(lowerSpacing);
    } else {
      printAddTextContent(sheet, "${App.earnDateTime}:\n$dateTime");
      sheet.addElement(lowerSpacing);
    }

    sheet.addElement(highSpacing);
    sheet.addElement(highSpacing);
    
    await ThermalPrinter.telpoFlutterChannel.print(sheet);

    // ignore: use_build_context_synchronously
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      barrierDismissible: true,
      confirmBtnText: App.ok,
      title: App.success,
      text: App.printSuccess
    );
  }

  static void printAddTextContent(
    TelpoPrintSheet sheet,
    String text
  ) {
    sheet.addElement(PrintData.text(
      text,
      alignment: PrintAlignment.left,
      fontSize: PrintedFontSize.size24
    ));
  }

}