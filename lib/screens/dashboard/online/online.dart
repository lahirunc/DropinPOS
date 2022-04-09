import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/onlineOrderController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/screens/dashboard/localWidgets/legendBar.dart';
import 'package:dropin_pos_v2/screens/dashboard/localWidgets/orderPreviewButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Online extends StatelessWidget {
  const Online({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    AuthController authController = Get.put(AuthController());
    OrderController orderController = Get.put(OrderController());
    return GetBuilder<OnlineOrderController>(
      init: OnlineOrderController(),
      builder: (controller) {
        return Column(
          children: [
            LegendBar(screenSize: screenSize),
            Expanded(
              flex: 8,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(authController.shopName.toString())
                        .doc("onlineOrders")
                        .collection('activeOrders')
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      var filteredDocs = [];
                      if (!snapshot.hasData) {
                        return Center(
                          child: SpinKitFadingCircle(
                            color: Colors.orange[200],
                            size: 50.0,
                          ),
                        );
                      }

                      filteredDocs = snapshot.data.docs;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: screenSize.width * 0.3,
                          mainAxisExtent: screenSize.height * 0.38,
                          crossAxisSpacing: screenSize.width * 0.01,
                          mainAxisSpacing: screenSize.height * 0.01,
                        ),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext ctx, index) {
                          controller.isBlur.add(true);
                          print('controller.isBlur}');
                          return Obx(
                            () => OrderPreviewButton(
                              controller: controller,
                              screenSize: screenSize,
                              orderId: filteredDocs[index]['orderId'],
                              time: filteredDocs[index]["time"],
                              date: filteredDocs[index]["date"],
                              name: filteredDocs[index]["name"],
                              table: filteredDocs[index]['table'] != ''
                                  ? filteredDocs[index]['table'].toString()
                                  : '',
                              mobile: filteredDocs[index]['mobile'],
                              address: filteredDocs[index]['address'],
                              isOrange: filteredDocs[index]["isDelivery"],
                              isBlur: controller.isBlur[index],
                              docId: filteredDocs[index].id,
                              onTap: () async {
                                orderController.cartList.clear();
                                orderController.isRead = false;
                                await orderController.getPrevOrder(
                                    filteredDocs[index]['orderId'],
                                    filteredDocs[index]["date"]);
                                Get.defaultDialog(
                                  barrierDismissible: false,
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            for (var item
                                                in orderController.cartList) {
                                              item.isRead = false;
                                            }

                                            List printerList = [
                                              'posPrinter',
                                              'kotPrinter',
                                              'kot2Printer',
                                              'kot3Printer'
                                            ];

                                            for (var printer in printerList) {
                                              await orderController.printTicket(
                                                filteredDocs[index]['orderId'],
                                                'Online Order',
                                                filteredDocs[index]["name"],
                                                printer.toString(),
                                                true,
                                                orderController.cartList,
                                              );
                                            }

                                            Get.delete<OrderController>();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Palette.secondaryColor,
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  screenSize.width * 0.06,
                                              vertical:
                                                  screenSize.width * 0.014,
                                            ),
                                          ),
                                          child: Text(
                                            'Print KOT',
                                            style: TextStyle(
                                                fontSize:
                                                    screenSize.width * 0.014),
                                          ),
                                        ),
                                        SizedBox(
                                            width: screenSize.width * 0.01),
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            Get.delete<OrderController>();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  screenSize.width * 0.06,
                                              vertical:
                                                  screenSize.width * 0.014,
                                            ),
                                          ),
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                    // Align(
                                    //     alignment: Alignment.bottomRight,
                                    //     child: InkWell(
                                    //       onTap: () {
                                    //         Get.back();
                                    //       },
                                    //       child: Card(
                                    //         color: Colors.red,
                                    //         child: Padding(
                                    //           padding:
                                    //               const EdgeInsets.all(8.0),
                                    //           child: Text(
                                    //             'Cancel',
                                    //             style: TextStyle(
                                    //                 color: Colors.white),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ))
                                  ],
                                  title:
                                      'Order - ${filteredDocs[index]['orderId']}',
                                  titleStyle:
                                      TextStyle(color: Palette.primaryColor),
                                  content: buildItemList(
                                      screenSize,
                                      orderController,
                                      authController,
                                      filteredDocs[index]["date"],
                                      filteredDocs[index]['orderId']),
                                );
                              },
                              onIconPressed: () {
                                // controller.orderPreviewList[index].isVisible = false;
                                controller.isBlur[index] =
                                    !controller.isBlur[index];
                                Future.delayed(
                                  Duration(seconds: 5),
                                  () {
                                    controller.isBlur[index] = true;
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildItemList(Size screenSize, OrderController controller,
          AuthController authController, var date, var orderId) =>
      Container(
        height: 500,
        width: 500,
        // padding: EdgeInsets.symmetric(
        //   horizontal: screenSize.width * 0.01,
        //   vertical: screenSize.height * 0.01,
        // ),
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection(authController.shopName.toString())
                .doc('kitchenOrderTicket')
                .collection(date)
                .doc(orderId)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SpinKitFadingCircle(
                    color: Colors.orange[200],
                    size: 50.0,
                  ),
                );
              }

              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  height: 10,
                ),
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.02),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            controller.cartList[index].name
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            maxLines: 5,
                                            // textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  screenSize.width * 0.016,
                                              decoration: controller
                                                      .cartList[index].isVoid
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: controller.cartList[index]
                                                          .isVoid ||
                                                      controller.cartList[index]
                                                          .isRead
                                                  ? Palette.darkGrey
                                                  : Palette.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    controller.cartList[index].notes
                                                .toString() !=
                                            ''
                                        ? Text(
                                            'Notes: ' +
                                                controller.cartList[index].notes
                                                    .toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: controller.cartList[index]
                                                          .isVoid ||
                                                      controller.cartList[index]
                                                          .isRead
                                                  ? Palette.darkGrey
                                                  : Palette.black,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    controller.cartList[index].attribNameList
                                                .length >
                                            0
                                        ? Text(
                                            '- ' +
                                                controller.cartList[index]
                                                    .attribNameList
                                                    .join('\n- ')
                                                    .toString(),
                                            style: TextStyle(
                                              decoration: controller
                                                      .cartList[index].isVoid
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: controller.cartList[index]
                                                          .isVoid ||
                                                      controller.cartList[index]
                                                          .isRead
                                                  ? Palette.darkGrey
                                                  : Palette.black,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    SizedBox(height: screenSize.height * 0.02),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                controller.cartList[index].qty.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenSize.width * 0.016,
                                  decoration: controller.cartList[index].isVoid
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: controller.cartList[index].isVoid ||
                                          controller.cartList[index].isRead
                                      ? Palette.darkGrey
                                      : Palette.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                // '\$${((controller.cartList[index].price + controller.cartList[index].attribPriceList.fold(0, (sum, attrib) => sum + attrib)) * controller.cartList[index].qty).toStringAsFixed(2)}',
                                '\$${controller.cartList[index].price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.016,
                                  fontWeight: FontWeight.bold,
                                  decoration: controller.cartList[index].isVoid
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: controller.cartList[index].isVoid ||
                                          controller.cartList[index].isRead
                                      ? Palette.darkGrey
                                      : Palette.black,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            }),
      );
}
