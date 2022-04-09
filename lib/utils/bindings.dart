import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/dashboardController.dart';
import 'package:dropin_pos_v2/controllers/dineController.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => OrderController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => GlobalController(), fenix: true);
    Get.lazyPut(() => DineController(), fenix: true);
    Get.lazyPut(() => PayController(), fenix: true);
    Get.lazyPut(() => SettingsController(), fenix: true);
  }
}
