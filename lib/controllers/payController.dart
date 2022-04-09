import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/models/cartModel.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';

import 'package:flutter_esc_printer/flutter_esc_printer.dart';
import 'package:get/get.dart';

import 'authController.dart';

class PayController extends GetxController {
  // variables
  bool _isRead = false;
  RxString color = ''.obs;
  var incGST = false.obs;
  var receiptList = <CartModel>[].obs;
  var amountToPay = 0.0.obs;
  var paid = 0.0.obs;
  var balance = 0.0.obs;
  var dbGst = 1.0.obs;
  var gstAmt = 0.0.obs;
  var discountPercentage = 0.0.obs;
  var discountAmt = 0.0.obs;
  var dbSurcharge = 0.0.obs;
  var surchargeAmt = 0.0.obs;
  var selectedDiscount = 'X'.obs;
  var isCash = true.obs;
  var isAmex = false.obs;
  var cusName = '';
  var cusMobile = '';
  var dateTimeStampISO = '';
  var isDiscountApproved = false.obs;
  var isCusCopy = false.obs;
  var isNoPrint = false.obs;
  var isPayPressed = false.obs;

  List<String> kotPrinterList = [];
  List<String> posPrinterList = [];

  // controllers
  AuthController authController = Get.find<AuthController>();

  // calculating total
  double get totalPrice => (receiptList.fold(
      0,
      (sum, item) =>
          sum +
          (item.price * item.qty) +
          (item.attribPriceList
              .fold(0, (sum, attrib) => sum + (attrib * item.qty)))));

  //get item total with extras
  double getItemTotal(int index) {
    double itemTotal = receiptList[index].price * receiptList[index].qty;
    double extras = 0;

    for (var extra in receiptList[index].attribPriceList) {
      extras += extra * receiptList[index].qty;
    }

    return itemTotal + extras;
  }

  // get items from exisiting order
  getPrevOrder(String orderId, String date) async {
    if (!_isRead) {
      receiptList.clear();
      List<String> _itemNamesList = [];
      List<String> _notesList = [];
      List<double> _priceList = [];
      List<int> _qtyList = [];
      List<String> _attribNameList = [];
      List<double> _attribPriceList = [];
      List<int> _attribParentIndexList = [];
      List<bool> _isVoid = [];

      DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('settings')
          .get();

      dbGst = RxDouble(double.parse(settingsSnap['gstAmt'].toString()));
      dbSurcharge = RxDouble(double.parse(settingsSnap['amexSurg'].toString()));

      DocumentSnapshot kotSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('kitchenOrderTicket')
          .collection(date)
          .doc(orderId)
          .get();

      _itemNamesList = List.from(kotSnap['itemname']);
      _notesList = List.from(kotSnap['notes']);
      _qtyList = List.from(kotSnap['qty']);
      _isVoid = List.from(kotSnap['void']);
      _attribNameList = List.from(kotSnap['attribNames']);
      _attribParentIndexList = List.from(kotSnap['attribParentIndex']);

      // _attribPriceList = List.from(kotSnap['attribPrice']);
      // _priceList = List.from(kotSnap['productPriceList']);

      for (var attribPrice in kotSnap['attribPrice']) {
        _attribPriceList.add(double.parse(attribPrice.toString()));
      }

      for (var prodPrice in kotSnap['productPriceList']) {
        _priceList.add(double.parse(prodPrice.toString()));
      }

      for (var i = 0; i < _itemNamesList.length; i++) {
        List<String> _renderedAttriNameList = [];
        List<double> _renderedAttriPriceList = [];

        for (var j = 0; j < _attribPriceList.length; j++) {
          if (i == _attribParentIndexList[j]) {
            _renderedAttriNameList.add(_attribNameList[j]);
            _renderedAttriPriceList.add(_attribPriceList[j]);
          }
        }

        var _recipetList = CartModel(
          _qtyList[i],
          _priceList[i],
          _itemNamesList[i],
          _notesList[i],
          _renderedAttriNameList,
          _renderedAttriPriceList,
          true,
          _isVoid[i],
          false,
          false,
          0,
        );

        if (receiptList.length < _itemNamesList.length) {
          receiptList.add(_recipetList);
        }
        _isRead = true;
        update();
        calcAmountToPay(0.0);
      }
    }
    // else {
    // Get.snackbar(
    //   'Error loading data!',
    //   'Error occured while loading data',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: Duration(seconds: 1),
    // );
    // }
  }

  changePayment() {
    isCash.toggle();
    calcAmountToPay(0);
  }

  changeCardType() {
    isAmex.toggle();

    calcAmountToPay(0.0);
  }

