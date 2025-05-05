import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/view/past_routes_screen.dart';
import 'package:flutter_application_1/view/map_screen.dart';
import 'package:flutter_application_1/view/settings_screen.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});
  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  final Color navigationBarColor = Colors.white;
  int selectedIndex = 1;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// [AnnotatedRegion<SystemUiOverlayStyle>] only for android black navigation bar. 3 button navigation control (legacy)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle(systemNavigationBarColor: navigationBarColor, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: <Widget>[PastRoutesScreen(), MapScreen(), SettingsScreen()],
        ),
        bottomNavigationBar: WaterDropNavBar(
          backgroundColor: navigationBarColor,
          onItemSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
            pageController.animateToPage(selectedIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
          },
          selectedIndex: selectedIndex,
          barItems: <BarItem>[
            // History sekmesi için ikon
            BarItem(filledIcon: Icons.history_rounded, outlinedIcon: Icons.history_outlined),
            // Map sekmesi için ikon
            BarItem(filledIcon: Icons.map_rounded, outlinedIcon: Icons.map_outlined),
            // Settings sekmesi için ikon
            BarItem(filledIcon: Icons.settings_rounded, outlinedIcon: Icons.settings_outlined),
          ],
        ),
      ),
    );
  }
}
