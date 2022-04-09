import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:blur/blur.dart';

class OrderPreviewButton extends StatefulWidget {
  const OrderPreviewButton({
    Key key,
    @required this.screenSize,
    @required this.orderId,
    @required this.docId,
    @required this.time,
    @required this.date,
    @required this.name,
    @required this.address,
    @required this.isOrange,
    @required this.isBlur,
    @required this.onTap,
    @required this.mobile,
    this.onIconPressed,
    this.index,
    @required this.controller,
    this.table,
  }) : super(key: key);

  final Size screenSize;
  final String orderId, time, name, table, mobile, address, date, docId;
  final bool isOrange, isBlur;
  final Function onTap, onIconPressed;
  final int index;
  final controller;

  @override
  State<OrderPreviewButton> createState() => _OrderPreviewButtonState();
}

class _OrderPreviewButtonState extends State<OrderPreviewButton> {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    OrderController orderController = Get.put(OrderController());
    orderController.getPrevOrder(widget.orderId, widget.date);
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: widget.screenSize.width * 0.003),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: widget.onIconPressed,
                  icon: Icon(
                    widget.isBlur == true
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                    color: Palette.white,
                  ),
                ),
              ],
            ),
            // orderId and time
            Text(
              '${widget.orderId} | ${widget.time}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Palette.white,
              ),
            ),
            // name
            Flexible(
              flex: 1,
              child: Text(
                widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                  color: Palette.white,
                ),
              ),
            ),
            SizedBox(height: widget.screenSize.height * 0.01),
            // table
            Visibility(
              visible: widget.table != '',
              child: Flexible(
                flex: 1,
                child: Text(
                  'Table ' + widget.table,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Palette.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.screenSize.height * 0.01),
            // mobile
            BurrableText(
                txtStr: widget.mobile,
                blurColor: Colors.deepOrange,
                isBlur: widget.isBlur),
            SizedBox(height: widget.screenSize.height * 0.01),
            // address
            BurrableText(
              txtStr: widget.address,
              blurColor: Colors.deepOrange,
              isBlur: widget.isBlur,
              maxLines: 3,
            ),
            SizedBox(height: widget.screenSize.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 10,
                  child: TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection(authController.shopName.toString())
                          .doc("onlineOrders")
                          .collection('completedOrders')
                          .doc(widget.orderId)
                          .set({
                        'name': widget.name,
                        'orderId': widget.orderId,
                        'mobile': widget.mobile,
                        'address': widget.address,
                        'date': widget.date,
                        'time': widget.time,
                        'isDelivery': widget.isOrange,
                        'server': authController.userName.toString(),
                      }).then((value) async {
                        await FirebaseFirestore.instance
                            .collection(authController.shopName.toString())
                            .doc("onlineOrders")
                            .collection('activeOrders')
                            .doc(widget.docId)
                            .delete();
                      });
                    },
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: widget.screenSize.width * 0.014,
                        fontWeight: FontWeight.bold,
                        color: Palette.primaryColor,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection(authController.shopName.toString())
                          .doc("onlineOrders")
                          .collection('activeOrders')
                          .doc(widget.docId)
                          .update({
                        "isDelivery": true,
                        // "Status" : status,
                      });
                    },
                    child: Text(
                      'Ready',
                      style: TextStyle(
                        fontSize: widget.screenSize.width * 0.014,
                        fontWeight: FontWeight.bold,
                        color: Palette.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        decoration: BoxDecoration(
          color: widget.isOrange == false ? Colors.deepOrange : Colors.green,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class BurrableText extends StatelessWidget {
  const BurrableText({
    Key key,
    @required this.txtStr,
    this.isBlur,
    this.colorOpacity = 0,
    @required this.blurColor,
    this.maxLines = 1,
  }) : super(key: key);

  final String txtStr;
  final double colorOpacity;
  final Color blurColor;
  final int maxLines;
  final bool isBlur;

  @override
  Widget build(BuildContext context) {
    return Blur(
      blur: isBlur ? 4 : 0,
      blurColor: blurColor,
      colorOpacity: colorOpacity,
      borderRadius: BorderRadius.circular(10),
      child: Text(
        txtStr,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Palette.white,
        ),
      ),
    );
  }
}
