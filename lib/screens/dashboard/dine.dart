import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/dineController.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/screens/pay/payScreen.dart';
import 'package:dropin_pos_v2/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Dine extends StatelessWidget {
  const Dine({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _tableName;
    String _status;
    int _seats;

    Size screenSize = MediaQuery.of(context).size;
    AuthController authController = Get.find<AuthController>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        0.0,
        screenSize.height * 0.01,
        screenSize.height * 0.02,
        0,
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(authController.shopName.toString())
            .doc("/tableDetails")
            .collection('TableNo')
            .orderBy('Name')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Loader(),
            );
          }

          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              _tableName = snapshot.data.docs[index]['Name'].toString();
              _seats =
                  int.parse(snapshot.data.docs[index]['NoOfGuests'].toString());
              _status = snapshot.data.docs[index]['Status'];

              return InkWell(
                onLongPress: () {
                  FirebaseFirestore.instance
                      .collection(authController.shopName.toString())
                      .doc('tableDetails')
                      .collection('TableNo')
                      .doc(snapshot.data.docs[index].id)
                      .set({
                    'isLocked': false,
                    'Status': snapshot.data.docs[index]['orderId'] != ''
                        ? snapshot.data.docs[index]['Status']
                        : '',
                  }, SetOptions(merge: true));
                },
                onTap: () async {
                  try {
                    if (!snapshot.data.docs[index]['isLocked']) {
                      String _orderId;
                      final dineController = Get.put(DineController());
                      GlobalController globalController =
                          Get.find<GlobalController>();

                      String _tableId = snapshot.data.docs[index].id;
                      _tableName = snapshot.data.docs[index]['Name'].toString();
                      _seats = int.parse(
                          snapshot.data.docs[index]['NoOfGuests'].toString());
                      _status = snapshot.data.docs[index]['Status'];

                      if (snapshot.data.docs[index]['orderId']
                          .toString()
                          .isNotEmpty) {
                        _orderId = snapshot.data.docs[index]['orderId'];
                      } else {
                        globalController.getOrderId();
                        _orderId = globalController.orderId.toString();
                      }

                      String _orderDate =
                          snapshot.data.docs[index]['dateStamp'] ?? '';

                      if (_status.toString() == 'Occupied' ||
                          _status.toString() == 'Hold') {
                        orderPopup(
                          context,
                          screenSize,
                          _tableId,
                          _tableName,
                          _seats,
                          true,
                          dineController,
                          _orderId,
                          _orderDate,
                          'DI',
                        );
                      } else {
                        orderPopup(
                          context,
                          screenSize,
                          _tableId,
                          _tableName,
                          _seats,
                          false,
                          dineController,
                          _orderId,
                          _orderDate,
                          'DI',
                        );
                      }
                    } else {
                      Get.snackbar(
                        'Active table',
                        'Table is being served as we speak...',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Palette.white,
                        backgroundColor: Palette.primaryColor,
                      );
                    }
                  } on FirebaseException catch (e) {
                    Get.snackbar(
                      'Something went wrong!',
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Palette.white,
                      backgroundColor: Palette.primaryColor,
                    );
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      _status.toString() == 'Occupied'
                          ? "assets/images/tables/orange${_seats.toString()}.png"
                          : _status.toString() == 'Hold'
                              ? "assets/images/tables/yellow${_seats.toString()}.png"
                              : "assets/images/tables/white${_seats.toString()}.png",
                    ),
                    Positioned(
                      top: screenSize.height * 0.1,
                      child: Text(
                        _tableName.toString(),
                        style: TextStyle(
                          color: _status.toString() == ''
                              ? Colors.black87
                              : Palette.white,
                          fontSize: screenSize.width * 0.018,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  orderPopup(
    BuildContext context,
    Size screenSize,
    String tableId,
    String tableName,
    int seats,
    bool isReOrder,
    DineController dineController,
    String orderId,
    String orderDate,
    String orderType,
  ) async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _mobileController = TextEditingController();
    TextEditingController _guestController = TextEditingController();
    TextEditingController _nameController = TextEditingController();

    if (isReOrder) {
      try {
        await dineController.getTableData(orderId, orderDate);
        _nameController.text = dineController.cusName.toString();
        _mobileController.text = dineController.cusMobile.toString();
        _guestController.text = dineController.guests;
      } catch (e) {
        Get.snackbar(
          'Empty table!',
          'Please give it a second to update.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
        await dineController.routeBack(tableId);
      }
    }

    return Get.defaultDialog(
      title: 'Table ${tableName.toString()}',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: screenSize.width * 0.022,
      ),
      content: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Focus(
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    controller: _mobileController,
                    enabled: !isReOrder,
                    decoration: InputDecoration(
                      hintText: 'Mobile No.',
                      labelStyle: TextStyle(color: Palette.black),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: screenSize.width * 0.025,
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: screenSize.width * 0.014,
                      color: isReOrder ? Palette.mediumGrey : Palette.black,
                    ),
                  ),
                  onFocusChange: (hasfocus) async {
                    if (!hasfocus) {
                      await dineController
                          .readCustomerData(_mobileController.text.trim());

                      _nameController.text = dineController.cusName;

                      if (dineController.lastOrder.length > 0) {
                        showLastOrderPopup(
                            context,
                            screenSize,
                            dineController,
                            orderId,
                            tableName,
                            _nameController,
                            _mobileController,
                            tableId,
                            _guestController,
                            isReOrder,
                            orderDate);
                      }
                    } else {
                      _nameController.clear();
                    }
                  },
                ),
                Divider(),
                TextFormField(
                  validator: (String value) {
                    if (value.length < 3)
                      return " Enter at least 3 character from Customer Name";
                    else
                      return null;
                  },
                  controller: _nameController,
                  enabled: !isReOrder,
                  decoration: InputDecoration(
                    hintText: 'Name\*',
                    labelStyle: TextStyle(color: Palette.black),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: screenSize.width * 0.025,
                      color: Colors.black54,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: screenSize.width * 0.014,
                    color: isReOrder ? Palette.mediumGrey : Palette.black,
                  ),
                ),
                Divider(),
                TextFormField(
                  controller: _guestController,
                  enabled: !isReOrder,
                  decoration: InputDecoration(
                    hintText: 'No. of guests (Max. ${seats.toString()})',
                    labelStyle: TextStyle(color: Palette.black),
                    prefixIcon: Icon(Icons.group_outlined,
                        size: screenSize.width * 0.025, color: Colors.black54),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: screenSize.width * 0.014,
                    color: isReOrder ? Palette.mediumGrey : Palette.black,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (value) {
                    if (int.parse(value) <= 0 || int.parse(value) > seats) {
                      _guestController.clear();
                    }
                  },
                ),
                Divider(),
                // buttons
                Row(
                  children: [
                    // Skip button
                    !isReOrder
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Palette.mediumGrey,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.024,
                                vertical: screenSize.width * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            onPressed: () => dineController.routeToMenu(
                              orderId,
                              tableName.toString(),
                              'Guest - ${tableName.toString()}',
                              _mobileController.text,
                              tableId,
                              _guestController.text,
                              isReOrder,
                              orderDate,
                              true,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.014,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    // Tap to order button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Palette.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.035,
                          vertical: screenSize.width * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          dineController.routeToMenu(
                            orderId,
                            tableName,
                            _nameController.text,
                            _mobileController.text,
                            tableId,
                            _guestController.text,
                            isReOrder,
                            orderDate,
                            true,
                          );
                        }
                      },
                      child: Text(
                        'Tap to order',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.014,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //Pay Button
                    isReOrder
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.035,
                                vertical: screenSize.width * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                              Get.to(
                                () => PayScreen(
                                  orderId: orderId,
                                  cusName: _nameController.text,
                                  cusMobile: _mobileController.text,
                                  tableName: tableName,
                                  tableId: tableId,
                                  date: orderDate,
                                  takeAway: false,
                                  dineIn: true,
                                ),
                              );
                            },
                            child: Text(
                              'Pay',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.014,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showLastOrderPopup(
      BuildContext mainContext,
      Size screenSize,
      DineController dineController,
      String orderId,
      String tableName,
      TextEditingController _nameController,
      TextEditingController _mobileController,
      String tableId,
      TextEditingController _guestController,
      bool isReOrder,
      String orderDate) {
    showDialog(
      context: mainContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Do you want the previous order?'),
              content: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                height: screenSize.height * 0.8,
                width: screenSize.width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 11,
                      child: ListView.builder(
                        itemCount: dineController.lastOrder.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.all(screenSize.width * 0.002),
                            child: Row(
                              children: [
                                Checkbox(
                                  checkColor: Palette.white,
                                  activeColor: Palette.secondaryColor,
                                  value: dineController
                                      .lastOrder[index].isSelected,
                                  onChanged: (value) {
                                    dineController.lastOrder[index].isSelected =
                                        !dineController
                                            .lastOrder[index].isSelected;
                                    dineController.update();
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  dineController.lastOrder[index].name,
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.016,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.1,
                                vertical: screenSize.width * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: Text('No'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Palette.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.1,
                                vertical: screenSize.width * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                            onPressed: () async =>
                                await dineController.addCustomersLastOrder(
                              orderId,
                              tableName,
                              _nameController.text.trim(),
                              _mobileController.text.trim(),
                              tableId,
                              _guestController.text.trim(),
                              isReOrder,
                              orderDate,
                              true,
                            ),
                            child: Text('Yes'),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
