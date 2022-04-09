import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class KeyPad extends StatelessWidget {
  final TextEditingController pinController;
  final Function onChange;
  final Function onSubmit;
  final bool isPin;

  KeyPad({
    this.onChange,
    this.onSubmit,
    this.pinController,
    this.isPin = false,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonSize = screenSize.width * 0.05;

    return Container(
      margin: EdgeInsets.only(
        left: screenSize.width * 0.015,
        right: screenSize.width * 0.015,
      ),
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buttonWidget('1', screenSize, buttonSize),
              buttonWidget('2', screenSize, buttonSize),
              buttonWidget('3', screenSize, buttonSize),
            ],
          ),
          SizedBox(height: screenSize.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buttonWidget('4', screenSize, buttonSize),
              buttonWidget('5', screenSize, buttonSize),
              buttonWidget('6', screenSize, buttonSize),
            ],
          ),
          SizedBox(height: screenSize.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buttonWidget('7', screenSize, buttonSize),
              buttonWidget('8', screenSize, buttonSize),
              buttonWidget('9', screenSize, buttonSize),
            ],
          ),
          SizedBox(height: screenSize.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buttonWidget(
                  isPin
                      ? ''
                      : !pinController.text.contains('.')
                          ? '.'
                          : '',
                  screenSize,
                  buttonSize),
              buttonWidget('0', screenSize, buttonSize),
              iconButtonWidget(
                Ionicons.backspace_outline,
                () {
                  if (pinController.text.length > 0) {
                    pinController.text = pinController.text
                        .substring(0, pinController.text.length - 1);
                  }
                  if (pinController.text.length > 5 && isPin) {
                    pinController.text = pinController.text.substring(0, 3);
                  }
                  onChange(pinController.text);
                },
                buttonSize,
                screenSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  buttonWidget(String buttonText, Size screenSize, double buttonSize) {
    return Container(
      height: buttonSize,
      width: buttonSize,
      child: TextButton(
        style: ButtonStyle(
            overlayColor:
                MaterialStateColor.resolveWith((states) => Colors.transparent)),
        onPressed: () {
          // if (pinController.text.length <= 3) {
          pinController.text = pinController.text + buttonText;
          onChange(pinController.text);
          // }
        },
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenSize.width * 0.032,
            ),
          ),
        ),
      ),
    );
  }

  iconButtonWidget(
      IconData icon, Function function, double buttonSize, Size screenSize) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: function,
      child: Container(
        height: buttonSize,
        width: buttonSize,
        child: Center(
          child: Icon(
            icon,
            size: screenSize.width * 0.035,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
