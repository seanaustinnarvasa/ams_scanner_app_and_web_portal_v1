import 'package:flutter/material.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'asset.scanner.dart';

class Home extends StatefulWidget {
  static String routeName = App.homeScreen;
  const Home({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  var selectedItem = App.home;
  
  String balanceInquiry = App.balance + App.nl + App.inquiry;

  bool isIdle = App.idleMode ? true : false;
  bool idleValidationSuccess = false;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    _onStartHome(context);
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  void _onStartHome(context) {
    // Routes.navigateToScreen(const AssetScannerScreen(headerTitle: App.compRedemptionTitle));
    // Routes.navigateToScreen(const QRScannerScreen());
    Routes.navigateToScreen(const AssetScannerScreen());
    // Routes.navigateToScreen(const AssetTagScreen());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return const SizedBox.shrink();
        // return Scaffold(
        //   backgroundColor: CustomColors.darkThemeColor,
        //   appBar: AppBar(
        //     automaticallyImplyLeading: false,
        //     backgroundColor: Colors.transparent,
        //     elevation: 0.0,
        //   ),
        //   extendBodyBehindAppBar: true,
        //   endDrawer: Theme(
        //     data: Theme.of(context).copyWith(
        //       canvasColor: Colors.transparent
        //     ),
        //     child: const MenuDrawer()
        //   ),
        //   body: Container(
        //     width: double.infinity,
        //     height: double.infinity,
        //     decoration: const BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [
        //           Color.fromRGBO(18, 18, 18, 0.8),
        //           Colors.transparent
        //         ]
        //       )
        //     ),
        //     child: SingleChildScrollView(
        //       child: SafeArea(
        //         top: false,
        //         child: Column(
        //           children: <Widget>[
        //             Container(
        //               margin: EdgeInsets.zero,
        //               width: 100.w,
        //               height: 55.h,
        //               child: Stack(
        //                 children: <Widget>[
        //                   ShaderMask(
        //                     shaderCallback: (rect) {
        //                       return const LinearGradient(
        //                         begin: Alignment.topCenter,
        //                         end: Alignment.bottomCenter,
        //                         colors: [Colors.black, Colors.transparent],
        //                       ).createShader(
        //                         Rect.fromLTRB(
        //                           0,
        //                           0,
        //                           rect.width,
        //                           rect.height
        //                         )
        //                       );
        //                     },
        //                     blendMode: BlendMode.dstIn,
        //                     child: Image.asset(
        //                       App.nustarResort,
        //                       height: 100.h,
        //                       fit: BoxFit.fill,
        //                     ),
        //                   ),
        //                   const SizedBox(height: 100),
        //                   App.breakpoint < MediaQuery.of(context).size.width ? Flex(
        //                     direction: Axis.horizontal,
        //                     children: [
        //                       Flexible(
        //                         flex: App.paneProportion,
        //                         child: Padding(
        //                           padding: const EdgeInsets.only(top: 25),
        //                           child: Align(
        //                             alignment: Alignment.topCenter,
        //                             child: RotatedBox(
        //                               quarterTurns: 3,
        //                               child: Text(
        //                                 App.nustar,
        //                                 style: TextStyle(
        //                                   fontSize: 75,
        //                                   fontWeight: FontWeight.bold,
        //                                   fontFamily: App.fontPrimary,
        //                                   color: Colors.grey.withOpacity(0.6),
        //                                   letterSpacing: 10
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     ],
        //                   ) : 
        //                   Flex(
        //                     direction: Axis.horizontal,
        //                     children: [
        //                       Flexible(
        //                         flex: 30,
        //                         child: Padding(
        //                           padding: const EdgeInsets.only(bottom: 20),
        //                           child: Align(
        //                             alignment: Alignment.bottomCenter,
        //                             child: RotatedBox(
        //                               quarterTurns: 3,
        //                               child: Text(
        //                                 App.nustar,
        //                                 style: TextStyle(
        //                                   fontSize: 50,
        //                                   fontWeight: FontWeight.bold,
        //                                   fontFamily: App.fontPrimary,
        //                                   color: Colors.grey.withOpacity(0.6),
        //                                   letterSpacing: 10
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                       const Flexible(
        //                         flex: 90,
        //                         child: Padding(
        //                           padding: EdgeInsets.only(bottom: 20),
        //                           child: Row(
        //                             children: [
        //                               Align(
        //                                 alignment: Alignment.bottomCenter,
        //                                 child: SizedBox(
        //                                   width: 250,
        //                                   child: Text(
        //                                     App.merchant,
        //                                     style: TextStyle(
        //                                       fontSize: 33,
        //                                       fontFamily: App.fontPrimary,
        //                                       fontWeight: FontWeight.bold,
        //                                       color: Colors.white,
        //                                       letterSpacing: 5
        //                                     ),
        //                                   ),
        //                                 )
        //                               ),
        //                             ],
        //                           )
        //                         ),
        //                       ),
        //                     ],
        //                   )
        //                 ],
        //               ),
        //             ),
        //             const SizedBox(height: 5),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //               children: <Widget>[
        //                 _buildMenuItem(
        //                   balanceInquiry,
        //                   Icons.wallet
        //                 ),
        //                 _buildMenuItem(
        //                   App.earnPoints,
        //                   Icons.money
        //                 ),
        //               ],
        //             ),
        //             Container(height: 15),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //               children: <Widget>[
        //                 _buildMenuItem(
        //                   App.pointsRedemption,
        //                   Icons.point_of_sale
        //                 ),
        //                 _buildMenuItem(
        //                   App.compsRedemption,
        //                   Icons.redeem_sharp
        //                 ),
        //               ],
        //             ),
        //             // if (idleManager.isIdle) const CircularProgressIndicator.adaptive(),
        //           ]
        //         )
        //       ),
        //     )
        //   ),
        // );
      }
    );
  }

  Widget _buildMenuItem(
    String menuItemName,
    IconData iconType
  ) {
    return AnimatedContainer(
      height: 17.h,
      width: 40.w,
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
      child: Container(
        decoration: BoxDecoration(
          color: isHovering ? Colors.black : const Color(0xFF651b32),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: isHovering ? Colors.black : const Color(0xFF651b32),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)
          ),
          shadowColor: Colors.black.withOpacity(0.1),
          borderOnForeground: true,
          child: InkWell(
            onTap: () => redirectToDetailScreen(),
            onHover: (value) => setState(() => isHovering = value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  iconType,
                  color: Colors.white
                ),
                const SizedBox(height: 12.0),
                Text(
                  menuItemName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontFamily: App.fontSecondary,
                    fontSize: 14.0,
                  )
                )
              ]
            )
          ),
        ),
      )
    );
  }

  redirectToDetailScreen() async {
    Routes.navigateToScreen(const AssetScannerScreen(headerTitle: App.compRedemptionTitle));
  }
  
}