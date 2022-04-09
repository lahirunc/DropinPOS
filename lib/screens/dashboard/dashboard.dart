import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/dashboardController.dart';
import 'package:dropin_pos_v2/screens/dashboard/delivery.dart';
import 'package:dropin_pos_v2/screens/dashboard/dine.dart';
import 'package:dropin_pos_v2/screens/dashboard/online/online.dart';
import 'package:dropin_pos_v2/screens/login/logout.dart';
import 'package:dropin_pos_v2/screens/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'takeaway.dart';

class Dashboard extends StatelessWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Dine(),
      TakeAway(),
      Delivery(),
      Online(),
      Settings(),
      Logout(),
    ];
    Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          return SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // SizedBox(height: screenSize.height * 0.1),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Dine In',
                              Icons.dinner_dining,
                              0,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Take Away',
                              Icons.takeout_dining,
                              1,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Delivery',
                              Icons.delivery_dining,
                              2,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Online',
                              Icons.book_online,
                              3,
                            ),
                            SizedBox(height: screenSize.height * 0.1),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Settings',
                              Icons.settings,
                              4,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            buildMenuIcons(
                              screenSize,
                              controller,
                              'Clock out',
                              Icons.power_settings_new_rounded,
                              5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      child: _widgetOptions[controller.tabIndex ?? 0],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMenuIcons(Size screenSize, DashboardController controller,
          String textStr, IconData icon, int index) =>
      InkWell(
        onTap: () {
          controller.changeTabIndex(index);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.01,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: index == controller.tabIndex
                ? Palette.primaryColor
                : Colors.transparent,
                
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: screenSize.width * 0.04,
                color:
                    index == controller.tabIndex ? Palette.white : Colors.black,
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                textStr,
                style: TextStyle(
                  fontSize: screenSize.width * 0.014,
                  fontWeight: index == controller.tabIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: index == controller.tabIndex
                      ? Palette.white
                      : Colors.black,
                ),
              )
            ],
          ),
        ),
      );
}
