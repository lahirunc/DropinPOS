import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/screens/login/loginScreen.dart';
import 'package:dropin_pos_v2/screens/pin/pinScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class  Root extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print(Get.find<AuthController>().shopName.toString());
      return (Get.find<AuthController>().shopName.toString() != ''
          ? PinScreen()
          : LoginScreen());
    });
  }
}
