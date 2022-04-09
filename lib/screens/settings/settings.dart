import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/screens/settings/localWidgets/settingsPin.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import 'localWidgets/settings_buttton.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // final dashboardController = DashboardController();

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: screenSize.width * 0.01,
          horizontal: screenSize.height * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect and Manage',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Palette.darkGrey,
              fontSize: screenSize.width * 0.016,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Divider(),
          SizedBox(height: screenSize.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SettingButton(
                screenSize: screenSize,
                title: 'Printers',
                onTap: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: SettingsPIN(settingName: 'printer'),
                ),
                icon: Icon(
                  Ionicons.print_outline,
                  size: screenSize.width * 0.1,
                ),
              ),
              SizedBox(width: screenSize.width * 0.05),
              SettingButton(
                screenSize: screenSize,
                title: 'X Report',
                onTap: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: SettingsPIN(settingName: 'xReport'),
                ),
                icon: Icon(
                  Ionicons.document_outline,
                  size: screenSize.width * 0.1,
                ),
              ),
              SizedBox(width: screenSize.width * 0.05),
              SettingButton(
                screenSize: screenSize,
                title: 'Previous Orders',
                onTap: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: SettingsPIN(settingName: 'orders'),
                ),
                icon: Icon(
                  Ionicons.archive_outline,
                  size: screenSize.width * 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
