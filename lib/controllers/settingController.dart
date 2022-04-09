import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/models/previous_order_model.dart';
import 'package:flutter_esc_printer/flutter_esc_printer.dart';
import 'package:get/get.dart';
import 'package:regexed_validator/regexed_validator.dart';

import 'authController.dart';
import 'globalController.dart';

class SettingsController extends GetxController {
  AuthController authController = Get.find<AuthController>();

  // printer IP lists
  var posList = [];
  var kot1List = [];
  var kot2List = [];
  var kot3List = [];

  var prevOrderList = <PreviousOrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    prevOrderList.bindStream(getPeviousOrders());
  }

  // Printer Methods
  // read printer data from the db
  Future<void> getPrinterList() async {
    DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('settings')
        .get();

    kot1List = RxList(List.from(settingsSnap['kotPrinter']));
    kot2List = RxList(List.from(settingsSnap['kot2Printer']));
    kot3List = RxList(List.from(settingsSnap['kot3Printer']));
    posList = RxList(List.from(settingsSnap['posPrinter']));
    update();
  }

  // Add/Update/Delete IP list - checks if the ip should be added. If added,
  // check the entered ip is valid else error will be shown else added. Also, if
  // removed the printer ip will be removed and updated
  void updatePrinterIPs(String ipAddress, String printerName, List printerList,
      bool isAdd) async {
    if (isAdd) {
      if (validator.ip(ipAddress)) {
        printerList.add(ipAddress);
      } else {
        return Get.snackbar(
          'Invalid IP Address',
          'Enter a valid IP address',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Palette.white,
          backgroundColor: Palette.secondaryColor,
        );
      }
    } else {
      printerList.removeAt(int.parse(ipAddress));
    }

    // DB Call
    try {
      await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('settings')
          .set(
        {
          printerName: printerList,
        },
        SetOptions(merge: true),
      ).then(
        (value) {
          getPrinterList();
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

  // for re-printing the prev. receipt
  void printPrevOrder(int index) async {
    await getPrinterList();

    printTicket(posList, true, index, prevOrderList);
  }

  // Calling method for print a ticket
  Future<void> printTicket(List printerList, bool isPOS, int index,
      List<PreviousOrderModel> itemList) async {
    GlobalController globalController = Get.find<GlobalController>();

    const PaperSize paper = PaperSize.mm80;

    for (var i = 0; i < printerList.length; i++) {
      String address = printerList[i];

      if (address.isIpAddress) {
        PrinterNetworkManager _printerNetworkManager = PrinterNetworkManager();
        _printerNetworkManager.selectPrinter(address);
        final res = await _printerNetworkManager.printTicket(await (isPOS
            ? posTestPrint(
                paper,
                itemList,
                index,
              )
            : kotTicketTemplate(paper, globalController)));

        print(res.msg);
      }
    }
  }

  // KOT Ticket Template
  Future<Ticket> kotTicketTemplate(
      PaperSize paper, GlobalController globalController) async {
    final Ticket ticket = Ticket(paper);

    ticket.feed(4);

    ticket.text(
      'KOT# 99999',
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    // ticket.feed(1);
    ticket.text(
      'Date: ${globalController.currDateTimeSlashed}',
      styles: PosStyles(
        align: PosAlign.center,
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.feed(1);
    ticket.text(
      'Table: 999',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.feed(1);
    ticket.text(
      'Customer: Test Customer',
      styles: PosStyles(
        align: PosAlign.center,
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    // ticket.feed(1);
    ticket.text(
      'Order taken by: Server1',
      styles: PosStyles(
        align: PosAlign.center,
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.text(
      '__________________________________________',
      styles: PosStyles(
        align: PosAlign.center,
      ),
      linesAfter: 1,
    );

    ticket.text(
      '1 x Test Item',
      styles: PosStyles(
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.text(
      'Notes: Test note',
      styles: PosStyles(
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );
    ticket.text(
      'Extras: Extra1, Extra2',
      styles: PosStyles(
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    ticket.feed(1);

    ticket.text(
      '1 x Test Item',
      styles: PosStyles(
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.text(
      'Notes: Void Item',
      styles: PosStyles(
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
        reverse: true,
      ),
      linesAfter: 1,
    );

    ticket.cut();
    // ticket.drawer();
    return ticket;
  }

  // POS Ticket Template
  Future<Ticket> posTestPrint(
    PaperSize paper,
    List<PreviousOrderModel> itemList,
    int index,
  ) async {
    final Ticket ticket = Ticket(paper);

    DocumentSnapshot _businessSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('businessProfile')
        .get();

    List<String> _greetings = List.from(_businessSnap['greetings']);
    int randNum = 0 + Random().nextInt(_greetings.length - 0);

    ticket.row([
      PosColumn(
        text: '',
        width: 4,
        styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1),
      ),
      PosColumn(
        text: _businessSnap['shopName'],
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
        text: _businessSnap['address'],
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
        text: 'PH: ${_businessSnap['phone']}',
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

    _businessSnap['ABN'] != ''
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
              text: 'ABN: ${_businessSnap['ABN']}',
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
      'Order ID: ' + itemList[index].id,
      styles: PosStyles(bold: true),
    );
    ticket.text(
      'Date: ' + itemList[index].date,
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
// asdasd
    for (var i = 0; i < itemList[index].priceList.length; i++) {
      double _subTotal = 0;

      _subTotal = itemList[i].subTotal;

      ticket.row([
        PosColumn(
          text: '${itemList[index].itemList[i]}',
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
          text: '\$${_subTotal.toStringAsFixed(2)}',
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
        '${itemList[index].qty[i]}pc(s) x \$${itemList[index].priceList[i].toStringAsFixed(2)}',
        styles: PosStyles(
          bold: true,
        ),
      );

      for (var j = 0; j < itemList[index].attributeNameList.length; j++) {
        ticket.text(
          '- ${itemList[index].attributeNameList[j]}  ${itemList[index].attribPriceList[j] > 0 ? 'x \$' + itemList[index].attribPriceList[j].toStringAsFixed(2) : ''}',
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
        text: '\$${itemList[index].subTotal.toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    //surchage
    itemList[index].paymentType == 'Amex'
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
              text: '\$${itemList[index].surcharge.toStringAsFixed(2)}',
              width: 4,
              styles: PosStyles(
                bold: true,
                align: PosAlign.right,
                width: PosTextSize.size1,
              ),
            ),
          ])
        : ticket.emptyLines(0);

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
        text: itemList[index].discount.toDouble() > 0
            ? '-\$${itemList[index].discount.toStringAsFixed(2)}'
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
        text: '\$${itemList[index].paidAmount.toStringAsFixed(2)}',
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
        text: itemList[index].paymentType,
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
        text: '\$${itemList[index].paidAmount.toStringAsFixed(2)}',
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
        text:
            '\$${(itemList[index].paidAmount - itemList[index].total).toStringAsFixed(2)}',
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
    ticket.row(
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
    );

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
    return ticket;
  }
  // End of Printer Methods

  // Previous Order Methods
  // read printer data from the db
  Stream<List<PreviousOrderModel>> getPeviousOrders() {
    return FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('completedPayment')
        .collection('totalPayment')
        .orderBy('dateTimeStampISO', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((item) => PreviousOrderModel.fromMap(item))
            .toList());
  }

  // End of Previous Order Methods
}
