
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/models/cartModel.dart';
import 'package:dropin_pos_v2/models/orderModel.dart';

import 'package:get/get.dart';

class OnlineOrderController extends GetxController {
  static OnlineOrderController instance = Get.find();

  var tabIndex = 0;
  var orderPreviewList = <OnlineOrderModel>[];
  var cartItems = <CartModel>[];
  var isBlur = [].obs;
  // var isOrange = [].obs;
  final authController = Get.find<AuthController>();

  @override
  void onInit() async {
    // await getOnlineOrders();
    super.onInit();
  }

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  // Future<void> getOnlineOrders() async {
  //   try {
  //     QuerySnapshot onlineOrdersSnap = await FirebaseFirestore.instance
  //         .collection(authController.shopName.toString())
  //         .doc('onlineOrders')
  //         .collection('activeOrders')
  //         .get();
  //
  //     orderPreviewList.clear();
  //
  //
  //     for (var order in onlineOrdersSnap.docs) {
  //       isBlur.add(true);
  //       isOrange.add(true);
  //       print('orderID ${order.id}');
  //       orderPreviewList.add(
  //         OnlineOrderModel(
  //           order['orderId'],
  //           order['time'],
  //           order['isDelivery'],
  //           order['address'],
  //           order['date'],
  //           order['name'],
  //           order['mobile'],
  //           order.id,
  //           isVisible: true,
  //         ),
  //       );
  //     }
  //     update();
  //   } catch (e) {
  //     Get.snackbar('Error occured!', e.toString(),
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Palette.primaryColor,
  //         colorText: Palette.white);
  //   }
  // }
}
