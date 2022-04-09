import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/utils/root.dart';
import 'package:dropin_pos_v2/widgets/keypad/keyPad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpeningTill extends StatelessWidget {
  const OpeningTill({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    TextEditingController textController = TextEditingController();

    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Opening Cash in Register',
            style: TextStyle(
              fontSize: screenSize.width * 0.034,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.1),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.2),
            child: Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.005),
              child: TextField(
                controller: textController,
                obscureText: false,
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
                    prefixIcon: Icon(
                      Icons.attach_money,
                      size: screenSize.width * 0.05,
                      color: Colors.amber,
                    )),
              ),
            ),
          ),
          Container(
            child: KeyPad(
              pinController: textController,
              onChange: (String pin) {},
            ),
          ),
          SizedBox(height: screenSize.height * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Palette.mediumGrey,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.08,
                    vertical: screenSize.height * 0.02,
                  ),
                ),
                onPressed: () => Get.offAll(() => Root()),
                child: const Text('Clock Out'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Palette.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.15,
                    vertical: screenSize.height * 0.02,
                  ),
                ),
                onPressed: () =>
                    authController.storeOpening(textController.text),
                child: Text(
                  'Start',
                  style: TextStyle(fontSize: screenSize.width * 0.018),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
