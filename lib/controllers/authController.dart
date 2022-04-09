import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';
import 'package:dropin_pos_v2/utils/root.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_esc_printer/flutter_esc_printer.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  var shopName = ''.obs;
  var userName = ''.obs;
  var userId = ''.obs;
  var isLoginPressed = false.obs;
  var tillId;
  var initTillAmount = 0.0.obs;
  var tillDiff = 0.0.obs;
  var recorededDateTimeISO;
  var version = ''.obs;
  bool isRead = false;
  int activeTables = 0;

  List<double> _dailyCashPriceList = [];
  List<double> _dailyCardPriceList = [];

  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User> _user = Rx<User>();

  double get dailyTotalCashSale =>
      (_dailyCashPriceList.fold(0, (sum, item) => sum + item));

  double get dailyTotalCardSale =>
      (_dailyCardPriceList.fold(0, (sum, item) => sum + item));

  double get dailyTotal => dailyTotalCardSale + dailyTotalCashSale;

  @override
  void onInit() {
    _user.bindStream(_auth.authStateChanges());
    getPackageInfo();

    super.onInit();
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // print(packageInfo.version);
    version.value = ' Ver: ${packageInfo.version}(${packageInfo.buildNumber})';
    update();
  }

  void signIn(String email, String password) async {
    if (!isLoginPressed.value) {
      isLoginPressed.value = true;
      update();
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        DocumentSnapshot loggedSnap = await FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser.displayName)
            .doc('loggedDevices')
            .get();

        if (loggedSnap['logged'] < loggedSnap['accepted']) {
          shopName = RxString(_auth.currentUser.displayName.toString());
          await FirebaseFirestore.instance
              .collection(shopName.toString())
              .doc('loggedDevices')
              .set(
            {'logged': FieldValue.increment(1)},
            SetOptions(merge: true),
          ).then((value) async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            preferences.setString('shopName', shopName.toString());
          });

          Get.offAll(() => Root());
        } else {
          Get.snackbar(
            'Maxed out users!',
            'Approved number of devices has been exceeded!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Palette.primaryColor,
            colorText: Palette.white,
          );
        }
      } catch (e) {
        var message;
        if (e.code == 'user-not-found') {
          message = 'Invalid email or password';
        } else {
          message = e.code;
        }
        Get.snackbar(
          'Login failed!',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
      isLoginPressed.value = false;
      update();
    }
  }

  void logOut() async {
    if (!isLoginPressed.value) {
      isLoginPressed.value = true;
      update();
      try {
        await _auth.signOut();

        await FirebaseFirestore.instance
            .collection(shopName.toString())
            .doc('loggedDevices')
            .set(
          {'logged': FieldValue.increment(-1)},
          SetOptions(merge: true),
        );

        shopName = RxString('');
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.remove('shopName');

        Get.offAll(() => Root());
      } catch (e) {
        Get.snackbar(
          'Sign out unsuccessful!',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
      isLoginPressed.value = false;
      update();
    }
  }

  void storeOpening(String cash) async {
    if (cash != '') {
      recorededDateTimeISO = DateTime.now().toIso8601String();
      try {
        var docRef = await FirebaseFirestore.instance
            .collection(shopName.toString())
            .doc('till')
            .collection('records')
            .add({
          'openAmt': double.parse(cash),
          'openDateTime': recorededDateTimeISO,
          'openStaffId': userId.value,
          'openStaffName': userName.value,
        });
        initTillAmount = RxDouble(double.parse(cash));
        tillId = docRef.id.toString();

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('tillId', tillId.toString());
        preferences.setString('tillAmount', initTillAmount.toString());
        preferences.setString('saffId', userId.toString());
        preferences.setString('startDateTime', recorededDateTimeISO.toString());

        Get.to(() => Dashboard());
      } catch (e) {
        Get.snackbar(
          'Error in updating the cash in register',
          'Something went wrong! Please try again.\n${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    } else {
      Get.snackbar(
        'Error in updating the cash in register',
        'Cash value cannot be null',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.primaryColor,
        colorText: Palette.white,
      );
    }
  }

  // setTillAmount(double newAmt) async {
  //   tillAmount.value += newAmt;

  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   preferences.setString('tillAmount', tillAmount.toString());
  // }

  void calcTillDiff(double cash) {
    tillDiff = RxDouble(initTillAmount.value - cash);
    update();
  }

  Future<void> getActiveTables() async {
    try {
      QuerySnapshot tableSnap = await FirebaseFirestore.instance
          .collection(shopName.toString())
          .doc('tableDetails')
          .collection('TableNo')
          .where('Status', isNotEqualTo: '')
          .get();

      activeTables = 0;

      for (var item in tableSnap.docs) {
        try {
          if (item['orderId'] != '') {
            activeTables++;
          }
        } catch (e) {
          continue;
        }
      }

      // activeTables = tableSnap.size;

     
      update();
    } catch (e) {
      activeTables = 0;
      // Get.snackbar(
      //   'Table no. could not be read!',
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Palette.primaryColor,
      //   colorText: Palette.white,
      // );
    }
  }

  printReport(
      String fromDateTime, String title, String reason, var cash) async {
    isRead = false;

    cash = (cash != '' ? double.parse(cash.toString()) : 0.0);

    if (title != 'Y Report') {
      activeTables = 0;
      isRead = false;
      try {
        _dailyCashPriceList.clear();
        _dailyCardPriceList.clear();

        QuerySnapshot salesSnap = await FirebaseFirestore.instance
            .collection(shopName.toString())
            .doc('completedPayment')
            .collection('totalPayment')
            .get();

        var _convertedRecordedDate = DateTime.parse(fromDateTime);
        var _currDateTime = DateTime.now();

        for (var item in salesSnap.docs) {
          try {
            var _dateTimeStampISO = item['dateTimeStampISO'];
            var _discount = double.parse(item['discount'].toString());
            var _gstAmt = double.parse(item['gstAmt'].toString());
            var _paymentType = item['paymentType'];
            List<int> _attribPIndexList = List.from(item['attribParentIndex']);
            List<double> _attribPriceList = List.from(item['attribPrice']);
            List<int> _qtyList = List.from(item['qty']);
            List<double> _priceList = [];

            for (var item in item['productPriceList']) {
              _priceList.add(double.parse(item.toString()));
            }

            for (var i = 0; i < _priceList.length; i++) {
              if (!item['void'][i]) {
                if (DateTime.parse(_dateTimeStampISO)
                        .isAfter(_convertedRecordedDate) &&
                    DateTime.parse(_dateTimeStampISO).isBefore(_currDateTime)) {
                  double itemTotal = _priceList[i] * _qtyList[i];
                  double attribTotal = 0;
                  double total = 0;

                  if (_paymentType == 'Cash') {
                    for (var k = 0; k < _attribPIndexList.length; k++) {
                      if (i == _attribPIndexList[k]) {
                        attribTotal += _attribPriceList[k] * _qtyList[i];
                      }
                    }

                    total = itemTotal + attribTotal;
                    total = total - (total * _discount / 100);

                    if (i == 0) {
                      total += _gstAmt;
                    }

                    _dailyCashPriceList.add(total);
                  } else {
                    _dailyCardPriceList.add(item['AmountPaid']);
                    i = _priceList.length;
                  }

                  // if (_paymentType == 'Cash') {
                  //   _dailyCashPriceList.add(total);
                  // } else if (_paymentType == 'Visa/Mastercard') {
                  //   _dailyCardPriceList.add(total);
                  // } else {
                  //   total += double.parse(item['surcharge'].toString());
                  //   _dailyCardPriceList.add((total));
                  // }
                }
              }
            }
          } catch (e) {
            continue;
          }
        }
        for (var item in _dailyCashPriceList) {
          initTillAmount += item;
        }
      } on Exception catch (e) {
        Get.snackbar(
          'Error reading data',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    }

    if (activeTables == 0) {
      // await getSales(fromDateTime);
      await sendtoPrinter(title, reason);
      // calcTillDiff(cash);
    } else {
      Get.snackbar(
        'Active table!',
        'Theres an on going table. Please close it to finalize the sale.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.primaryColor,
        colorText: Palette.white,
      );
    }
  }

  Future<void> getSales(String fromDateTime) async {
    if (!isRead) {
      try {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var storedTillAmt = preferences.getString('tillAmount') ?? 0;
        initTillAmount.value = double.parse(storedTillAmt.toString());

        _dailyCashPriceList.clear();
        _dailyCardPriceList.clear();

        var _convertedRecordedDate = DateTime.parse(fromDateTime);
        var _currDateTime = DateTime.now();

        QuerySnapshot salesSnap = await FirebaseFirestore.instance
            .collection(shopName.toString())
            .doc('completedPayment')
            .collection('totalPayment')
            .get();

        for (var item in salesSnap.docs) {
          try {
            var _dateTimeStampISO = item['dateTimeStampISO'];
            var _discount = double.parse(item['discount'].toString());
            var _gstAmt = double.parse(item['gstAmt'].toString());
            var _paymentType = item['paymentType'];
            List<int> _attribPIndexList = List.from(item['attribParentIndex']);
            List<double> _attribPriceList = List.from(item['attribPrice']);
            List<int> _qtyList = List.from(item['qty']);
            List<double> _priceList = [];

            for (var item in item['productPriceList']) {
              _priceList.add(double.parse(item.toString()));
            }

            for (var i = 0; i < _priceList.length; i++) {
              if (!item['void'][i]) {
                if (DateTime.parse(_dateTimeStampISO)
                        .isAfter(_convertedRecordedDate) &&
                    DateTime.parse(_dateTimeStampISO).isBefore(_currDateTime)) {
                  double itemTotal = _priceList[i] * _qtyList[i];
                  double attribTotal = 0;
                  double total = 0;

                  for (var k = 0; k < _attribPIndexList.length; k++) {
                    if (i == _attribPIndexList[k]) {
                      attribTotal += _attribPriceList[k] * _qtyList[i];
                    }
                  }

                  total = itemTotal + attribTotal;
                  total = total - (total * _discount / 100);

                  if (i == 0) {
                    total += _gstAmt;
                  }

                  if (_paymentType == 'Cash') {
                    _dailyCashPriceList.add(total);
                  } else if (_paymentType == 'Visa/Mastercard') {
                    _dailyCardPriceList.add(total);
                  } else {
                    total += double.parse(item['surcharge'].toString());
                    _dailyCardPriceList.add((total));
                  }
                }
              }
            }
          } catch (e) {
            continue;
          }
        }
        for (var item in _dailyCashPriceList) {
          initTillAmount += item;
        }

        await getActiveTables();
        isRead = true;
        update();
      } catch (e) {
        Get.snackbar(
          'Error occured! Please try again!',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    }
  }

  Future<void> storeClosing(String amount, String reason) async {
    await getActiveTables();
    if (amount != '' && activeTables == 0) {
      if (tillDiff.value == 0 ||
          tillDiff.value == tillDiff.value ||
          (tillDiff.value != 0 && reason.length > 5)) {
        try {
          await FirebaseFirestore.instance
              .collection(shopName.toString())
              .doc('till')
              .collection('records')
              .doc(tillId)
              .set(
            {
              'actualAmt': double.parse(initTillAmount.toStringAsFixed(2)),
              'closeAmt': double.parse(amount),
              'closeDateTime': DateTime.now().toIso8601String(),
              'reason': reason,
            },
            SetOptions(merge: true),
          ).then((value) async {
            tillId = RxString('');
            initTillAmount.value = -1;
            tillDiff.value = 0;

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.remove('tillId');
            await preferences.remove('tillAmount');
            await preferences.remove('saffId');

            update();
            Get.offAll(() => Root());
          });
        } catch (e) {
          Get.snackbar(
            'Error in updating the cash in register',
            'Something went wrong! Please try again.\n${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Palette.primaryColor,
            colorText: Palette.white,
          );
        }
      } else {
        Get.snackbar(
          'Error in updating the cash in register',
          'Valid reason should be entered!.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    } else {
      String title, message;

      if (activeTables != 0) {
        // implement active tables here
        title = 'Active table!';
        message =
            'Theres an on going table. Please close it to finalize the sale';
      } else {
        title = 'Error in updating the cash in register';
        message = 'Actual cash in register cannot be null';
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.primaryColor,
        colorText: Palette.white,
      );
    }
    print(amount);
    print(reason);
  }

  sendtoPrinter(String title, String reason) async {
    DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
        .collection(shopName.toString())
        .doc('settings')
        .get();

    var posPrinterList = List.from(settingsSnap['posPrinter']);

    const PaperSize paper = PaperSize.mm80;
    for (var i = 0; i < posPrinterList.length; i++) {
      String address = posPrinterList[i];

      if (address.isIpAddress) {
        //print via ip address
        PrinterNetworkManager _printerNetworkManager = PrinterNetworkManager();
        _printerNetworkManager.selectPrinter(address);
        final res = await _printerNetworkManager
            .printTicket(await posTicketTemplate(paper, title, reason));

        if (res.msg == 'Success') {
          Get.snackbar(
            'Report printed!',
            'Check the front counter printer (Reciept Printer)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Palette.primaryColor,
            colorText: Palette.white,
          );
        } else {
          Get.snackbar(
            'Error in printing the report',
            'Please check if the printer is working and try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Palette.primaryColor,
            colorText: Palette.white,
          );
        }
      } else {
        Get.snackbar(
          'Error in printing the report',
          'Please check if the printer is working and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    }
  }

  Future<Ticket> posTicketTemplate(
      PaperSize paper, String title, String reason) async {
    final Ticket ticket = Ticket(paper);

    ticket.row([
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1),
      ),
      PosColumn(
        text: title,
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size2,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1),
      ),
    ]);

    ticket.text(
      '================================================',
      styles: PosStyles(
        bold: true,
      ),
    );

    title != 'Y Report'
        ? ticket.text(
            'Staff Name: ${userName.value}',
            styles: PosStyles(
              bold: true,
              height: PosTextSize.size2,
            ),
            linesAfter: 1,
          )
        : ticket.emptyLines(0);

    ticket.text(
      'Date: ' + GlobalController().currDateTimeSlashed,
      styles: PosStyles(
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    ticket.text(
      '------------------------------------------------',
      styles: PosStyles(
        bold: true,
      ),
    );

    ticket.row([
      PosColumn(
        text: 'Cash Sales',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '\$${dailyTotalCashSale.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    ticket.feed(1);

    ticket.row([
      PosColumn(
        text: 'Card Sales',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '\$${dailyTotalCardSale.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    ticket.text(
      '------------------------------------------------',
      styles: PosStyles(
        bold: true,
      ),
    );

    ticket.row([
      PosColumn(
        text: 'Total Sales',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '\$${dailyTotal.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    ticket.feed(1);

    title == 'Y Report'
        ? ticket.text(
            'Reason:',
            styles: PosStyles(
              bold: true,
              align: PosAlign.left,
              width: PosTextSize.size1,
              height: PosTextSize.size2,
            ),
          )
        : ticket.emptyLines(0);

    title == 'Y Report'
        ? ticket.text(
            reason,
            styles: PosStyles(
              bold: false,
              align: PosAlign.left,
              width: PosTextSize.size2,
              height: PosTextSize.size1,
            ),
          )
        : ticket.emptyLines(0);

    ticket.cut();
    return ticket;
  }
}
