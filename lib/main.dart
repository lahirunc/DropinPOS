import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/utils/bindings.dart';
import 'package:dropin_pos_v2/utils/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp();

  // init shared pref object to retreive the shop name
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var storedShopName = preferences.getString('shopName') ?? '';
  print('Stored ShopName: ' + storedShopName.toString());

  runApp(MyApp(storedShopName: storedShopName));
}

class MyApp extends StatelessWidget {
  final storedShopName;

  const MyApp({Key key, this.storedShopName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // instance of auth controller
    final authController = Get.put(AuthController());

    // assigning the logged in shop name to authconroller
    authController.shopName = RxString(storedShopName ?? '');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      smartManagement: SmartManagement.keepFactory,
      initialBinding: AuthBinding(),
      home: Root(),
    );
  }
}
