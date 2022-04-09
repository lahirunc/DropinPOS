import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/state_manager.dart';

import '../../../widgets/keypad/keyPad.dart';

class CashKeypad extends StatelessWidget {
  const CashKeypad({Key key}) : super(key: key);

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
                  obscureText: false,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // letterSpacing: screenSize.width * 0.000,
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
              pinController: pinController,
              onChange: (String pin) {
                _.calcAmountToPay(double.parse(pinController.text) ?? 0);
              },
            ),
          ],
        );
      },
    );
  }
}
