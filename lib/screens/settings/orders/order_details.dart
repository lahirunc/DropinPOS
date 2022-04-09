import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:dropin_pos_v2/screens/settings/localWidgets/header.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'order_details_body.dart';
import 'order_details_header.dart';

class OrderDetails extends StatelessWidget {
  const OrderDetails(
      {Key key, @required this.itemIndex, this.screenSize, this.controller})
      : super(key: key);

  final int itemIndex;
  final Size screenSize;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Palette.black,
        title: Header(
          screenSize: screenSize,
          title: 'Order #' + controller.prevOrderList[itemIndex].id,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.height * 0.04,
        ),
        child: Column(
          children: [
            OrderDetailsHeader(
              screenSize: screenSize,
              controller: controller,
              itemIndex: itemIndex,
            ),
           OrderDetailsBody(screenSize: screenSize, controller: controller, itemIndex: itemIndex)
          ],
        ),
      ),
    );
  }
}
