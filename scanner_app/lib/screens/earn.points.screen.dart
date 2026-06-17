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
import 'package:nustar_turnstile_scanner/utility/shared/modal.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:nustar_turnstile_scanner/utility/shared/text.field.dart';
import 'package:nustar_turnstile_scanner/utility/shared/math.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
import '../services/idle.manager.dart';
import 'home.screen.dart';

class EarnPointsScreen extends StatefulWidget {
  static String routeName = App.earnPointsScreen;
  final String? headerTitle;

  const EarnPointsScreen({
    Key? key,
    this.headerTitle
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EarnPointsScreenState createState() => _EarnPointsScreenState();
}

class _EarnPointsScreenState extends State<EarnPointsScreen> {

  final TextEditingController membershipIdField = TextEditingController();
  final TextEditingController invoiceNumberField = TextEditingController();
  final TextEditingController transactedAmountField = TextEditingController();
  final TextEditingController pinField = TextEditingController();

  String activeButtonName = App.confirm;
  String membershipIdValue = App.na;
  String invoiceNumberValue = App.na;
  String totalAmountValue = App.e;
  String secondaryConfirmation = '${App.confirm}2';

  bool printNow = false;
  bool isIdle = App.idleMode ? true : false;
  bool idleValidationSuccess = false;

  String? cardValue;

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
      child: WillPopScope(
        onWillPop: () {
          _clear();
          Routes.goBack(context);
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: CustomColors.darkThemeColor,
          appBar: AppBar(
            backgroundColor: CustomColors.darkThemeColor,
            title: const Hero(
              tag: App.defaultKey,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  App.earnPointsTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: App.fontSecondary,
                    fontWeight: FontWeight.bold
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
                  var membershipCardNumber = membershipIdField.text;
                  if (membershipCardNumber.isEmpty) {
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
                  Map<String, dynamic>? data = {
                    App.membershipIdPrm: membershipCardNumber
                  };
                  await earnPoints(
                    data: data,
                    requestName: App.getPlayerID,
                    membershipID: membershipCardNumber
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
                  => setState(() => activeButtonName = secondaryConfirmation),
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
                      "${App.transactedAmount}: $totalAmountValue",
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
                    transactedAmountValue: totalAmountValue,
                    whenPressed: () {
                      Routes.goBack();
                      Loader.show(context, 0);
                      Map<String, dynamic>? data = {
                        App.membershipIdPrm: App.memberCurrentPlayerID,
                        App.pin.toLowerCase(): pin,
                      };
                      earnPinValidation(param: data);
                    },
                  );
                },
              ),
            ],
          ) :
          activeButtonName == secondaryConfirmation ?
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
                      textField: transactedAmountField,
                      labelValue: App.transactedAmount,
                      hintValue: "${App.enter} ${App.transactedAmount}",
                      keyboardValue: TextInputType.number,
                      hasThousandOperator: true
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
                  var transactedAmount = transactedAmountField.text,
                      invoiceNumber = invoiceNumberField.text;
                  if (transactedAmount.isEmpty ||
                      invoiceNumber.isEmpty
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
                  setState(() {
                    invoiceNumberValue = invoiceNumber;
                    totalAmountValue = transactedAmount;
                    activeButtonName = App.pin;
                  });
                },
              ),
              const SizedBox(height: 30),
            ],
          )
          /* :
          activeButtonName == App.print ?
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
                    setState(() {
                      cardValue = membershipIdValue;
                      App.telpoServiceConnected = false;
                      App.magStripe = null;
                      t = null;
                      t?.cancel();
                    });
                    ThermalPrinter.telpoPrinting(
                      context: context,
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

  void postEarnPoints({
    required int tenantId,
    required String membershipId,
    required String transactionId,
    required double amount,
    required String cardTier,
  }) async {
    Map<String, dynamic>? earnPointsParam = {
      App.tenantIdPrm: tenantId,
      App.cardTierPrm: cardTier,
      App.membershipIdPrm: membershipId,
      App.transactionIdPrm: transactionId,
      App.amountPrm: amount,
      App.username: App.memberCurrentUsername,
      App.deviceIMEI: App.memberCurrentDeviceID
    };
    await earnPoints(
      data: earnPointsParam,
      requestName: App.earnPoints
    );
  }

  Future<void> earnPoints({
    Map<String, dynamic>? data,
    String? requestName,
    String? pinValue,
    String? membershipID
  }) async {
    var url = Uri.parse(
      (requestName == App.pinValidation) ? App.validatePinURI :
      (requestName == App.earnPoints) ? App.earnPointsURI :
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
    if (response.statusCode == 200) {
      final List<Points> points = [
        Points.fromJson(jsonDecode(response.body))
      ];
      String errorMessage = points[0].errorMessage ?? App.undefinedError;
      bool errorStatus = points[0].errorStatus ?? false;
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
            postEarnPoints(
              tenantId: App.memberCurrentTenantID,
              membershipId: App.memberCurrentPlayerID ?? App.e,
              transactionId: invoiceNumberValue,
              amount: Math.dp(double.parse(totalAmountValue.replaceAll(",", "")), 2),
              cardTier: App.cardTierValue ?? App.e
            );
            Loader.stop();
            return;
          }
          App.validateSuccess = false;
        } else if (requestName == App.getPlayerID) {
          App.memberCurrentPlayerID = points[0].playerId ?? App.e;
          App.cardTierValue = points[0].cardTier ?? App.na;
          App.cardHolderName = "${points[0].firstName ?? App.na} ${points[0].lastName ?? App.na}";
          membershipIdValue = points[0].playerId ?? membershipIdField.text;
          activeButtonName = secondaryConfirmation; //App.pin;
          Loader.stop();
          return;
        } else {
          App.memberCurrentMembershipID = points[0].membershipId ?? App.na;
          App.memberCurrentPoints = points[0].points ?? 0;
          App.memberCurrentUpdatedPoints = points[0].updatedPoints ?? 0;
          App.transactionInvoiceNumber = invoiceNumberValue;
          App.totalAmountValue = totalAmountValue;
          App.validateSuccess = true;
          activeButtonName = App.print;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            barrierDismissible: true,
            confirmBtnText: App.ok,
            title: App.e,
            text: App.successfullySaved,
            onConfirmBtnTap:() async {
              _clear();
              Routes.navigateToScreen(
                PrintingScreen(
                  headerTitle: widget.headerTitle
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
          activeButtonName = secondaryConfirmation;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      Loader.stop();
    }
  }

  earnPinValidation({
    required Map<String, dynamic> param
  }) async {
    await earnPoints(
      data: param,
      requestName: App.pinValidation
    );
    return;
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
      Map<String, dynamic>? data = {App.membershipIdPrm: cardValue};
      await earnPoints(
        data: data,
        requestName: App.getPlayerID,
        membershipID: cardValue
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
              await earnPoints(
                data: data,
                requestName: App.getPlayerID,
                membershipID: cardValue
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
    t?.cancel();
    App.t?.cancel();
    await App.callMethodChannel(App.stopMerchantMagStripeSwiping);
    isIdle = false;
    App.validateSuccess = false;
    App.isEarnPointsActive = false;
    App.cardHolderName = null;
    cardValue = null;
    membershipIdField.clear();
    invoiceNumberField.clear();
    transactedAmountField.clear();
    pinField.clear();
  }

  clearSwipeAndEnableMagstripe(context) async {
    Loader.show(context, 0);
    _clear();
    await Future.delayed(const Duration(seconds: 2));
    Loader.stop();
    Routes.navigateToScreen(const EarnPointsScreen(headerTitle: App.earnPointsTitle));
  }

  showWarningExpiredSession(BuildContext context) {
    if (isIdle && !idleValidationSuccess) {
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

  void _initializeIdleTimeChecker() {
    // if (App.idleMode) {
    //   if (_timer != null) {
    //     _timer?.cancel();
    //   }
    //   setState(() => App.isEarnPointsActive = true);
    //   _timer = Timer(Duration(seconds: App.idleIntervalDuration), _cancelIdleTimeChecker);
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

    if (App.isEarnPointsActive && !idleValidationSuccess) {
      showWarningExpiredSession(context);
      return;
    }
  }
  
  _resetAndStartIdleTimeChecker(BuildContext context) async {
    debugPrint('>>> EARN_POINTS --> _resetAndStartIdleTimeChecker');
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