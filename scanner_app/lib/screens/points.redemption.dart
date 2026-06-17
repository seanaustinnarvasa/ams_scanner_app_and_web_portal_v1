import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/data/models/points.dart';
import 'package:nustar_turnstile_scanner/screens/printing.screen.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/buttons.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/math.dart';
import 'package:nustar_turnstile_scanner/utility/shared/modal.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:nustar_turnstile_scanner/utility/shared/text.field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
import '../services/idle.manager.dart';
import 'home.screen.dart';

class PointsRedemptionScreen extends StatefulWidget {
  static String routeName = App.pointsRedemptionScreen;
  final String? headerTitle;

  const PointsRedemptionScreen({
    Key? key,
    this.headerTitle
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PointsRedemptionScreenState createState() => _PointsRedemptionScreenState();
}

class _PointsRedemptionScreenState extends State<PointsRedemptionScreen> {

  final TextEditingController membershipIdField = TextEditingController();
  final TextEditingController pinField = TextEditingController();
  final TextEditingController pointsToRedeemField = TextEditingController();
  final TextEditingController invoiceNumberField = TextEditingController();
  
  String activeButtonName = App.confirm;
  String membershipIdValue = App.na;
  String invoiceNumberValue = App.na;
  String pointsToRedeemValue = App.e;
  String? cardValue;

  bool isIdle = App.idleMode ? true : false;
  bool idleValidationSuccess = false;

  Timer? t;
  Timer? _timer;

  @override
  void initState() {
    initCardReader();
    _initializeIdleTimeChecker();
    super.initState();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idleManager = Provider.of<IdleManager>(context);
    
    final checkIdle
      = App.idleMode ? idleManager.resetTimer(() => idleManager.showIdle(context), context) : null;

    return SafeArea(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          leading: InkWell(
            onTap: () => Routes.replaceScreen(const Home()),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        // body: GestureDetector(
        //   behavior: HitTestBehavior.translucent,
        //   onPanDown: (_) => _resetAndStartIdleTimeChecker(context),
        //   onTap: () => _resetAndStartIdleTimeChecker(context),
        //   child: bodyWidget(context),
        // ),
        body: GestureDetector(
          onTap: () => checkIdle,
          onPanDown: (_) => checkIdle,
          onScaleStart: (_) => checkIdle,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (_) => checkIdle,
            child: bodyWidget(context),
      ),
      ),
      ),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return SingleChildScrollView(
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
          activeButtonName == App.confirm ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  // horizontal: 25,
                  vertical: 25
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget> [
                    AppTextFormField.defaultInput(
                      onTapKb: () => FocusManager.instance.primaryFocus?.unfocus(),
                      keyboardType: TextInputType.number,
                      thisChild: const SizedBox(),
                      readOnly: true,
                      App.swipeCard,
                      false,
                      membershipIdField,
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 5),
              /*
              Buttons.themeButton(
                context: context,
                buttonName: App.submit,
                height: 10.h,
                width: 55.w,
                onTap: () async {
                  /*
                    ThermalPrinter.telpoPrinting(
                      context: context,
                      receiptTitle: App.pointsRedemption,
                      membershipID: membershipIdValue,
                      invoiceNumber: invoiceNumberValue,
                      pointsToRedeem: 
                        NumberFormat.decimalPattern().format(
                          App.memberCurrentPoints
                        ),
                      pointsBalance: 
                        NumberFormat.decimalPattern().format(
                          App.memberCurrentUpdatedPoints
                        ),
                      // transactedAmount: totalAmountValue,
                      cardTier: App.cardTierValue ?? App.na,
                      dateTime: App.currentDateAndTime()
                    );
                  */
                  AppTextFormField.hideKeyboard();
                  var balanceInquiry = membershipIdField.text;
                  if (balanceInquiry.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      barrierDismissible: true,
                      confirmBtnText: App.ok,
                      title: App.e,
                      text: App.requiredField
                    );
                    return;
                  }
                  Loader.show(context, 0);
                  Map<String, dynamic>? data = {App.membershipIdPrm: balanceInquiry};
                  await redeemPoints(
                    data: data,
                    requestName: App.getPlayerID
                  );
                },
              ),
              */
            ],
          ) :
          activeButtonName == App.pin ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Buttons.smallPreviousBtn(
                onTap: ()
                  => setState(() => activeButtonName = App.pointsToRedeem),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 25
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Text(
                      "${App.playerId}: ${App.memberCurrentPlayerID}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${App.nameKey.capitalize()}: ${App.cardHolderName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${App.invoiceNumber}: $invoiceNumberValue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${App.pointsToRedeem}: $pointsToRedeemValue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextFormField.textInputFormField(
                      textField: pinField,
                      labelValue: App.pin,
                      hintValue: "${App.enter} ${App.pin}",
                      keyboardValue: TextInputType.number,
                      fieldMask: true
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 25),
              Buttons.themeButton(
                context: context,
                buttonName: App.confirm,
                height: 10.h,
                width: 55.w,
                onTap: () async {
                  AppTextFormField.hideKeyboard();
                  var pin = pinField.text;
                  if (pin.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      barrierDismissible: true,
                      confirmBtnText: App.ok,
                      title: App.e,
                      text: App.requiredField
                    );
                    return;
                  }
                  Modal.textInputDialog(
                    context,
                    messageValue: App.plsConfirm,
                    membershipID: membershipIdValue,
                    transactionID: invoiceNumberValue,
                    pointsToRedeemValue: pointsToRedeemValue,
                    whenPressed: () {
                      Routes.goBack();
                      Loader.show(context, 0);
                      Map<String, dynamic>? data = {
                        App.membershipIdPrm: App.memberCurrentPlayerID,
                        App.pin.toLowerCase(): pinField.text,
                      };
                      pointsPinValidation(param: data);
                    },
                  );
                },
              ),
            ],
          ) :
          activeButtonName == App.pointsToRedeem ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Buttons.smallPreviousBtn(onTap: () {
                setState(() {
                  activeButtonName = App.confirm;
                  membershipIdField.text = App.e;
                });
                clearSwipeAndEnableMagstripe(context);
              }),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 25
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    Text(
                      "${App.playerId}: ${App.memberCurrentPlayerID}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${App.nameKey.capitalize()}: ${App.cardHolderName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: App.fontSecondary,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextFormField.textInputFormField(
                      textField: invoiceNumberField,
                      labelValue: App.invoiceNumber,
                      hintValue: "${App.enter} ${App.invoiceNumber}",
                      keyboardValue: TextInputType.text
                    ),
                    const SizedBox(height: 15),
                    AppTextFormField.textInputFormField(
                      textField: pointsToRedeemField,
                      labelValue: App.pointsToRedeem,
                      hintValue: "${App.enter} ${App.pointsToRedeem}",
                      keyboardValue: TextInputType.number,
                      hasThousandOperator: true
                    )
                  ]
                ),
              ),
              const SizedBox(height: 25),
              Buttons.themeButton(
                context: context,
                buttonName: App.confirm,
                height: 10.h,
                width: 55.w,
                onTap: () {
                  var pointsToRedeem = pointsToRedeemField.text;
                  var invoiceNumber = invoiceNumberField.text;
                  if (pointsToRedeem.isEmpty || invoiceNumber.isEmpty
                  ) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      barrierDismissible: true,
                      confirmBtnText: App.ok,
                      title: App.e,
                      text: App.requiredField
                    );
                    return;
                  }
                  AppTextFormField.hideKeyboard();
                  setState(() {
                    pointsToRedeemValue = pointsToRedeem;
                    invoiceNumberValue = invoiceNumber;
                    activeButtonName = App.pin;
                  });
                },
              ),
              const SizedBox(height: 30),
            ],
          ) /* :
          activeButtonName == App.print ?
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
                      child: detailsCard(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Buttons.themeButton(
                context: context,
                buttonName: activeButtonName,
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
                      membershipID: membershipIdValue,
                      invoiceNumber: invoiceNumberValue,
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
          )
          */
          : const SizedBox(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Card detailsCard() {
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
                          App.nustarResortCasino,
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
                          membershipIdValue,
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
                          invoiceNumberValue,
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

  void postRedeemPoints({
    required int tenantId,
    required String membershipId,
    required double amount,
    required double pointsToRedeem,
    required int userId
  }) async {
    Map<String, dynamic>? redeemParam = {
      App.tenantIdPrm: tenantId,
      App.membershipIdPrm: membershipId,
      App.transactionIdPrm: invoiceNumberValue,
      App.amountPrm: amount,
      App.pointsToRedeemPrm: pointsToRedeem,
      App.username: App.memberCurrentUsername,
      App.deviceIMEI: App.memberCurrentDeviceID
    };
    await redeemPoints(
      data: redeemParam,
      membershipID: membershipId,
      requestName: App.pointsToRedeem
    );
  }

  Future<void> redeemPoints({
    Map<String, dynamic>? data,
    String? requestName,
    String? pinValue,
    String? membershipID
  }) async {
    var url = Uri.parse(
      (requestName == App.pinValidation) ? App.validatePinURI : 
      (requestName == App.pointsToRedeem) ? App.pointsRedemptionURI :
      App.getPlayerIdURI
    );
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    var response = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    // ignore: use_build_context_synchronously
    final token = await App.getTokenKey(context);
    final List<Points> points = [
      Points.fromJson(jsonDecode(response.body))
    ];
    String errorMessage = points[0].errorMessage ?? App.undefinedError;
    bool errorStatus = points[0].errorStatus ?? false;
    if (response.statusCode == 200) {
      DatabaseService.insertLogs(
        id: "${App.generateDateTimeSeconds()}${App.requestKey}",
        tenantId: App.memberCurrentTenantID.toString(),
        membershipId: membershipID ?? App.na,
        deviceId: App.memberCurrentDeviceID ?? App.na,
        jsonRequest: json.encode(data),
        jsonResponse: jsonDecode(response.body).toString(),
        endpoint: url.toString(),
        appVersion: App.versionNumber,
        username: App.memberCurrentUsername,
        hasError: errorStatus
      );
      if (errorMessage.contains(App.connectionAttemptFailed) || 
          errorMessage.contains(App.tn)
      ) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: App.serverErrorMsg
        );
        Loader.stop();
        return;
      }
      if (errorMessage == App.invalidPIN ||
          errorMessage == App.invalidInvoiceNumber
      ) {
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: "Message: $errorMessage\nMerchant Name: ${App.memberCurrentTenantName}\nInvoice Number: $invoiceNumberValue",
        );
        Loader.stop();
        return;
      }
      if (errorStatus) {
        Loader.stop();
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          onConfirmBtnTap: () {
            Routes.goBack();
            clearSwipeAndEnableMagstripe(context);
          },
          context: context,
          type: QuickAlertType.error,
          barrierDismissible: true,
          confirmBtnText: App.ok,
          title: App.e,
          text: errorMessage
        );
        return;
      }
      setState(() {
        if (requestName == App.pinValidation) {
          if (points[0].pinCorrect ?? false) {
            pinField.text = App.e;
            postRedeemPoints(
              tenantId: App.memberCurrentTenantID,
              membershipId: App.memberCurrentPlayerID ?? App.na,
              amount: 0, //Math.dp(double.parse(totalAmountValue.replaceAll(",", "")), 2),
              pointsToRedeem: Math.dp(double.parse(pointsToRedeemValue.replaceAll(",", "")), 2),
              userId: App.memberDefaultUserId
            );
            Loader.stop();
            return;
          }
          App.validateSuccess = false;
        } else if (requestName == App.getPlayerID) {
          App.memberCurrentPlayerID = points[0].playerId ?? App.e;
          App.cardTierValue = points[0].cardTier ?? App.na;
          App.cardHolderName = "${points[0].firstName ?? App.na} ${points[0].lastName ?? App.na}";
          activeButtonName = App.pointsToRedeem;
          membershipIdValue = points[0].playerId ?? membershipIdField.text;
          Loader.stop();
          return;
        } else {
          App.memberCurrentMembershipID = points[0].membershipId ?? App.na;
          App.memberCurrentPoints = points[0].points ?? 0;
          App.memberCurrentUpdatedPoints = points[0].updatedPoints ?? 0;
          App.transactionInvoiceNumber = invoiceNumberValue;
          App.validateSuccess = true;
          activeButtonName = App.print;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            barrierDismissible: false,
            confirmBtnText: App.ok,
            title: App.e,
            text: App.successfullySaved,
            onConfirmBtnTap:() async {
              _clear();
              Routes.navigateToScreen(
                PrintingScreen(
                  headerTitle: widget.headerTitle ?? App.na
                )
              );
            },
          );
          Loader.stop();
          return;
        }
      });
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          activeButtonName = App.pointsToRedeem;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      Loader.stop();
    }
    // Loader.stop();
  }

  pointsPinValidation({
    required Map<String, dynamic> param
  }) async {
    await redeemPoints(
      data: param,
      requestName: App.pinValidation
    );
  }
  
  initCardReader() async {
    setState(() {
      App.telpoServiceConnected = true;
      membershipIdField.text = App.e;
    });
    /*
    setState(() => cardValue = "12345665000228994355"); //"12345665000225652188");
    if (cardValue != null) {
      Loader.show(context, 0);
      Map<String, dynamic>? data = {
        App.membershipIdPrm: cardValue
      };
      await redeemPoints(
        data: data,
        requestName: App.getPlayerID
      );
      return;
    }
    */
    if (cardValue == null && App.telpoServiceConnected) {
      t = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        try {
          final magStripe = await App.callMethodChannel(App.merchantSwipeMagStripeCard);
          // ignore: unrelated_type_equality_checks
          if (magStripe != null && magStripe != App.e) {
            if (!mounted) return;
            setState(() => cardValue = magStripe);
            if (cardValue != null) {
              Loader.show(context, 0);
              // Map<String, dynamic>? data = {
              //   App.membershipIdPrm: "12345665000228994355"
              // };
              Map<String, dynamic>? data = {
                App.membershipIdPrm: cardValue
              };
              await redeemPoints(
                data: data,
                requestName: App.getPlayerID
              );
              t.cancel();
              return;
            }
          }
        } on PlatformException catch (e) {
          log("Failed to Invoke: '${e.message}'.");
        }
      });
    }
  }

  _clear() async {
    App.t?.cancel();
    t?.cancel();
    await App.callMethodChannel(App.stopMerchantMagStripeSwiping);
    isIdle = false;
    App.validateSuccess = false;
    App.clearStripe = false;
    App.cardHolderName = null;
    cardValue = null;
    membershipIdField.clear();
    invoiceNumberField.clear();
    pointsToRedeemField.clear();
    pinField.clear();
  }

  clearSwipeAndEnableMagstripe(context) async {
    Loader.show(context, 0);
    _clear();
    await Future.delayed(const Duration(seconds: 2));
    Loader.stop();
    Routes.navigateToScreen(const PointsRedemptionScreen(headerTitle: App.pointsRedemptionTitle));
  }

  showWarningExpiredSession(BuildContext context) {
    log('>>> POINTS_REDEMPTION showWarningExpiredSession');
    if (isIdle && !idleValidationSuccess) {
      log('>>> POINTS_REDEMPTION showWarningExpiredSession TRUE');
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
        onConfirmBtnTap: () {
          Restart.restartApp();
        },
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

  void _initializeIdleTimeChecker() {
    // if (App.idleMode) {
    //   if (_timer != null) {
    //     _timer?.cancel();
    //   }
    //   setState(() => App.isPointsRedemptionActive = true);
    //   _timer = Timer(Duration(seconds: App.idleIntervalDuration), _cancelIdleTimeChecker);
    //   log('>>> POINTS_REDEMPTION _initializeIdleTimeChecker');
    // }
    
    if (App.idleMode) {
      final session = IdleManager();
      session.startSessionTimer(() {
        session.showIdle(context);
      }, context);
    }
  }

  void _cancelIdleTimeChecker() {
    setState(() {
      _timer?.cancel();
      _timer = null;
    });

    // setState(() => isIdle = true);

    log('>>> POINTS_REDEMPTION _cancelIdleTimeChecker');

    if (App.isPointsRedemptionActive && !idleValidationSuccess) {
      showWarningExpiredSession(context);
      return;
    }
  }
  
  _resetAndStartIdleTimeChecker(BuildContext context) async {
    debugPrint('>>> POINTS_REDEMPTION --> _resetAndStartIdleTimeChecker');
    // Navigator.pop(context);

    FocusScope.of(context).unfocus();

    Loader.stop();
    
    setState(() {
      _timer?.cancel();
      _timer = null;
      App.isBalanceInquiryActive = true;
      idleValidationSuccess = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    _initializeIdleTimeChecker();
  }
  
}