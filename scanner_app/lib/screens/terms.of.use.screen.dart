import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class TermsOfUseScreen extends StatefulWidget {
  static String routeName = App.termsOfUseScreen;
  const TermsOfUseScreen({Key? key}) :super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _TermsOfUseState createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUseScreen> {

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
                App.termsOfUse,
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
                        colors: [Colors.white, Colors.transparent],
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
                                  fontFamily: App.fontPrimary,
                                  fontWeight: FontWeight.bold,
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
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 15),
                            Container(
                              margin: EdgeInsets.zero,
                              width: screenWidth,
                              child: const Column(
                                children: <Widget>[
                                  Text(
                                    "THE TERMS AND CONDITIONS SET FORTH BELOW (THE 'TERMS OF USE') GOVERN YOUR USE OF THIS SITE ON THE WORLD WIDE WEB. THESE TERMS ARE A LEGAL CONTRACT BETWEEN YOU AND NUSTAR RESORT AND CASINO AND GOVERN YOUR ACCESS TO, AND USE OF THE NUSTAR RESORT AND CASINO WEBSITE LOCATED AT WWW.NUSTAR.PH (THE 'WEBSITE'). IF YOU DO NOT AGREE WITH ANY OF THESE TERMS, DO NOT ACCESS OR OTHERWISE USE THIS WEBSITE OR ANY INFORMATION CONTAINED ON THIS WEBSITE. YOUR USE OF THIS WEBSITE OR ANY INFORMATION CONTAINED ON THIS WEBSITE SHALL CONSTITUTE YOUR AGREEMENT TO ABIDE BY EACH OF THE TERMS SET FORTH BELOW. ANY BREACH OR VIOLATION BY YOU OR BY ANY PERSON ACTING FOR AND ON YOUR BEHALF OF THESE TERMS OF USE WILL BE PROSECUTED TO THE FULLEST EXTENT BY NUSTAR RESORT AND CASINO. This website is owned by NUSTAR Resort and Casino. NUSTAR Resort and Casino reserves the right, at its sole discretion, to change, modify, add to, or otherwise alter these Terms of Use at any time. Such changes and/or modifications shall become effective immediately upon posting, so please review these Terms of Use periodically. Your continued use of this website following the posting of changes and/or modifications will constitute your acceptance of the revised Terms of Use (including NUSTAR Resort and Casino’s Privacy Policy).",
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
                                    "Authorized Use: NUSTAR Resort and Casino provides this website solely to permit you to determine the availability of products and services offered on the website and to make legitimate reservations or otherwise transact business with NUSTAR Resort and Casino, and for no other purposes. The website is for your personal and non-commercial use. You agree that you will use the website's services only to make legitimate reservations or purchases for you or for another person for whom you are authorized to act both legally and under the terms of this Terms of Use. Hence, unless you are specifically authorized otherwise by NUSTAR Resort and Casino, you are permitted to use this website only for the following personal and non-commercial purposes: (1) viewing the website; (2) making bookings; (3) reviewing or changing bookings; (4) transferring to other websites through links provided on this website; and (5) making use of other facilities that may be provided on the website. You are not permitted to use any automated system or software to extract data from this website for commercial purposes ('screen-scraping'). You hereby expressly agree not to use this website to: Modify, copy, distribute, transmit, display, perform, reproduce, publish, license, create derivative works from, transfer, or sell any information, software, products or services obtained from this website; 'Meta-search' this website, send, or cause to be sent, any automated queries of any sort to this website, or use this website in any commercial manner or access this website for any commercial gain other than the purpose specifically authorized by these Terms of Use; Impersonate any person or entity, or otherwise state or falsely misrepresent your affiliation with a person or entity; Forge or otherwise manipulate identifiers in order to disguise the origin of any user of the website including yourself; Interfere with or disrupt this website or servers or networks connected to this website or disobey any requirements, procedures, policies or regulations of networks connected to this website, including using any device, software or routine to bypass the website's robot exclusion mechanisms; intentionally or unintentionally violate any applicable local, national or international law; and collect or store any personal data of any other user that you obtained by any means through this website.",
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
                                    "Intellectual Property: NUSTAR Resort and Casino is the registered owner of and holds the title to and all interest (including the security interest) in the trademark 'NUSTAR Resort and Casino' and owns all intellectual property rights to and all interest in the tradename NUSTAR Resort and Casino logo. Intellectual Property Rights (including, but not limited to the copyright, patent and trademark) in the material contained in this website belongs to NUSTAR Resort and Casino. No part of such materials included may be reproduced, transmitted, downloaded, saved, displayed or used in any manner or for any purpose without prior written authority from NUSTAR Resort and Casino.",
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
                            const SizedBox(height: 30)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}