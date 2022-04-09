import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';
import 'package:dropin_pos_v2/screens/till/openingTill.dart';
import 'package:dropin_pos_v2/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/keypad/keyPad.dart';

class CodeUnlock extends StatefulWidget {
  @override
  _CodeUnlockState createState() => _CodeUnlockState();
}

class _CodeUnlockState extends State<CodeUnlock> {
  TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    Size screenSize = MediaQuery.of(context).size;

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
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(FirebaseAuth.instance.currentUser.displayName)
              .doc("staff")
              .collection('staffLogin')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loader();
            }
            bool _isCorrect = false;

            return KeyPad(
              isPin: true,
              pinController: pinController,
              onChange: (String pin) async {
                try {
                  if (pinController.text.length == 4) {
                    for (var i = 0; i < snapshot.data.docs.length; i++) {
                      if (pinController.text ==
                          snapshot.data.docs[i]['memberId'].toString()) {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();

                        var storedTillId =
                            preferences.getString('tillId') ?? '';
                        var storedTillAmt =
                            preferences.getString('tillAmount') ?? '';
                        var storedSaffId =
                            preferences.getString('saffId') ?? '';
                        var storedStartDateTime =
                            preferences.getString('startDateTime') ?? '';

                        print('Stored TillId: ' + storedTillId.toString());
                        print('Stored TillAmt: ' + storedTillAmt.toString());
                        print('Stored SaffId: ' + storedSaffId.toString());
                        print('Stored startDateTime: ' +
                            storedStartDateTime.toString());

                        if (snapshot.data.docs[i].id != storedSaffId) {
                          authController.initTillAmount.value = -1;
                          authController.tillId = '';
                          authController.recorededDateTimeISO = '';
                        } else {
                          authController.initTillAmount.value =
                              double.parse(storedTillAmt.toString());
                          authController.tillId = storedTillId;
                          authController.recorededDateTimeISO =
                              storedStartDateTime;
                        }

                        authController.userName =
                            RxString(snapshot.data.docs[i]['firstName']);
                        authController.userId =
                            RxString(snapshot.data.docs[i].id);
                        _isCorrect = true;
                      }
                    }
                  }
                  if (_isCorrect) {
                    final globalController = Get.find<GlobalController>();
                    globalController.getOrderId();

                    Get.to(() => authController.initTillAmount.value == -1
                        ? OpeningTill()
                        : Dashboard());
                  } else if (pinController.text.length >= 4) {
                    Get.snackbar(
                      'Invalid PIN',
                      'Pin didn\'t match please try again!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Palette.primaryColor,
                      colorText: Palette.white,
                    );
                    pinController.clear();
                  }
                } catch (e) {
                  Get.snackbar(
                    'Connection Error!',
                    'Please check your device is connected to internet.\n' +
                        e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Palette.primaryColor,
                    colorText: Palette.white,
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  void showInSnackBar(String value, Size screenSize) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          value,
          style: TextStyle(
            fontSize: screenSize.width * 0.018,
          ),
        ),
      ),
    );
  }
}
