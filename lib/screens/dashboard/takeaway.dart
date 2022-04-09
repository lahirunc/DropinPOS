import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';

import '../../controllers/authController.dart';
import '../../controllers/dineController.dart';
import '../../controllers/globalController.dart';

import '../pay/payScreen.dart';

class TakeAway extends StatefulWidget {
  const TakeAway({Key key}) : super(key: key);

  @override
  _TakeAwayState createState() => _TakeAwayState();
}

class _TakeAwayState extends State<TakeAway> {
  final globalController = Get.find<GlobalController>();
  String currentTime;
  String orderId;
  var order;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  // TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  Future<Null> _selectTime(BuildContext context, StateSetter setstate) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setstate(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    currentTime = DateFormat('hh:mm a').format(
      DateTime.now(),
    );

    AuthController authController = Get.put(AuthController());
    GlobalController globalController = Get.put(GlobalController());
    DineController dineController = Get.put(DineController());

    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate =
        DateFormat('dd-MM-yyyy').format(DateTime.parse(dateParse.toString()));
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Palette.primaryColor,
          onPressed: () {
            globalController.getOrderId();
            orderId = globalController.orderId;
            orderPopup(context, screenSize, 'Take Away', false, dineController,
                orderId, '', 'TA', AuthController());
            print('orderId $orderId');
          },
          child: Icon(
            Icons.add,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.only(
                  top: screenSize.height * 0.01,
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenSize.width * 0.02),
                    buildLegend(screenSize, Palette.primaryColor, 'Preparing'),
                    SizedBox(width: screenSize.width * 0.05),
                    buildLegend(screenSize, Colors.green, 'Waiting'),
                    Spacer(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: buildBody(screenSize, formattedDate, authController),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(Size screenSize, String formattedDate,
          AuthController authController) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(authController.shopName.toString())
              .doc("takeWay")
              .collection('takeWayDetails')
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
                  mainAxisExtent: screenSize.height * 0.13,
                  crossAxisSpacing: screenSize.width * 0.01,
                  mainAxisSpacing: screenSize.height * 0.02,
                ),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext ctx, index) {
                  return InkWell(
                    onTap: () {
                      // dialog( filteredDocs[index]['orderId']);
                      final dineController = Get.put(DineController());
                      final authController = Get.put(AuthController());
                      orderPopup(
                          context,
                          screenSize,
                          'Take Away',
                          true,
                          dineController,
                          filteredDocs[index]['orderId'],
                          filteredDocs[index]['dateStamp'],
                          'TA',
                          authController);
                    },
                    onLongPress: () {},
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            filteredDocs[index]['orderId'],
                            style: TextStyle(
                              fontSize:
                                  snapshot.data.docs.length != 0 ? 20 : 40,
                              fontWeight: FontWeight.normal,
                              color: Palette.white,
                            ),
                          ),
                          Text(
                            '${filteredDocs[index]["name"]} | ${filteredDocs[index]["time"]}',
                            style: TextStyle(
                              fontSize:
                                  snapshot.data.docs.length != 0 ? 24 : 40,
                              fontWeight: FontWeight.normal,
                              color: Palette.white,
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: (filteredDocs[index]["preparing"] == '0')
                            ? Colors.deepOrange
                            : Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                });
          },
        ),
      );

  void showLastOrderPopup(
      BuildContext mainContext,
      Size screenSize,
      DineController dineController,
      String orderId,
      String tableName,
      TextEditingController _nameController,
      TextEditingController _mobileController,
      String tableId,
      String _guestController,
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
                              _guestController,
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

  orderPopup(
    BuildContext context,
    Size screenSize,
    String tableName,
    bool isReOrder,
    DineController dineController,
    String orderId,
    String orderDate,
    String orderType,
    AuthController authController,
  ) async {
    print('orderId $orderId');
    final _formKey = GlobalKey<FormState>();
    TextEditingController _mobileController = TextEditingController();
    // TextEditingController _guestController = TextEditingController();
    TextEditingController _nameController = TextEditingController();

    if (isReOrder) {
      await dineController.getTakeAwayData(
        orderId,
      );
      _nameController.text = dineController.cusName.toString();
      _mobileController.text = dineController.cusMobile.toString();
      _timeController.text = dineController.orderTime;
    }

    _timeController.text =
        DateFormat('hh:mm a').format(DateTime.now().add(Duration(minutes: 15)));

    return Get.defaultDialog(
      title: 'Table ${tableName.toString()}',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: screenSize.width * 0.022,
      ),
      content: StatefulBuilder(builder: (context, StateSetter setstate) {
        return Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Focus(
                    child: TextFormField(
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
                              'Take Away',
                              '0',
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
                  Visibility(visible: isReOrder, child: Divider()),
                  Visibility(
                    visible: isReOrder,
                    child: TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection(authController.shopName.toString())
                            .doc("takeWay")
                            .collection('takeWayDetails')
                            .doc(orderId)
                            .update({
                          "preparing": "1",
                          // "Status" : status,
                        }).then((value) => Get.back());
                      },
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.014,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Divider(),

                  InkWell(
                    onTap: () {
                      _selectTime(context, setstate);
                    },
                    child: Row(
                      children: [
                        SizedBox(width: screenSize.width * .005),
                        Icon(
                          Icons.access_time_outlined,
                          color: Colors.black54,
                          size: screenSize.width * 0.023,
                        ),
                        SizedBox(width: screenSize.width * .01),
                        Text(
                          _timeController.text,
                          style: TextStyle(fontSize: screenSize.width * 0.014),
                        ),
                      ],
                    ),
                  ),
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
                              onPressed: () => dineController
                                  .routeToMenuFromTakeAwayDelivery(
                                orderId,
                                tableName,
                                'Guest',
                                _mobileController.text,
                                isReOrder,
                                orderDate,
                                _timeController.text,
                                true,
                                false,
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
                            dineController.routeToMenuFromTakeAwayDelivery(
                              orderId,
                              tableName,
                              _nameController.text,
                              _mobileController.text,
                              isReOrder,
                              orderDate,
                              _timeController.text,
                              true,
                              false,
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
                                    date: orderDate,
                                    dineIn: false,
                                    takeAway: true,
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
        );
      }),
    );
  }

  Widget buildLegend(Size screenSize, Color color, String textStr) => Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: screenSize.width * 0.01,
          ),
          SizedBox(
            width: screenSize.width * 0.008,
          ),
          Text(
            textStr,
            style: TextStyle(fontSize: screenSize.width * 0.018),
          ),
        ],
      );
}
