import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:dropin_pos_v2/widgets/keypad/keyPad.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class DiscountPIN extends StatelessWidget {
  final discountVal;
  final selectDiscountStr;

  const DiscountPIN(
      {Key key, @required this.discountVal, @required this.selectDiscountStr})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    Size screenSize = MediaQuery.of(context).size;

    return GetBuilder<PayController>(
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
              onChange: (String pin) {
                // if (pinController.text.length == 4) {
                _.approveDiscount(
                    pinController.text, discountVal, selectDiscountStr);
                // }
              },
            ),
          ],
        );
      },
    );
  }
}
