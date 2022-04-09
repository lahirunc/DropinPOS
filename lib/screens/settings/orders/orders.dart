import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../localWidgets/header.dart';
import 'order_body.dart';

class Orders extends StatelessWidget {
  const Orders({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      initState: (_) {},
      builder: (_) {
        // _.prevOrderList.bindStream(_.getPeviousOrders());
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Palette.black,
              title: Header(
                screenSize: screenSize,
                title: 'Previous Orders',
              ),
            ),
            body: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
              child: Column(
                children: [
                  // Expanded(
                  //   flex: 1,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       Text(
                  //         'Order Type: ',
                  //         style: TextStyle(
                  //             fontSize: screenSize.width * 0.016,
                  //             color: Palette.mediumGrey),
                  //       ),
                  //       Text(
                  //         'Date: ',
                  //         style: TextStyle(
                  //             fontSize: screenSize.width * 0.016,
                  //             color: Palette.mediumGrey),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Divider(),
                  OrderBody(
                    screenSize: screenSize,
                    controller: _,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
