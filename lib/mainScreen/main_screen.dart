import 'package:driver_app/tabPages/earning_tab.dart';
import 'package:driver_app/tabPages/home_tab.dart';
import 'package:driver_app/tabPages/profile_tab.dart';
import 'package:driver_app/tabPages/rating_tab.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../appConstatns/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {


  TabController? tabController;
  int selectedIndex = 0;

  onItemClick(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  //.............................................................
  @override
  void initState() {
    super.initState();

    // inital tab controller ..............
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeTabPage(),
          EarningTabPage(),
          RatingTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.darkGreen,
        child: Container(
      
          height: 78,
          margin: const EdgeInsets.all(7),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(35),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: AppColors.darkGreen,
              )
            ],
          ),
          child: GNav(
            rippleColor: AppColors.lightBlue,
            hoverColor: Colors.grey[100]!,
            gap: 4,
            activeColor: Colors.black,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppColors.yellowColor,
            color: AppColors.lightBlue,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.credit_card,
                text: 'Earning',
              ),
              GButton(
                icon: Icons.star,
                text: 'Rating',
              ),
              GButton(
                icon: Icons.person,
                text: 'Account',
              ),
            ],
            onTabChange: onItemClick,
          ),
        ),
      ),
    );
  }
}
