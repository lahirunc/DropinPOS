import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/screens/till/closingTill.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Logout extends StatelessWidget {
  const Logout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to clock out?',
              style: TextStyle(
                fontSize: screenSize.width * 0.036,
                fontWeight: FontWeight.bold,
                color: Palette.primaryColor,
              ),
            ),
            SizedBox(height: screenSize.height * 0.05),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.08,
                  vertical: screenSize.height * 0.02,
                ),
              ),
              onPressed: () => Get.to(() => ClosingTill()),
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: screenSize.width * 0.032,
                  fontWeight: FontWeight.bold,
                  // color: Palette.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
