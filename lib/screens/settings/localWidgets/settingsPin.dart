import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/screens/settings/orders/orders.dart';
import 'package:dropin_pos_v2/screens/settings/printer.dart';
import 'package:dropin_pos_v2/widgets/keypad/keyPad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPIN extends StatelessWidget {
  final settingName;

  const SettingsPIN({Key key, @required this.settingName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    Size screenSize = MediaQuery.of(context).size;

    final authController = Get.find<AuthController>();

    return GetBuilder<AuthController>(
      builder: (_) {
        return Column(
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.only(left: screenSize.width * 0.005),
                child: TextField(
                  controller: pinController,
                  obscureText: true,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: screenSize.width * 0.040,
                    color: Colors.amber,
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            KeyPad(
              isPin: true,
              pinController: pinController,
              onChange: (String pin) async {
                if (pin.length == 4) {
                  QuerySnapshot staffSnap = await FirebaseFirestore.instance
                      .collection(_.shopName.toString())
                      .doc('staff')
                      .collection('staffLogin')
                      .get();

                  bool _isApproved = false;

                  for (var i = 0; i < staffSnap.docs.length; i++) {
                    if (staffSnap.docs[i]['memberId'] == pin &&
                        staffSnap.docs[i]['settingApprove']) {
                      _isApproved = true;
                    }
                  }
                  if (_isApproved) {
                    Get.back();
                    switch (settingName) {
                      case 'printer':
                        Get.to(() => Printer());
                        break;
                      case 'xReport':
                        authController.printReport(
                            authController.recorededDateTimeISO,
                            'X Report',
                            '',
                            0.0);
                        break;
                      case 'orders':
                        Get.to(() => Orders());
                        break;
                      default:
                        break;
                    }
                  } else {
                    Get.back();
                    pinController.clear();
                    Get.snackbar(
                      'Unauthorized PIN',
                      'Unauthorized user. Please contact your manager',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Palette.primaryColor,
                      colorText: Palette.white,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
