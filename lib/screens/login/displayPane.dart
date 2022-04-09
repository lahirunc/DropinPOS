import 'dart:ui';

import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    Size screenSize = MediaQuery.of(context).size;

    authController.getPackageInfo();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/loginHero.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.05,
          horizontal: screenSize.width * 0.09,
        ),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.width * 0.05),
                Image.asset(
                  'assets/images/logo.png',
                  height: screenSize.height * 0.1,
                ),
                SizedBox(height: screenSize.width * 0.05),
                Text(
                  'Dropin POS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.035,
                    color: Palette.white,
                  ),
                ),
                SizedBox(height: screenSize.width * 0.005),
                Obx(() => Text(
                      authController.version.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: screenSize.width * 0.035,
                        color: Palette.white,
                      ),
                    )),
                SizedBox(height: screenSize.width * 0.03),
                Text(
                  'Advance POS solutions to manage small & medium size business',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.016,
                    color: Palette.white,
                    height: screenSize.height * 0.002,
                  ),
                ),
                SizedBox(height: screenSize.width * 0.05),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        print('fb');
                      },
                      child: Image.asset(
                        'assets/images/logos/fb.png',
                        height: screenSize.height * 0.03,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        print('insta');
                      },
                      child: Image.asset(
                        'assets/images/logos/insta.png',
                        height: screenSize.height * 0.03,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        print('web');
                      },
                      child: Image.asset(
                        'assets/images/logos/web.png',
                        height: screenSize.height * 0.03,
                      ),
                    ),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                  ],
                ),
                SizedBox(height: screenSize.width * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Palette.darkGrey,
                        fontSize: screenSize.width * 0.016,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Contact',
                      style: TextStyle(
                        color: Palette.darkGrey,
                        fontSize: screenSize.width * 0.016,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '© Dropin 2021',
                      style: TextStyle(
                        color: Palette.darkGrey,
                        fontSize: screenSize.width * 0.016,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.width * 0.04),

                //log out
                (authController.shopName.toString() != '')
                    ? InkWell(
                        onTap: () {
                          authController.logOut();
                        },
                        child: Container(
                          width: screenSize.width * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Palette.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Login from another account?',
                                      style: TextStyle(
                                          fontSize: screenSize.width * 0.014),
                                    ),
                                    SizedBox(height: screenSize.width * 0.002),
                                    Text(
                                      'Log out',
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: screenSize.width * 0.02,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenSize.height * 0.01,
                                      horizontal: screenSize.width * 0.017,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Palette.black,
                                        size: screenSize.width * 0.03,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