  calcAmountToPay(double val) {
    gstAmt = RxDouble(totalPrice * double.parse(dbGst.toString()) - totalPrice);

    // discountAmt = RxDouble(amountToPay * discount.toDouble() / 100);

    amountToPay = RxDouble(double.parse(totalPrice.toStringAsFixed(2)) +
        double.parse(gstAmt.toStringAsFixed(2)));

    surchargeAmt = isAmex.value
        ? RxDouble(amountToPay.toDouble() * (dbSurcharge.toDouble()))
        : RxDouble(0);

    amountToPay = RxDouble(amountToPay.toDouble() + surchargeAmt.toDouble());

    discountAmt = RxDouble(amountToPay * (discountPercentage.toDouble() / 100));

    amountToPay.value -= double.parse(discountAmt.toStringAsFixed(2));

    paid = RxDouble(isCash.value ? val : amountToPay.toDouble());

    balance = RxDouble(paid.toDouble() - amountToPay.toDouble());

    update();
  }

  // make the kitchen order
  savePayment(String date, String orderId, String tableId, String tableName,
      bool dineIn, bool takeAway) async {
    isPayPressed.value = true;
    update();
    if (balance >= 0) {
      int count = 0;
      List<int> _qty = [];
      List<double> _itemPriceList = [];
      List<double> _attribPrice = [];
      List<String> _notes = [];
      List<String> _itemNameList = [];
      List<String> _attribName = [];
      List<int> _attribParentIndex = [];
      List<bool> _void = [];

      receiptList.forEach((element) {
        _itemNameList.add(element.name);
        _itemPriceList.add(double.parse(element.price.toStringAsFixed(2)));
        _qty.add(element.qty);
        _notes.add(element.notes);
        _void.add(element.isVoid);
        element.attribNameList.forEach((element) {
          _attribName.add(element);
          _attribParentIndex.add(count);
        });
        element.attribPriceList.forEach((element) =>
            _attribPrice.add(double.parse(element.toStringAsFixed(2))));
        count++;
      });

      try {
        FirebaseFirestore.instance
            .collection(authController.shopName.toString())
            .doc('completedPayment')
            .collection('totalPayment')
            .doc(orderId)
            .set(
          {
            'customerName': cusName,
            'customerNumber': cusMobile,
            'date': date,
            'dateTimeStampISO': DateTime.now().toIso8601String(),
            'itemname': _itemNameList,
            'notes': _notes,
            'void': _void,
            'orderId': orderId,
            'tableName': tableName,
            'productPriceList': _itemPriceList,
            'qty': _qty,
            'discount':
                double.parse(discountPercentage.value.toStringAsFixed(2)),
            'attribNames': _attribName,
            'attribPrice': _attribPrice,
            'attribParentIndex': _attribParentIndex,
            'server': authController.userName.value,
            'serverId': authController.userId.value,
            'paymentType': isCash.value
                ? 'Cash'
                : isAmex.value
                    ? 'Amex'
                    : 'Visa/Mastercard',
            'AmountPaid': paid.value,
            'surcharge': isAmex.value
                ? double.parse(surchargeAmt.toStringAsFixed(2))
                : 0.0,
            'gstAmt': double.parse(gstAmt.toStringAsFixed(2)),
          },
          SetOptions(merge: true),
        ).then(
          (value) {
            if (dineIn == true) {
              FirebaseFirestore.instance
                  .collection(authController.shopName.toString())
                  .doc('tableDetails')
                  .collection('TableNo')
                  .doc(tableId)
                  .update({
                'Status': '',
                'dateStamp': '',
                'orderId': '',
              });
            } else {
              if (takeAway == true) {
                FirebaseFirestore.instance
                    .collection(authController.shopName.toString())
                    .doc("takeWay")
                    .collection('takeWayDetails')
                    .doc(orderId)
                    .delete();
              } else {
                print('delivery deleting started');
                FirebaseFirestore.instance
                    .collection(authController.shopName.toString())
                    .doc("Delivery")
                    .collection('DeliveryDetails')
                    .doc(orderId)
                    .delete();
              }
            }

            if (cusMobile.isNotEmpty) {
              FirebaseFirestore.instance
                  .collection(authController.shopName.toString())
                  .doc('CustomerDatabase')
                  .collection('CustomerInfo')
                  .doc(cusMobile)
                  .set(
                {
                  'lastOrder': _itemNameList,
                },
                SetOptions(merge: true),
              );
            }

            authController.isRead = false;

            Get.offAll(() => Dashboard());
          },
        );

        if (!isNoPrint.value) {
          await printReceipt(orderId, tableName);
        }
      } catch (e) {
        Get.snackbar(
          'Error occured!',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white,
        );
      }
    } else {
      Get.snackbar(
        'Payment Unsuccessful!',
        'Enter payment type and amount!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.primaryColor,
        colorText: Palette.white,
      );
    }
    isPayPressed.value = false;
    update();
  }

