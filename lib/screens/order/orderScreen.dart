import 'package:dropin_pos_v2/screens/order/bill.dart';
import 'package:flutter/material.dart';

import 'menu.dart';

class OrderScreen extends StatelessWidget {
  final orderId;
  final tableId;
  final tableName;
  final cusMobile;
  final cusName;
  final seats;
  final isReOrder;
  final dateStamp;
  final orderTime;
  final bool dineIn;
  final bool takeAway;
  const OrderScreen(
      {Key key,
      this.cusMobile,
      this.cusName,
      this.seats = 1,
      this.tableName,
      this.tableId,
      this.orderId,
      this.isReOrder,
      this.orderTime,
      this.dineIn,
      this.takeAway,
      this.dateStamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Menu(),
          ),
          Expanded(
            flex: 1,
            child: Bill(
              orderId: orderId,
              cusMobile: cusMobile,
              tableId: tableId,
              tableName: tableName.toString(),
              cusName: cusName,
              seats: seats,
              isReOrder: isReOrder,
              orderTime: orderTime,
              dateStamp: dateStamp,
              dineIn: dineIn,
              takeAway: takeAway,
            ),
          ),
        ],
      ),
    );
  }
}
