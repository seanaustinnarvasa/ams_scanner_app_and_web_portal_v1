import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/screens/home.screen.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/buttons.dart';
import 'package:nustar_turnstile_scanner/utility/shared/print.receipt.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restart_app/restart_app.dart';

import '../services/idle.manager.dart';

class PrintingScreen extends StatefulWidget {
  static String routeName = App.printingScreen;
  final String? headerTitle;

  const PrintingScreen({
    Key? key,
    this.headerTitle
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PrintingScreenState createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {
  
  Timer? _timer;
  bool isIdle = false;
  bool idleValidationSuccess = false;

  @override
  void initState() {
    // App.checkIdle(context);
    _initializeIdleTimeChecker();
    super.initState();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  _clear() {
    setState(() {
    App.t?.cancel();
      _timer?.cancel();
      _timer = null;
      isIdle = false;
      idleValidationSuccess = true;
      App.isIdle = true;
      App.isHomeActive = false;
      App.isBalanceInquiryActive = false;
      App.isPointsRedemptionActive = false;
      App.isEarnPointsActive = false;
      App.isCompRedemptionActive = false;
    });
  }

  _initializeIdleTimeChecker() {
    // debugPrint('>>> PRINT_SCREEN --> _initializeIdleTimeChecker --> App.idleMode: ${App.idleMode}');
    // debugPrint('>>> PRINT_SCREEN --> _initializeIdleTimeChecker --> isIdle: $isIdle');
    // debugPrint('>>> PRINT_SCREEN --> _initializeIdleTimeChecker --> idleValidationSuccess: $idleValidationSuccess');
    // debugPrint('>>> PRINT_SCREEN --> _initializeIdleTimeChecker --> App.isCompRedemptionActive: ${App.isCompRedemptionActive}');

    if (App.idleMode) {
      if (_timer != null) {
        _timer?.cancel();
      }
      setState(() => App.isCompRedemptionActive = true);
      _timer = Timer(Duration(seconds: App.idleIntervalDuration), _cancelIdleTimeChecker);
    }
  }

  _cancelIdleTimeChecker() {
    setState(() {
      _timer?.cancel();
      _timer = null;
    });

    // setState(() => isIdle = true);
    // debugPrint('>>> PRINT_SCREEN --> _cancelIdleTimeChecker');

    showWarningExpiredSession(context);

    return;
  }

  showWarningExpiredSession(BuildContext context) {
    // if (isIdle && !idleValidationSuccess) {
    if (!idleValidationSuccess) {
      setState(() {
        isIdle = false;
        idleValidationSuccess = true;
        App.isHomeActive = false;
        App.isBalanceInquiryActive = false;
        App.isPointsRedemptionActive = false;
        App.isEarnPointsActive = false;
        App.isCompRedemptionActive = false;
      });
      QuickAlert.show(
        onConfirmBtnTap: () => Restart.restartApp(),
        type: QuickAlertType.info,
        barrierDismissible: false,
        confirmBtnText: App.ok,
        text: "User Session expired, \nPlease Login again to continue.",
        title: App.warning,
        context: context
      );
      return;
    }
  }
  
  _resetAndStartIdleTimeChecker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    
    setState(() {
      _timer?.cancel();
      _timer = null;
      // App.isCompRedemptionActive = true;
      idleValidationSuccess = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    _initializeIdleTimeChecker();
  }

  @override
  Widget build(BuildContext context) {
    final idleManager = Provider.of<IdleManager>(context);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          Routes.navigateToScreen(const Home());
          return Future.value(false);
        },
        child: GestureDetector(
          onTap: () => idleManager.resetTimer(() => idleManager.showIdle(context), context),
          onPanDown: (_) => idleManager.resetTimer(() => idleManager.showIdle(context), context),
          onScaleStart: (_) => idleManager.resetTimer(() => idleManager.showIdle(context), context),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (_) => idleManager.resetTimer(() => idleManager.showIdle(context), context),
            child: Scaffold(
          backgroundColor: CustomColors.darkThemeColor,
          appBar: AppBar(
            backgroundColor: CustomColors.darkThemeColor,
            title: Hero(
              tag: App.defaultKey,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.headerTitle ?? App.na,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: App.fontSecondary,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            leading: InkWell(
              onTap: () {
                // App.checkIdle(context);
                // setState(() => App.isIdle = true);
                Routes.navigateToScreen(const Home());
                // Routes.goBack();
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          // body: SingleChildScrollView(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanDown: (_) => _resetAndStartIdleTimeChecker(context),
            onTap: () => _resetAndStartIdleTimeChecker(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.zero,
                    width: 100.w,
                    height: 50.h,
                    child: Stack(
                      children: <Widget>[
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                              Rect.fromLTRB(
                                0,
                                0,
                                rect.width,
                                rect.height
                              )
                            );
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            App.nustarResort,
                            height: 100.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 100),
                        App.breakpoint < MediaQuery.of(context).size.width ? Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: App.paneProportion,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      App.nustar,
                                      style: TextStyle(
                                        fontSize: 75,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: App.fontPrimary,
                                        color: Colors.grey.withOpacity(0.6),
                                        letterSpacing: 10
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ) : 
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 30,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      App.nustar,
                                      style: TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: App.fontPrimary,
                                        color: Colors.grey.withOpacity(0.6),
                                        letterSpacing: 10
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Flexible(
                              flex: 90,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        App.merchant,
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontFamily: App.fontPrimary,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 5
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  //EARN POINTS
                  widget.headerTitle == App.earnPointsTitle ?
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 100.w,
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            Expanded(
                              flex: 2,
                              child: earnDetailsCard(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Buttons.themeButton(
                        context: context,
                        buttonName: App.print,
                        height: 10.h,
                        width: 55.w,
                        onTap: () async {
                          /* //WISEASY PRINT
                            ThermalPrinter.init(
                              context,
                              true,
                              receiptTitle: App.earnPoints,
                              membershipID: membershipIdValue,
                              invoiceNumber: invoiceNumberValue,
                              updatedPoints:
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentUpdatedPoints
                                ),
                              pointsEarned:
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentPoints
                                ),
                              transactedAmount: totalAmountValue,
                              cardTier: App.cardTierValue
                            ); 
                          */
                          if (App.telpoServiceConnected) {
                            ThermalPrinter.telpoPrinting(
                              context: context,
                              receiptTitle: App.earnPoints,
                              membershipID: App.memberCurrentMembershipID,
                              invoiceNumber: App.transactionInvoiceNumber,
                              updatedPoints:
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentUpdatedPoints
                                ),
                              pointsEarned:
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentPoints
                                ),
                              transactedAmount: App.totalAmountValue,
                              cardTier: App.cardTierValue,
                              dateTime: App.currentDateAndTime()
                            );
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              barrierDismissible: true,
                              confirmBtnText: App.ok,
                              title: App.e,
                              text: App.telpoNotFound
                            );
                          }
                        },
                      ),
                    ],
                  ) : widget.headerTitle == App.pointsRedemptionTitle ?
                  //POINTS REDEMPTION
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(
                        width: 100.w,
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            Expanded(
                              flex: 2,
                              child: redeemDetailsCard(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Buttons.themeButton(
                        context: context,
                        buttonName: App.print,
                        height: 10.h,
                        width: 55.w,
                        onTap: () async {
                          /* //WISEASY PRINT
                            ThermalPrinter.init(
                              context,
                              true,
                              receiptTitle: App.pointsRedemption,
                              membershipID: membershipIdValue,
                              transactionID: invoiceNumberValue,
                              pointsToRedeem: 
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentPoints
                                ),
                              pointsBalance: 
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentUpdatedPoints
                                ),
                              cardTier: App.cardTierValue
                            );
                          */
                          if (App.telpoServiceConnected) {
                            ThermalPrinter.telpoPrinting(
                              context: context,
                              receiptTitle: App.pointsRedemption,
                              membershipID: App.memberCurrentMembershipID,
                              invoiceNumber: App.transactionInvoiceNumber,
                              pointsToRedeem: 
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentPoints
                                ),
                              pointsBalance: 
                                NumberFormat.decimalPattern().format(
                                  App.memberCurrentUpdatedPoints
                                ),
                              // transactedAmount: totalAmountValue,
                              cardTier: App.cardTierValue,
                              dateTime: App.currentDateAndTime()
                            );
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              barrierDismissible: true,
                              confirmBtnText: App.ok,
                              title: App.e,
                              text: App.telpoNotFound
                            );
                          }
                        },
                      ),
                    ],
                  ) : 
                  //COMP REDEMPTION
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(
                        // height: 60.h,
                        width: 100.w,
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            Expanded(
                              flex: 2,
                              child: compRedeemDetailsCard(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Buttons.themeButton(
                        context: context,
                        buttonName: App.print,
                        height: 10.h,
                        width: 55.w,
                        onTap: () async {
                          if (App.telpoServiceConnected) {
                            ThermalPrinter.telpoPrinting(
                              context: context,
                              receiptTitle: App.compsRedemption,
                              membershipID: App.memberCurrentPlayerID ?? App.na,
                              compID: App.compRedemptionNumberValue ?? App.na,
                              // redeemedDescription: App.redeemedDescriptionValue ?? App.na,
                              // amount: "${App.amountValue ?? 0}",
                              dateTime: App.currentDateAndTime()
                            );
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              barrierDismissible: true,
                              confirmBtnText: App.ok,
                              title: App.e,
                              text: App.telpoNotFound
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }

  Card earnDetailsCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Container(
        margin: EdgeInsets.zero,
        height: 80.h,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 30
        ),
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          App.nustarNewTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontPrimary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.merchant.capitalize()}:",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentTenantName ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.cardTier}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      App.cardTierValue ?? App.na,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: App.fontSecondary,
                        fontSize: 20
                      ),
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.playerId}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentMembershipID,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.invoiceNumber}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.transactionInvoiceNumber ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.pointsEarned}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat.decimalPattern().format(
                            App.memberCurrentPoints
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.earnDateTime}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.currentDateAndTime(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }

  Card redeemDetailsCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Container(
        margin: EdgeInsets.zero,
        height: 80.h,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 30
        ),
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          App.nustarNewTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontFamily: App.fontPrimary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.merchant.capitalize()}:",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentTenantName ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.cardTier}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      App.cardTierValue ?? App.na,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: App.fontSecondary,
                        fontSize: 20
                      ),
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.playerId}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentMembershipID,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.invoiceNumber}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.transactionInvoiceNumber ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.pointsRedeemed}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat.decimalPattern().format(
                            App.memberCurrentPoints
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.redemptionDateTime}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.currentDateAndTime(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }

  Card compRedeemDetailsCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Container(
        margin: EdgeInsets.zero,
        height: 100.h,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 30
        ),
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          App.nustarNewTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontFamily: App.fontPrimary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.merchant.capitalize()}:",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentTenantName ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.playerId}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.memberCurrentPlayerID ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.compId}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.compRedemptionNumberValue ?? App.na,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            // const SizedBox(height: 15),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Column(
            //       children: [
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               "${App.redeemedDescription}:",
            //               style: TextStyle(
            //                 color: Colors.black,
            //                 fontSize: 20,
            //                 fontFamily: App.fontSecondary,
            //                 fontWeight: FontWeight.bold
            //               ),
            //             ),
            //           ]
            //         ),
            //       ]
            //     ),
            //   ]
            // ),
            // Container(
            //   width: Sizes.displayWidth(context),
            //   child: Text(
            //     App.redeemedDescriptionValue ?? App.na,
            //     style: const TextStyle(
            //       color: Colors.black,
            //       fontFamily: App.fontSecondary,
            //       fontSize: 20
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 15),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Column(
            //       children: [
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               "${App.amountPrm}:".capitalize(),
            //               style: const TextStyle(
            //                 color: Colors.black,
            //                 fontSize: 20,
            //                 fontFamily: App.fontSecondary,
            //                 fontWeight: FontWeight.bold
            //               ),
            //             ),
            //           ]
            //         ),
            //       ]
            //     ),
            //   ]
            // ),
            // Container(
            //   width: Sizes.displayWidth(context),
            //   child: Text(
            //     "${App.amountValue ?? 0}",
            //     style: const TextStyle(
            //       color: Colors.black,
            //       fontFamily: App.fontSecondary,
            //       fontSize: 20
            //     ),
            //   ),
            // ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.redemptionDateTime}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: App.fontSecondary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          App.currentDateAndTime(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: App.fontSecondary,
                            fontSize: 20
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }
  
}