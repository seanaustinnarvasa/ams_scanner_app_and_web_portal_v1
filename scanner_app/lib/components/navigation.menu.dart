import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nustar_turnstile_scanner/components/custom.colors.dart';
import 'package:nustar_turnstile_scanner/screens/home.screen.dart';
import 'package:nustar_turnstile_scanner/utility/shared/app.data.dart';
import 'package:nustar_turnstile_scanner/utility/shared/routes.navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavigationMenu extends StatefulWidget {
  static String routeName = App.navigationMenuScreen;
  static int activeIndex = 0;
  final String uid;
  const NavigationMenu({Key? key, activeIndex, required this.uid}) : super(key: key);
  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  bool isLoading = true;
  static CupertinoTabView? returnValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: 
          Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  width: 100.h, //kIsWeb ? 600.0 : screenWidth,
                  child: Scaffold(
                    appBar: AppBar(
                      flexibleSpace: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color> [
                                    Color.fromARGB(255, 0, 0, 0),
                                    CustomColors.themeColor
                                  ]
                          ),
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 85, bottom: 20),
                              child: Image(
                                height: 44,
                                image: AssetImage(App.nustarLogo)
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 90),
                              child: Text(
                                App.login,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: App.fontSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      centerTitle: true,
                      // actions: [NotificationButton()],
                      leading: Builder(builder: (context) {
                        return IconButton(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          alignment: Alignment.centerLeft,
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        );
                      }),
                    ),
                    body: CupertinoTabScaffold(
                      tabBar: CupertinoTabBar(
                        onTap: (value) {
                          setState(() => NavigationMenu.activeIndex = value);
                          if (value == 0) {
                            NavigationMenu.activeIndex = 0;
                            Routes.replaceScreen(NavigationMenu(uid: widget.uid));
                            // Routes.popAndPush(context, App.navigationMenuScreen);
                          } else if (value == 1) {
                            NavigationMenu.activeIndex = 1;
                          } else if (value == 2) {
                            NavigationMenu.activeIndex = 2;
                          } else if (value == 3) {
                            NavigationMenu.activeIndex = 3;
                          } else if (value == 4) {
                            NavigationMenu.activeIndex = 4;
                          }
                        },
                        activeColor: Colors.white, //NavigationMenu().setActiveColor(NavigationMenu.activeIndex, false),
                        inactiveColor: CustomColors.lightGrey,
                        backgroundColor: CustomColors.themeColor,
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.home),
                            label: 'Home'
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.star),
                            label: 'Promos',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.person),
                            label: 'Account',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.envelope),
                            label: 'Messages',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.ellipsis_circle_fill),
                            label: 'More',
                          ),
                        ],
                      ),
                      tabBuilder: (context, index) {
                        index = NavigationMenu.activeIndex;
                        var home = CupertinoTabView(builder: (context) => const Home());
                        switch (index) {
                          case 0:
                            returnValue = home;
                            break;
                        }
                        return returnValue ?? home;
                      },
                    )
                  ),
                );
              }
            ),
          // ),
        ),
      ),
    );
  }
  
}