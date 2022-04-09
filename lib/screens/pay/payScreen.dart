import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'amount.dart';
import 'receipt.dart';

class PayScreen extends StatelessWidget {
  final orderId;
  final cusName;
  final cusMobile;
  final tableName;
  final date;
  final tableId;
  final bool dineIn;
  final bool takeAway;

  const PayScreen({
    Key key,
    this.tableName,
    this.date,
    this.cusName,
    this.orderId,
    this.tableId,
    this.cusMobile,
    this.takeAway,
    this.dineIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PayController>(
      init: PayController(),
      builder: (payController) {
        payController.cusName = cusName;
        payController.cusMobile = cusMobile;
        payController.getPrevOrder(orderId, date);
        return Scaffold(
          backgroundColor: Palette.blueGrey,
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Receipt(
                    payController: payController,
                    tableName: tableName,
                    orderId: orderId,
                    date: date,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Amount(
                    tableName: tableName,
                    tableId: tableId,
                    orderId: orderId,
                    date: date,
                    payController: payController,
                    dineIn:dineIn ,
                    takeAway: takeAway,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
