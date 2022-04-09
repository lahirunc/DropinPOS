import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var tabIndex = 0;

  final authController = Get.find<AuthController>();

  
  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }
}
