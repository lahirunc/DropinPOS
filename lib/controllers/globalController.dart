import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GlobalController extends GetxController {
  var orderId = '';
  var currDateDashDelimated = DateFormat('dd-MM-yyyy')
      .format(DateTime.parse(DateTime.now().toString()));
  var currTime = DateFormat('hh:mm a').format(DateTime.now());
  var currDateTimeSlashed =
      DateFormat('dd/MM/yy').add_jm().format(DateTime.now()).toString();

  final authController = Get.find<AuthController>();

  @override
  void onInit() {
    getOrderId();
    super.onInit();
  }

  //get orderId
  Future<String> getOrderId() async {
    await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('consts')
        .set({'orderId': FieldValue.increment(1)}, SetOptions(merge: true));

    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('consts')
        .get();

    orderId = (data.get('orderId')).toString().padLeft(6, '0');
    update();
    return orderId;
  }
}
