import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class PrivacyPolicyScreen extends StatefulWidget {
  static String routeName = App.privacyPolicyScreen;
  const PrivacyPolicyScreen({Key? key}) :super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicyScreen> {

  @override
  void initState() {
    // App.checkIdle(context);
    super.initState();
  }

  @override
  void dispose() {
    App.t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = 85.w;
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.darkThemeColor,
        appBar: AppBar(
          backgroundColor: CustomColors.darkThemeColor,
          title: const Hero(
            tag: App.defaultKey,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                App.privacyPolicy,
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
            onTap: () {
              // setState(() => App.isIdle = true);
              // App.checkIdle(context);
              Routes.goBack();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: [
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
            ClipPath(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    App.privacyStatement,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 23,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    App.privacyPolicyInfo,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    App.coveragePrivacyPolicy,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 23,
                                    )
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "This Privacy Policy covers NUSTAR’s treatment of personally identifiable information from our customers, guests, patrons, members, vendors, business and service partners. \n\nThis policy applies to all personal data in any format, collected, maintained, used or otherwise processed by NUSTAR.",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column (
                                children: <Widget>[
                                  Text(
                                    "Why is Your Data Being Collected",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 23,
                                    )
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "Generally, we collect, use and disclose your personal data for the following purposes:",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "I. To complete your service request and purchase transaction;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "II. To respond to your queries or proposals;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "III. To handle complaints;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column (
                                children: <Widget>[
                                  Text(
                                    "IV. To maintain the security of our premises, projects, and events;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "V. To comply with applicable laws and regulations issued by government and regulatory bodies;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "VI. To maintain records of your gaming transactions;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "VII. To improve our products and services;",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "VIII. To provide updates on products, services, regulations, events, programs, and promotions.",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: App.fontSecondary,
                                      fontSize: 16,
                                    )
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 30)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

}