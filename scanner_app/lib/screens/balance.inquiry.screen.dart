import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/data/models/points.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/buttons.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:nustar_turnstile_scanner/utility/shared/text.field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
// import 'package:user_inactivity_detector/user_inactivity_detector.dart';

import '../services/idle.manager.dart';
import 'home.screen.dart';

class BalanceInquiry extends StatefulWidget {
  static String routeName = App.balanceInquiryScreen;
  final String? headerTitle;

  const BalanceInquiry({
    Key? key,
    this.headerTitle
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BalanceInquiryState createState() => _BalanceInquiryState();
}

class _BalanceInquiryState extends State<BalanceInquiry> {

  final TextEditingController membershipIdField = TextEditingController();
  final TextEditingController pinField = TextEditingController();

  String activeButtonName = App.checkBalance;
  String membershipIdValue = App.na;
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
      child: GestureDetector(
        onTap: () => checkIdle,
        onPanDown: (_) => checkIdle,
        onScaleStart: (_) => checkIdle,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (_) => checkIdle,
          child:  Scaffold(
        backgroundColor: CustomColors.darkThemeColor,
        appBar: AppBar(
          backgroundColor: CustomColors.darkThemeColor,
          title: const Hero(
            tag: App.defaultKey,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                App.balanceInquiryTitle,
                style: TextStyle(
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
        // body: SingleChildScrollView(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: (_) => _resetAndStartIdleTimeChecker(context),
          onTap: () => _resetAndStartIdleTimeChecker(context),
          child: bodyWidget(context)
        )
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
          activeButtonName == App.checkBalance ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
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
              /*
              const SizedBox(height: 5),
              Buttons.themeButton(
                context: context,
                buttonName: activeButtonName,
                height: 10.h,
                width: 65.w,
                onTap: () async {
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
                  Map<String, dynamic>? data = {
                    App.membershipIdPrm: balanceInquiry
                  };
                  await balanceInquiryReq(
                    data: data,
                    requestName: App.getPlayerID,
                    membershipID: cardValue,
                    context: context
                  );
                },
              ),
              */
            ],
          ) :
          activeButtonName == App.confirm ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Buttons.smallPreviousBtn(onTap: () => clearSwipeAndEnableMagstripe(context)),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 25,
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
                        "${App.cardTier.capitalize()}: ${App.cardTierValue}",
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
                      )
                      /*
                      if (App.isTenantValetService) Column(
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            "${App.cardTier.capitalize()}: ${App.cardTierValue}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: App.fontSecondary,
                              fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ) else Column(
                        children: [
                          const SizedBox(height: 18),
                          AppTextFormField.textInputFormField(
                            textField: pinField,
                            labelValue: App.pin,
                            hintValue: "${App.enter} ${App.pin}",
                            keyboardValue: TextInputType.number,
                            fieldMask: true
                          )
                        ],
                      )
                      */
                    ]
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Buttons.themeButton(
                    context: context,
                    buttonName: App.submit,
                    height: 10.h,
                    width: 55.w,
                    onTap: () async {
                      AppTextFormField.hideKeyboard();
                      // _initializeIdleTimeChecker();
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
                      Loader.show(context, 0);
                      Map<String, dynamic>? data = {
                        App.membershipIdPrm: App.memberCurrentPlayerID,
                        App.pin.toLowerCase(): pin
                      };
                      debugPrint("PIN data ->$data");
                      initBalanceInquiry(
                        pin: pin,
                        param: data,
                        context: context
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                /*
                if (!App.isTenantValetService) Column(
                  children: [
                    Center(
                      child: Buttons.themeButton(
                        context: context,
                        buttonName: App.submit,
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
                          Loader.show(context, 0);
                          Map<String, dynamic>? data = {
                            App.membershipIdPrm: App.memberCurrentPlayerID, //membershipIdValue,
                            App.pin.toLowerCase(): pin
                          };
                          initBalanceInquiry(
                            pin: pin,
                            param: data,
                            context: context
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                )
                */
              ],
            ) : activeButtonName == App.backHome ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 100.w,
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
                const SizedBox(height: 15),
                Buttons.themeButton(
                  context: context,
                  buttonName: activeButtonName,
                  height: 10.h,
                  width: 60.w,
                  onTap: () => Routes.replaceScreen(const Home()),
                ),
                const SizedBox(height: 20),
              ],
            ) :
            const SizedBox(),
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
        height: 35.h,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20
        ),
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      App.memberCurrentPlayerID ?? App.na,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${App.points}:",
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      NumberFormat.decimalPattern().format(
                        App.memberCurrentBalance
                      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ]
        ),
      ),
    );
  }

  initBalanceInquiry({
    required String pin,
    required Map<String, dynamic> param,
    required BuildContext context
  }) async {
    await balanceInquiryReq(
      data: param,
      requestName: App.pinValidation,
      pinValue: pin,
      context: context
    );
  }

  Future<void> balanceInquiryReq({
    Map<String, dynamic>? data,
    String? requestName,
    String? pinValue,
    String? membershipID,
    required BuildContext context
  }) async {
    var url = Uri.parse(
      (requestName == App.getBalance) ? App.getBalanceByIdURI :
      (requestName == App.pinValidation) ? App.validatePinURI : 
      App.getPlayerIdURI
    );
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    debugPrint("balanceInquiryReq requestName ->$requestName");
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
        // _initializeIdleTimeChecker();
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
      if (errorStatus) {
        Loader.stop();
        // ignore: use_build_context_synchronously
        QuickAlert.show(
          onConfirmBtnTap: () {
            Routes.goBack();
            setState(() => _clear());
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
      // resetTimerAndStartAgain();
      setState(() {
        if (requestName == App.pinValidation) {
          if (points[0].pinCorrect ?? false) {
            // activeButtonName = App.backHome;
            Map<String, dynamic>? data = {
              App.membershipIdPrm: App.memberCurrentPlayerID
            };
            balanceInquiryReq(
              requestName: App.getBalance,
              context: context,
              data: data
            );
            // _initializeIdleTimeChecker();
            Loader.stop();
            return;
          } else {
            App.validateSuccess = false;
            Loader.stop();
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
              text: 'Incorrect PIN. Please try again'
            );
          }
        } else if (requestName == App.getPlayerID || App.isTenantValetService) {
          if (points[0].cardTier != null) {
            App.cardTierValue = points[0].cardTier ?? App.na;
          }
          App.memberCurrentPlayerID = points[0].playerId ?? App.e;
          App.cardHolderName = "${points[0].firstName ?? App.na} ${points[0].lastName ?? App.na}";
          membershipIdValue = membershipIdField.text;
          activeButtonName = App.confirm;
          // _initializeIdleTimeChecker();
          Loader.stop();
        }
        if (requestName == App.getBalance) {
          activeButtonName = App.backHome;
          App.memberCurrentMembershipID = points[0].membershipId ?? App.na;
          App.memberCurrentPlayerID = points[0].membershipId ?? App.na;
          App.memberCurrentBalance = points[0].rewardsBalance ?? 0;
          // _initializeIdleTimeChecker();
          Loader.stop();
        }
      });
    } else {
      if (App.k3y != null) {
        setState(() {
          App.k3y = token;
          activeButtonName = App.confirm;
        });
      } else {
        // ignore: use_build_context_synchronously
        Loader.show(context, 0);
      }
      // _initializeIdleTimeChecker();
      Loader.stop();
    }
  }

  requestGetBalance({
    required Map<String, dynamic> data,
    required String requestName,
    required String pin,
    required BuildContext context
  }) async {
    Loader.show(context, 0);
    await balanceInquiryReq(
      data: data,
      requestName: requestName, //App.isTenantValetService ? App.cardTier : App.getBalance,
      pinValue: pin,
      context: context
    );
  }
  
  initCardReader() async {
    setState(() {
      App.telpoServiceConnected = true;
      membershipIdField.text = App.e;
    });
    
    /*
    setState(() => cardValue = "12345665000228994355" /* PlayerID 266 */); //"12345665000225652188");
    if (cardValue != null) {
      Loader.show(context, 0);
      Map<String, dynamic>? data = {App.membershipIdPrm: cardValue};
      await balanceInquiryReq(
        data: data,
        requestName: App.getPlayerID,
        membershipID: cardValue,
        context: context
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
            // setState(() => cardValue = "12345665000228994355"); //"12345665000225652188"); ///TODO: TEMPO FOR TESTING
            if (cardValue != null) {
              Loader.show(context, 0);
              Map<String, dynamic>? data = {App.membershipIdPrm: cardValue};
              await balanceInquiryReq(
                data: data,
                requestName: App.getPlayerID,
                membershipID: cardValue,
                context: context
              );
              t.cancel();
              return;
            }
          }
        } on PlatformException catch (e) {
          debugPrint("Failed to Invoke: '${e.message}'.");
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
    pinField.clear();
  }

  clearSwipeAndEnableMagstripe(context) async {
    Loader.show(context, 0);
    _clear();
    await Future.delayed(const Duration(seconds: 2));
    Loader.stop();
    Routes.navigateToScreen(const BalanceInquiry(headerTitle: App.balanceInquiryTitle));
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
    if (App.idleMode) {
      final session = IdleManager();
      session.startSessionTimer(() {
        session.showIdle(context);
      }, context);
    }
  }

  // void _cancelIdleTimeChecker() {
  //   // setState(() => isIdle = true);
  //   setState(() {
  //     _timer?.cancel();
  //     _timer = null;
  //     // isIdle = false;
  //   });

  //   if (App.isBalanceInquiryActive && !idleValidationSuccess) {
  //     // debugPrint('>>> BALANCE_INQUIRY --> TRIGGER --> TRUE isBalanceInquiryActive | FALSE idleValidationSuccess');
  //     showWarningExpiredSession(context);
  //     return;
  //   }
  // }
  
  _resetAndStartIdleTimeChecker(BuildContext context) async {
    // debugPrint('>>> BALANCE_INQUIRY --> _resetAndStartIdleTimeChecker');
    // Navigator.pop(context);

    FocusScope.of(context).unfocus();

    Loader.stop();
    
    // setState(() {
    //   _timer?.cancel();
    //   _timer = null;
    //   App.isBalanceInquiryActive = true;
    //   idleValidationSuccess = false;
    // });

    // await Future.delayed(const Duration(seconds: 1));

    _initializeIdleTimeChecker();
  }

}
