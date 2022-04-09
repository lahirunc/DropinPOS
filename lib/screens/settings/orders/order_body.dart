import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'order_details.dart';

class OrderBody extends StatelessWidget {
  const OrderBody({
    Key key,
    @required this.screenSize,
    this.controller,
  }) : super(key: key);

  final Size screenSize;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: SizedBox(
        // height: screenSize.height * 00.5,
        width: double.infinity,
        child: Obx(
          () => GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: screenSize.width * 0.2,
              // mainAxisExtent: screenSize.height * 0.28,
              crossAxisSpacing: screenSize.width * 0.01,
              mainAxisSpacing: screenSize.height * 0.02,
            ),
            itemCount: controller.prevOrderList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OrderDetails(
                          itemIndex: index,
                          screenSize: screenSize,
                          controller: controller,
                        ))),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Palette.lightGrey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BodyText(
                          screenSize: screenSize,
                          title: 'Order: ${controller.prevOrderList[index].id}',
                          isBold: true,
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        BodyText(
                          screenSize: screenSize,
                          title:
                              'Date: ${controller.prevOrderList[index].date}',
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        BodyText(
                          screenSize: screenSize,
                          title:
                              'Total: \$${controller.prevOrderList[index].total.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        BodyText(
                          screenSize: screenSize,
                          title:
                              'Payment: ${controller.prevOrderList[index].paymentType}',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText({
    Key key,
    @required this.screenSize,
    @required this.title,
    this.isBold = false,
  }) : super(key: key);

  final Size screenSize;
  final String title;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: screenSize.width * 0.016,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
