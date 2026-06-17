import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/data/models/users.dart';
import 'package:nustar_turnstile_scanner/screens/home.screen.dart';
import 'package:nustar_turnstile_scanner/services/database.service.dart';
import 'package:nustar_turnstile_scanner/services/gpg.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/loader.dart';
import 'package:nustar_turnstile_scanner/utility/shared/sizes.dart';
import 'package:nustar_turnstile_scanner/utility/shared/text.field.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  static String routeName = App.signIn;
  final String? phoneNumber;

  const SignInScreen({
    Key? key,
    this.phoneNumber,
  }) : super(key: key);
  @override
  State<SignInScreen> createState() =>
      _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  bool _showPassword = true;

  @override
  void initState() {
    initStart(context);
    super.initState();
  }

  @override
  void dispose() {
    usernameController.clear();
    pwController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: CustomColors.darkThemeColor,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(1, 1, 1, 0.8),
                  Colors.transparent
                ]
              )
            ),
            child: Container(
              margin: EdgeInsets.zero,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.zero,
                      width: 100.w,
                      height: 60.h,
                      child: Stack(
                        children: <Widget>[
                          ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                // stops: [0.0, 1.0],
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
                                          fontSize: 55,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: App.fontPrimary,
                                          color: Colors.grey.withOpacity(0.6),
                                          letterSpacing: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Flexible(
                                flex: 92,
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
                    const SizedBox(height: 10),
                    _inputField(),
                    const SizedBox(height: 15),
                    _submitButton(context),
                    const SizedBox(height: 30),
                    Text(
                      App.versionNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: App.fontSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _inputField() {
    return Column(
      children: <Widget>[
        AppTextFormField.defaultInput(
          App.username.capitalize(),
          false,
          usernameController
        ),
        AppTextFormField.defaultInput(
          App.password,
          _showPassword,
          pwController,
          onTap: () => _togglevisibility(),
          thisChild: Icon(_showPassword ? Icons.visibility_off :
            Icons.visibility, color: Colors.white
          ),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return InkWell(child: 
      Container(
        height: 10.h,
        width: 100.w,
        margin: const EdgeInsets.symmetric(horizontal: 28),
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
          App.signIn.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: App.fontSecondary,
          ),
        ),
      ),
      onTap: () async {
        AppTextFormField.hideKeyboard();
        String username = usernameController.text;
        String pw = pwController.text;
        if (username.isEmpty || pw.isEmpty) {
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
        postLoginAccount(
          context: context,
          username: username,
          password: pw
        );
      }
    );
  }

  void postLoginAccount({
    required BuildContext context,
    required String username,
    required String password
  }) async {
    final token = await App.getTokenKey(context);
    setState(() => App.k3y = token);
    Map<String, dynamic>? param = {
      App.username: username,
      App.password.toLowerCase(): password,
      App.deviceId: App.memberCurrentDeviceID
    };
    await accountLoginReq(
      param,
      username,
      password
    );
  }

  Future<void> accountLoginReq(
    Map<String, dynamic> data,
    String username,
    String password
  ) async {
    var url = Uri.parse(App.accountLoginURI);
    App.headers = {
      App.authKey: App.k3y ?? App.na,
      App.contentType: App.appJsonUTF8
    };
    var loginResponse = await http.post(
      url,
      headers: App.headers,
      body: json.encode(data),
      encoding: Encoding.getByName(App.utf8),
    );
    // final getIdleMode = await App.getLocalStorage(
    //   keyName: App.idleModeKey,
    //   dataType: App.boolean
    // );
    final List<Users> user = [
      Users.fromJson(jsonDecode(loginResponse.body))
    ];
    int tenantId = user[0].tenantId ?? 0;
    debugPrint('>>> tenantId: $tenantId');
    String errorMessage = user[0].errorMessage ?? App.undefinedError;
    String tenantName = user[0].tenantName ?? App.na;
    String userName = user[0].username ?? App.na;
    String name = user[0].name ?? App.na;
    String requestKey = await Gpg.encodeData(
      userName+tenantName+name+tenantId.toString()
    ) ?? App.na;
    bool errorStatus = user[0].errorStatus ?? false;

    // debugPrint('>>> LOGIN_REQUEST getIdleMode: $getIdleMode');

    // ignore: use_build_context_synchronously
    final authUser = await DatabaseService.authenticateAndCreateUserEmailAndPassword(
      context,
      userEmailAddress: username,
      userPw: password,
    );
    
    if (!authUser) {
      // _unableToConnect("Unable to login. Please try again");
      return;
    }

    if (errorMessage.contains(App.connectionAttemptFailed) || 
        errorMessage.contains(App.tn)
    ) {
      DatabaseService.insertUserLogs(
        userId: requestKey,
        deviceId: App.memberCurrentDeviceID!,
        username: userName,
        name: name,
        tenantId: tenantId,
        tenantName: tenantName,
        earnPointsEnabled: App.earnPointsEnabled ?? false,
        pointsRedemptionEnabled: App.pointsRedemptionEnabled ?? false,
        balanceInquiryEnabled: App.balanceInquiryEnabled ?? false,
        compRedemptionEnabled: App.compsRedemptionEnabled ?? false,
      );
      _unableToConnect(App.serverErrorMsg);
      return;
    }

    if (errorStatus) {
      DatabaseService.insertUserLogs(
        userId: requestKey,
        deviceId: App.memberCurrentDeviceID!,
        username: userName,
        name: name,
        tenantId: tenantId,
        tenantName: tenantName,
        earnPointsEnabled: App.earnPointsEnabled ?? false,
        pointsRedemptionEnabled: App.pointsRedemptionEnabled ?? false,
        balanceInquiryEnabled: App.balanceInquiryEnabled ?? false,
        compRedemptionEnabled: App.compsRedemptionEnabled ?? false,
      );
      _unableToConnect(errorMessage);
      return;
    }

    if (loginResponse.statusCode == 200) {
      setState(() {
        // App.idleMode = getIdleMode ?? false;
        App.memberCurrentUsername = userName;
        App.memberCurrentName = name;
        App.memberCurrentTenantID = tenantId;
        App.memberCurrentTenantName = tenantName;
        App.balanceInquiryEnabled = user[0].enableInquiry ?? false;
        App.earnPointsEnabled = user[0].enableEarn ?? false;
        App.pointsRedemptionEnabled = user[0].enableRedeem ?? false;
        App.compsRedemptionEnabled = user[0].enableRedeemComp ?? false;
        App.requestKey = requestKey;
        App.loginDateTime = App.currentDateAndTime();
        App.idleMode = true; /// Set Idle Mode to enable by default
        // debugPrint("tenantId ->$tenantId");
        if (tenantId == 37 || tenantId == 57) {
          App.isTenantValetService = true;
        }
      });

      DatabaseService.insertUserLogs(
        userId: requestKey,
        deviceId: App.memberCurrentDeviceID!,
        username: App.memberCurrentUsername,
        name: name,
        tenantId: tenantId,
        tenantName: tenantName,
        earnPointsEnabled: App.earnPointsEnabled ?? false,
        pointsRedemptionEnabled: App.pointsRedemptionEnabled ?? false,
        balanceInquiryEnabled: App.balanceInquiryEnabled ?? false,
        compRedemptionEnabled: App.compsRedemptionEnabled ?? false,
      );

      Loader.stop();
      
      Routes.navigateToScreen(const Home());
    }  else {
      _unableToConnect(App.serverErrorMsg);
    }
  }

  _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  _unableToConnect(String message) {
    Loader.stop();
    // ignore: use_build_context_synchronously
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      barrierDismissible: true,
      confirmBtnText: App.ok,
      title: App.e,
      text: message
    );
  }

  initStart(BuildContext context) async {
    /* ///TODO: --- FOR DEBUGGING/TESTING PURPOSES ONLY */
    // usernameController.text = "sean.narvasa";    //"rowelcc";   // "rewards1";
    // pwController.text = "123qwe"; //"111111";    // "1234";

    // usernameController.text = "RC&M";    //"rowelcc";   // "rewards1";
    // pwController.text = "rc&m00234"; //"111111";    // "1234";
  }

}