  Future<void> printReceipt(String orderId, String tableName) async {
    List<String> posPrinterList = [];

    DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('settings')
        .get();

    DocumentSnapshot businessSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('businessProfile')
        .get();

    posPrinterList = List.from(settingsSnap['posPrinter']);

    const PaperSize paper = PaperSize.mm80;
    for (var i = 0; i < posPrinterList.length; i++) {
      for (var j = 0; j < (isCusCopy.value ? 2 : 1); j++) {
        String address = posPrinterList[i];

        if (address.isIpAddress) {
          //print vai ip address
          PrinterNetworkManager _printerNetworkManager =
              PrinterNetworkManager();
          _printerNetworkManager.selectPrinter(address);
          final res = await _printerNetworkManager.printTicket(
              await posTicketTemplate(
                  paper, orderId, tableName, cusName, businessSnap, j));

          print(res.msg);
        } else if (address.isMacAddress) {
          //print via mac address
          PrinterBluetoothManager _printerBluetoothManager =
              PrinterBluetoothManager();
          _printerBluetoothManager.selectPrinter(address);
          final res = await _printerBluetoothManager.printTicket(
              await posTicketTemplate(
                  paper, orderId, tableName, cusName, businessSnap, j));

          print(res.msg);
        } else {
          //print("Error :e");
        }
      }
    }
  }

