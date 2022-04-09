import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:dropin_pos_v2/widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';

class OrderDetailsHeader extends StatelessWidget {
  const OrderDetailsHeader(
      {Key key,
      @required this.screenSize,
      @required this.controller,
      @required this.itemIndex})
      : super(key: key);

  final Size screenSize;
  final SettingsController controller;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.02),
          RichText(
            text: TextSpan(
              text: controller.prevOrderList[itemIndex].cusName,
              style: TextStyle(
                  color: Palette.black, fontSize: screenSize.width * 0.024),
              children: [
                controller.prevOrderList[itemIndex].mobile.toString().isNotEmpty
                    ? TextSpan(
                        text:
                            ' | ${controller.prevOrderList[itemIndex].mobile}')
                    : TextSpan(text: ''),
              ],
            ),
          ),
          SizedBox(height: screenSize.height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CustomOutlinedButton(
              //     screenSize: screenSize,
              //     onPressed: () => print('Refund'),
              //     title: 'Issue Refund',
              //     width: screenSize.width * 0.08,
              //     height: screenSize.width * 0.015),
              // SizedBox(width: screenSize.width * 0.01),
              CustomOutlinedButton(
                  screenSize: screenSize,
                  onPressed: () => controller.printPrevOrder(itemIndex),
                  title: 'Print Reciept',
                  width: screenSize.width * 0.08,
                  height: screenSize.width * 0.015),
            ],
          ),
        ],
      ),
    );
  }
}
