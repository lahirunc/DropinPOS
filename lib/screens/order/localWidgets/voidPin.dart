import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/widgets/keypad/keyPad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class VoidPIN extends StatelessWidget {
  final index;

  const VoidPIN({Key key, @required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    Size screenSize = MediaQuery.of(context).size;

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

                  for (var i = 0; i < staffSnap.docs.length; i++) {
                    if (staffSnap.docs[i]['memberId'] == pin &&
                        staffSnap.docs[i]['voidApprove']) {
                      Get.back();
                      voidItemPopup(screenSize, index);
                      return;
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
                } else {}
              },
            ),
          ],
        );
      },
    );
  }

  voidItemPopup(Size screenSize, int index) {
    TextEditingController _voidController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    OrderController orderController = Get.find<OrderController>();

    Get.defaultDialog(
      title: orderController.cartList[index].name.toUpperCase(),
      titleStyle: TextStyle(fontWeight: FontWeight.bold),
      content: Container(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Container(
                // height: screenSize.height * 0.02,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]),
                  color: Colors.grey[100],
                ),
                child: TextFormField(
                  maxLines: 6,
                  controller: _voidController,
                  // validator: (String value) {
                  //   if (value.length < 5)
                  //     return "Please enter a valid reason!";
                  //   else
                  //     return null;
                  // },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: screenSize.width * .01,
                      top: screenSize.height * .01,
                    ),
                    hintText: 'Reason for removing the item',
                  ),
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            // Buttons close / Save
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      primary: Palette.mediumGrey,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.06),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        orderController.voidItem(
                            index, _voidController.text.trim());
                        Get.back();
                      }
                    },
                    child: Text('Void'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.06),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