  Future<Ticket> posTicketTemplate(
      PaperSize paper,
      String orderId,
      String tableName,
      String cusName,
      DocumentSnapshot businessSnap,
      int count) async {
    GlobalController globalController = Get.find<GlobalController>();

    final _random = new Random();
    final Ticket ticket = Ticket(paper);

    List<String> _greetings = List.from(businessSnap['greetings']);

    int randNum = 0 + _random.nextInt(_greetings.length - 0);

    // ticket.image(
    //   Image.network(businessSnap['logoURL']),
    // );

    // final image = decodeImage((businessSnap['logoURL']).readAsBytesSync());

// final image = decodeImage(netw)
    // ticket.feed(1);

    // ticket.image(image);

    ticket.feed(1);

    ticket.row([
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1),
      ),
      PosColumn(
        text: businessSnap['shopName'],
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

    ticket.feed(1);

    ticket.row([
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.left,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: businessSnap['address'],
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          bold: true,
          fontType: PosFontType.fontA,
          // height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.right,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    ticket.row([
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.left,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: 'PH: ${businessSnap['phone']}',
        width: 4,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          bold: true,
          fontType: PosFontType.fontB,
          // height: PosTextSize.size2,
        ),
      ),
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(
          align: PosAlign.right,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    businessSnap['ABN'] != ''
        ? ticket.row([
            PosColumn(
              text: '',
              width: 4,
              styles: PosStyles(
                align: PosAlign.left,
                width: PosTextSize.size1,
              ),
            ),
            PosColumn(
              text: 'ABN: ${businessSnap['ABN']}',
              width: 4,
              styles: PosStyles(
                align: PosAlign.center,
                width: PosTextSize.size1,
                bold: true,
                fontType: PosFontType.fontB,
                // height: PosTextSize.size2,
              ),
            ),
            PosColumn(
              text: '',
              width: 4,
              styles: PosStyles(
                align: PosAlign.right,
                width: PosTextSize.size1,
              ),
            ),
          ])
        : ticket.feed(1);

    ticket.text(
      '=========================================================',
      styles: PosStyles(
        bold: true,
      ),
    );
    ticket.text(
      'Order ID: ' + orderId,
      styles: PosStyles(bold: true),
    );
    ticket.text(
      'Date: ' + globalController.currDateTimeSlashed,
      styles: PosStyles(bold: true),
    );
    ticket.text(
      'Cashier: ${authController.userName}',
      styles: PosStyles(bold: true),
    );
    ticket.text(
      '---------------------------------------------------------',
      styles: PosStyles(
        bold: true,
      ),
    );

    ticket.feed(1);

    for (var i = 0; i < receiptList.length; i++) {
      double _subTotal = 0;
      List<String> _attribName = [];
      List<double> _attribPrice = [];

      for (var j = 0; j < receiptList[i].attribNameList.length; j++) {
        _attribName.add(receiptList[i].attribNameList[j]);
        _attribPrice.add(receiptList[i].attribPriceList[j]);
      }

      _subTotal = receiptList[i].price +
          (_attribPrice.fold(0, (previous, element) => previous + element));

      ticket.row([
        PosColumn(
          text: '${receiptList[i].name}',
          width: 7,
          styles: PosStyles(
            align: PosAlign.left,
            width: PosTextSize.size1,
            bold: true,
          ),
        ),
        PosColumn(
          text: '',
          width: 1,
          styles: PosStyles(
            bold: true,
            align: PosAlign.left,
            width: PosTextSize.size1,
          ),
        ),
        PosColumn(
          text: '\$${(_subTotal * receiptList[i].qty).toStringAsFixed(2)}',
          // text: '\$${receiptList[i].price.toStringAsFixed(2)}',
          width: 4,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      ticket.text(
        '${receiptList[i].qty}pc(s) x \$${receiptList[i].price.toStringAsFixed(2)}',
        styles: PosStyles(
          bold: true,
        ),
      );

      for (var j = 0; j < _attribName.length; j++) {
        ticket.text(
          '-${_attribName[j]}  ${_attribPrice[j] > 0 ? 'x\$' + _attribPrice[j].toStringAsFixed(2) : ''}',
          styles: PosStyles(
            bold: true,
          ),
        );
      }

      ticket.feed(1);
    }
    ticket.feed(1);

    ticket.text(
      '---------------------------------------------------------',
      styles: PosStyles(
        bold: true,
      ),
    );

    //sub-total
    ticket.row([
      PosColumn(
        text: 'Sub-Total',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          width: PosTextSize.size1,
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
        text: '\$${totalPrice.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    //surchage
    isAmex.value
        ? ticket.row([
            PosColumn(
              text: 'Surcharge',
              width: 4,
              styles: PosStyles(
                bold: true,
                align: PosAlign.left,
                width: PosTextSize.size1,
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
              text: '\$${surchargeAmt.toStringAsFixed(2)}',
              width: 4,
              styles: PosStyles(
                bold: true,
                align: PosAlign.right,
                width: PosTextSize.size1,
              ),
            ),
          ])
        : ticket.emptyLines(0);

    // //G.S.T
    // ticket.row([
    //   PosColumn(
    //     text: 'G.S.T',
    //     width: 4,
    //     styles: PosStyles(
    //       bold: true,
    //       align: PosAlign.left,
    //       width: PosTextSize.size1,
    //     ),
    //   ),
    //   PosColumn(
    //     text: '',
    //     width: 4,
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       width: PosTextSize.size1,
    //       bold: true,
    //     ),
    //   ),
    //   PosColumn(
    //     text:
    //         '\$${(amountToPay.toDouble() - discountAmt.toDouble()).toString()}',
    //     width: 4,
    //     styles: PosStyles(
    //       bold: true,
    //       align: PosAlign.right,
    //       width: PosTextSize.size1,
    //     ),
    //   ),
    // ]);

    //Discount
    ticket.row([
      PosColumn(
        text: 'Discount (inc. G.S.T)',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          width: PosTextSize.size1,
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
        text: discountAmt.toDouble() > 0
            ? '-\$${(discountAmt.toDouble()).toStringAsFixed(2)}'
            : '0.00',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    //total
    ticket.row([
      PosColumn(
        text: 'Total (inc. G.S.T)',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
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
        text: '\$${amountToPay.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    //recieved
    ticket.row([
      PosColumn(
        text: isCash.value
            ? 'Recieved Cash'
            : isAmex.value
                ? 'Amex Card Payment'
                : 'Visa/Master Card Payment',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
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
        text: '\$${paid.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
        ),
      ),
    ]);

    //change
    ticket.row([
      PosColumn(
        text: 'Change',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.left,
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
        text: '\$${balance.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
        ),
      ),
    ]);

    ticket.text(
      '---------------------------------------------------------',
      styles: PosStyles(
        bold: true,
      ),
    );
    ticket.feed(1);
    isCusCopy.value && count == 1
        ? ticket.row(
            [
              PosColumn(
                text: '***** CUSTOMER COPY *****',
                width: 12,
                styles: PosStyles(
                  align: PosAlign.center,
                  width: PosTextSize.size2,
                  height: PosTextSize.size1,
                  bold: true,
                ),
              ),
            ],
          )
        : ticket.feed(0);
    ticket.feed(1);
    ticket.row([
      PosColumn(
        text: _greetings[randNum],
        width: 12,
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size2,
          height: PosTextSize.size1,
          bold: true,
        ),
      ),
    ]);

    ticket.cut();
    isCash.value ? ticket.drawer() : ticket.beep();
    return ticket;
  }

  // discount process
  approveDiscount(
      String pin, double discountVal, String selectedDiscountStr) async {
    if (pin.length == 4) {
      QuerySnapshot staffSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('staff')
          .collection('staffLogin')
          .get();

      for (var i = 0; i < staffSnap.docs.length; i++) {
        if (staffSnap.docs[i]['memberId'] == pin &&
            staffSnap.docs[i]['disApprove']) {
          discountPercentage = RxDouble(discountVal);
          calcAmountToPay(0.0);
          selectedDiscount = RxString(selectedDiscountStr);
        }
      }
      Get.back();
    }
  }
}
