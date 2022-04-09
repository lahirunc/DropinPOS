import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/screens/login/displayPane.dart';
import 'package:dropin_pos_v2/widgets/dateTimeDisp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'codeUnlock.dart';

class PinScreen extends StatelessWidget {
  const PinScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    AuthController authController = Get.find<AuthController>();
    // TextEditingController pinController = TextEditingController();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: DisplayPane(),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  screenSize.width * 0.05,
                  screenSize.height * 0.08,
                  screenSize.width * 0.05,
                  screenSize.height * 0.02,
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          '${authController.shopName.toUpperCase()}',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.028,
                            fontWeight: FontWeight.bold,
                            color: Palette.primaryColor,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        SizedBox(height: screenSize.height * 0.00),
                        CodeUnlock(),
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.03),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: Text(
                    //     'Forgot PIN?',
                    //     style: TextStyle(
                    //       color: Colors.red,
                    //       fontSize: screenSize.width * 0.014,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: screenSize.height * 0.1),
                    DateTimeDisp(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
