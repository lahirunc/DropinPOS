import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/models/cartModel.dart';
import 'package:dropin_pos_v2/models/lastOrderModel.dart';
import 'package:dropin_pos_v2/screens/order/orderScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DineController extends GetxController {
  var cusName = '';
  var cusMobile = '';
  var guests = '';
  var address = '';
  var lastOrder = <LastOrderModel>[].obs;
  var reorderData;
  var orderTime;
  var exists = false;
  var isPreviousOrder = false;
  var previousOrderList = <CartModel>[].obs;

  final authController = Get.find<AuthController>();

  routeToMenu(
    String orderId,
    String tableName,
    String cusName,
    String cusMobile,
    String tableId,
    String guests,
    bool isReOrder,
    String dateStamp,
    bool dineIn,
  ) async {
    try {
      if (!exists && !isReOrder && cusMobile.isNotEmpty) {
        addCustomer(cusName, cusMobile, '');
      }

      // if (isReOrder) {
      //   orderController.cartList.clear();
      // }

      FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc("/tableDetails")
          .collection('TableNo')
          .doc(tableId)
          .set(
        {
          'isLocked': true,
          'Status': 'Occupied',
        },
        SetOptions(merge: true),
      ).then(
        (value) {
          Get.back();

          if (isPreviousOrder) {
            Get.back();
          }
          Get.to(
            () => OrderScreen(
              orderId: orderId,
              cusName: cusName,
              tableName: tableName,
              tableId: tableId,
              cusMobile: cusMobile,
              seats: guests != '' ? guests : 1,
              isReOrder: isReOrder,
              dateStamp: dateStamp,
              dineIn: true,
              takeAway: false,
            ),
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error adding IP',
        'Something went wrong! Please try again.\n${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.primaryColor,
        colorText: Palette.white,
      );
    }
  }

  routeToMenuFromTakeAwayDelivery(
    String orderId,
    String tableName,
    String cusName,
    String cusMobile,
    bool isReOrder,
    String dateStamp,
    String takeAwayTime,
    bool takeAway,
    bool dineIn,
  ) {
    print('OrderScreen $orderId');
    Get.back();
    Get.to(
      () => OrderScreen(
        orderId: orderId,
        cusName: cusName,
        tableName: tableName,
        cusMobile: cusMobile,
        isReOrder: isReOrder,
        dateStamp: dateStamp,
        orderTime: takeAwayTime,
        takeAway: takeAway,
        dineIn: dineIn,
      ),
    );
  }

  Future getTableData(String orderId, String date) async {
    try {
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('kitchenOrderTicket')
          .collection(date)
          .doc(orderId)
          .get();

      cusName = data['customerName'];
      cusMobile = data['customerNumber'];
      guests = data['guestNumber'].toString();
      update();
    } catch (e) {}
  }

  Future getTakeAwayData(
    String orderId,
  ) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('takeWay')
        .collection('takeWayDetails')
        .doc(orderId)
        .get();

    cusName = data['name'];
    cusMobile = data['MobileNumber'];
    orderTime = data['time'].toString();
    update();
  }

  Future getDeliveryData(
    String orderId,
  ) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('Delivery')
        .collection('DeliveryDetails')
        .doc(orderId)
        .get();

    cusName = data['name'];
    cusMobile = data['MobileNumber'];
    orderTime = data['time'].toString();
    update();
  }

  // sending back
  routeBack(String tableId) async {
    try {
      FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc("/tableDetails")
          .collection('TableNo')
          .doc(tableId)
          .set(
        {
          'isLocked': false,
          'Status': '',
        },
        SetOptions(merge: true),
      ).then((value) {
        Get.back();
      });
    } catch (e) {}
  }

  // add new customer to the system
  addCustomer(String name, String mobile, String address) async {
    try {
      await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('CustomerDatabase')
          .collection('CustomerInfo')
          .doc(mobile)
          .set(
        {
          'name': name,
          'mobile': mobile,
          'address': address,
        },
        SetOptions(merge: true),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  // check if mobile number exist and if exists update name and address
  readCustomerData(String mobile) async {
    lastOrder.clear();
    cusMobile = mobile;

    if (mobile.isNotEmpty) {
      try {
        CollectionReference cusRef = FirebaseFirestore.instance
            .collection(authController.shopName.toString())
            .doc('CustomerDatabase')
            .collection('CustomerInfo');

        var cusDoc = await cusRef.doc(mobile).get();

        if (cusDoc.exists) {
          exists = true;
          Map<String, dynamic> map = cusDoc.data();
          cusName = map['name'];

          if (map.containsKey('address')) {
            var valueOfField = map['address'];

            if (valueOfField.toString().isNotEmpty) {
              address = valueOfField;
            }
          }

          if (map.containsKey('lastOrder') && map['lastOrder'].length > 0) {
            for (var order in map['lastOrder']) {
              lastOrder.add(LastOrderModel(order));
            }
          }
        } else {
          exists = false;
          cusName = '';
        }
      } catch (e) {
        print(e);
      }

      update();
    }
  }

  // adding customer last order to the order menu
  addCustomersLastOrder(
    String orderId,
    String tableName,
    String cusName,
    String cusMobile,
    String tableId,
    String guests,
    bool isReOrder,
    String dateStamp,
    bool dineIn,
  ) async {
    try {
      // final orderController = Get.find<OrderController>();

      // orderController.cartList.clear();
      QuerySnapshot menuSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc("/itemDetails")
          .collection('items')
          .orderBy('name')
          .get();

      for (var i = 0; i < lastOrder.length; i++) {
        List<String> _attribNames = [];
        List<double> _attribPrice = [];
        if (lastOrder[i].isSelected) {
          for (var item in menuSnap.docs) {
            if (item['name'] == lastOrder[i].name) {
              var _cartList = CartModel(
                1,
                double.parse(item['price'].toString()),
                lastOrder[i].name,
                '',
                _attribNames,
                _attribPrice,
                false,
                false,
                item['cat'].toString().toLowerCase().contains('pizza'),
                item['cat'].toString().toLowerCase().contains('combo'),
                item['printer'] == null
                    ? 2
                    : int.parse(item['printer'].toString()),
              );

              previousOrderList.add(_cartList);
            }
          }
        }
      }
      isPreviousOrder = true;
    } on Exception catch (e) {
      print(e);
    }

    routeToMenu(
      orderId,
      tableName,
      cusName,
      cusMobile,
      tableId,
      guests,
      isReOrder,
      dateStamp,
      true,
    );
  }
}
