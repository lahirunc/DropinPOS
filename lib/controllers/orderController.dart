import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/models/cartModel.dart';
import 'package:dropin_pos_v2/models/menu_model.dart';
import 'package:dropin_pos_v2/models/toppingModel.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';

import 'package:flutter_esc_printer/flutter_esc_printer.dart';
import 'package:get/get.dart';

import 'dineController.dart';

class OrderController extends GetxController {
  //variables
  var pressedIndex = 0.obs;
  var cartList = <CartModel>[].obs;
  bool isRead = false;
  var isSendPressed = false.obs;
  var _readDate = '';
  var filteredDocs = <MenuModel>[];
  var isSendToKitchen = false;
  var catList = [];
  var isEditPizza = false;
  var scrollController = ScrollController();
  RxDouble end = 0.0.obs;
  RxString check = ''.obs;

  List _posPrintList = <CartModel>[];
  List _kot1PrintList = <CartModel>[];
  List _kot2PrintList = <CartModel>[];
  List _kot3PrintList = <CartModel>[];

  // pizza variables
  var isHnH = false.obs;

  //curst
  var crustList = ['No data'].obs;
  var selectedCrust1 = ''.obs;
  var selectedCrust2 = ''.obs;

  // size
  var sizeList = ['No data'].obs;
  var selectedSize = ''.obs;

  // sauces
  var sauceList = ['No data'].obs;
  var selectedSauce1 = ''.obs;
  var selectedSauce2 = ''.obs;

  // toppings
  var toppingsList = ['No data'].obs;
  var selectedToppings1 = <ToppingModel>[].obs;
  var selectedToppings2 = <ToppingModel>[].obs;

  // combo variables
  var mains = ''.obs;
  var addons = ''.obs;
  var drinks = ''.obs;
  var selectedAddons = [].obs;
  var selectedDrinks = [].obs;

  // get the length of cartList
  int get count => cartList.length;

  // controllers
  AuthController authController = Get.find<AuthController>();
  final dineController = Get.find<DineController>();
  GlobalController globalController = Get.put(GlobalController());

  // calculating total
  double get totalPrice => cartList.fold(
      0,
      (sum, item) =>
          sum +
          (item.price * item.qty) +
          (item.attribPriceList
              .fold(0, (sum, attrib) => sum + (attrib * item.qty))));

  @override
  void onInit() {
    pressedIndex = RxInt(0);
    getMenu('', 'All Items');

    print(cartList);

    update();
    super.onInit();
  }

  // combo selection - addons and drinks
  // checks the limit is less or equal to the size of the array. if its
  // higher error will be displayed. If theres no limit keep the limit 0.
  void addItemsToArray(String value, var arrVar, int limit) {
    if (arrVar.where((element) => element == value).isNotEmpty) {
      arrVar.removeWhere((element) => element == value);
    } else {
      if (limit != 0 ? arrVar.length < limit : true) {
        arrVar.add(value);
      } else {
        Get.snackbar('Limted to $limit item', 'Can only select $limit item(s).',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Palette.primaryColor,
            colorText: Palette.white);
      }
    }

    update();
  }

  // clear combo data
  void flushComboData() {
    selectedAddons.clear();
    selectedDrinks.clear();
    selectedSize.value = '';
  }

  //combo save to order
  void addComboToOrder(int itemIndex) {
    int _index = cartList.length - 1;

    cartList[_index].attribNameList.add(selectedSize.toString());
    cartList[_index].attribPriceList.add(
        double.parse(filteredDocs[itemIndex].main[selectedSize].toString()));

    for (var item in selectedAddons) {
      cartList[_index].attribNameList.add(item.toString());
      cartList[_index].attribPriceList.add(double.parse(
          filteredDocs[itemIndex].addons[item.toString()].toString()));
    }

    for (var item in selectedDrinks) {
      cartList[_index].attribNameList.add(item.toString());
      cartList[_index].attribPriceList.add(double.parse(
          filteredDocs[itemIndex].drinks[item.toString()].toString()));
    }
  }

  // Pizza crust selection - assign the value to the crust
  void setSelectedCrust(int index, String value) {
    index == 1 ? selectedCrust1.value = value : selectedCrust2.value = value;

    update();
  }

  void setSelectedSize(String value) {
    selectedSize.value = value;

    update();
  }

// Pizza sauce selection - assign the value to the sauce
  void setSelectedSauce(int index, String value) {
    index == 1 ? selectedSauce1.value = value : selectedSauce2.value = value;

    update();
  }

  // combo selection - main item
  void setSelectedValue(String value, var statValue) {
    statValue.value = value;

    update();
  }

  void setIsEditPizza(bool value) {
    isEditPizza = value;
    update();
  }

  void getPizzaData() async {
    try {
      DocumentSnapshot itemSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc("/itemDetails")
          .get();

      // toppings
      pizzaListUpdate(itemSnap, toppingsList, '', '', 'toppings');

      toppingsList.sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

      // size
      pizzaListUpdate(itemSnap, sizeList, selectedSize, '', 'size');

      // sauce
      pizzaListUpdate(
          itemSnap, sauceList, selectedSauce1, selectedSauce2, 'sauces');

      // crust
      pizzaListUpdate(
          itemSnap, crustList, selectedCrust1, selectedCrust2, 'crusts');

      update();
    } catch (e) {
      Get.snackbar('Error occured!', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Palette.primaryColor,
          colorText: Palette.white);
    }
  }

  // NOT BEING USED - For add defaults
  Future<void> addDefaultPizzaSelection(int index) async {
    if (cartList[index].attribNameList.length > 0) {
      isEditPizza = true;

      isHnH.value =
          cartList[index].attribNameList[0].toString() == 'H&H' ? true : false;
      // selectedSize.value = cartList[index].attribNameList[0].toString();
      // selectedCrust.value = cartList[index].attribNameList[1].toString();
      // selectedSauce.value = cartList[index].attribNameList[2].toString();

      // for (var attrib in cartList[index].attribNameList) {
      //   for (var toppings in toppingsList) {
      //     var _key = toppings.split('\n');

      //     if (_key[0].contains(RegExp(attrib, caseSensitive: false))) {
      //       var _price =
      //           _key.length < 2 ? 0.00 : double.parse(_key[1].split('\$')[1]);

      //       selectedToppings.add(ToppingModel(attrib, _price));
      //     }
      //   }
      // }
    }
    // try {
    //   QuerySnapshot _pizzaSnap = await FirebaseFirestore.instance
    //       .collection(authController.shopName.toString())
    //       .doc("/itemDetails")
    //       .collection('items')
    //       .where('name', isEqualTo: cartList[index].name)
    //       .get();

    //   for (var item in _pizzaSnap.docs) {
    //     if (cartList[index]
    //         .name
    //         .contains(RegExp(item['name'], caseSensitive: false))) {
    //       for (var ing in item['ingredients']) {
    //         // selectedToppings.add()
    //       }
    //     }
    //   }
    // } catch (e) {
    //   Get.snackbar('Error occured while reading defaults!', e.toString(),
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: Palette.primaryColor,
    //       colorText: Palette.white);
    // }

    update();
  }

  void pizzaListUpdate(DocumentSnapshot<Object> itemSnap, var list,
      var selected, var selected2, String field) {
    list.clear();

    var map = itemSnap[field];

    for (var item in map.keys) {
      String _price = double.parse(map[item].toString()) > 0
          ? '\n\$${map[item].toStringAsFixed(2)}'
          : '';
      list.add(item + _price);
    }

    if (list.length <= 0) {
      list.clear();
      list.add('No size data found!');
    }

    if (field != 'toppings') {
      selected.value = list.reversed.toList()[0].toString();

      if (field != 'size' && field != 'toppings') {
        selected2.value = list.reversed.toList()[0].toString();
      }
    }
  }

  void addToppings(String key, int index) {
    var _key = key.split('\n');

    String _name = _key[0];

    var contain = index == 1
        ? selectedToppings1.where((element) => element.name == _name)
        : selectedToppings2.where((element) => element.name == _name);
    if (contain.isEmpty) {
      var _price =
          _key.length < 2 ? 0.00 : double.parse(_key[1].split('\$')[1]);

      index == 1
          ? selectedToppings1.add(ToppingModel(_name, _price))
          : selectedToppings2.add(ToppingModel(_name, _price));
    } else {
      index == 1
          ? selectedToppings1.removeWhere((element) => element.name == _name)
          : selectedToppings2.removeWhere((element) => element.name == _name);
    }

    update();
  }

  void pizzaSave(int index) {
    double _total = 0;
    var _selectedSizeSeperated = selectedSize.split('\n');
    var _selectedCrustSeperated = selectedCrust1.split('\n');
    var _selectedSauceSeperated = selectedSauce1.split('\n');

    double _sizePrice = _selectedSizeSeperated.length < 2
        ? 0.00
        : double.parse(_selectedSizeSeperated[1].split('\$')[1]);
    double _crustPrice = _selectedCrustSeperated.length < 2
        ? 0.00
        : double.parse(_selectedCrustSeperated[1].split('\$')[1]);
    double _saucePrice = _selectedSauceSeperated.length < 2
        ? 0.00
        : double.parse(_selectedSauceSeperated[1].split('\$')[1]);

    _total = _sizePrice + _crustPrice + _saucePrice;
    addNotes(index, '');

    cartList[index].attribNameList.clear();
    cartList[index].attribPriceList.clear();

    addPizzaAttributes(index, isHnH.value ? 'H&H' : 'FULL', 0.0);
    addPizzaAttributes(
        index, _selectedSizeSeperated[0].capitalize.toString(), 0.0);
    addPizzaAttributes(index, _selectedCrustSeperated[0].toString(), 0.0);
    addPizzaAttributes(index, _selectedSauceSeperated[0], 0.0);

    // cartList[index].attribNameList.add(isHnH.value ? 'H&H' : 'Full');
    // cartList[index].attribPriceList.add(0.0);

    // cartList[index]
    //     .attribNameList
    //     .add(_selectedSizeSeperated[0].capitalize.toString());

    // cartList[index].attribNameList.add(_selectedCrustSeperated[0].toString());

    // cartList[index].attribNameList.add(_selectedSauceSeperated[0].toString());

    for (var topping in selectedToppings1) {
      addPizzaAttributes(index, topping.name.toString(), 0.0);
      // cartList[index].attribNameList.add(topping.name.toString());
      // cartList[index].attribPriceList.add(0.0);
      // _attribNameList.add();
      // _attribPriceList.add(0.0);
      _total += topping.price;
    }

    if (isHnH.value) {
      var _selectedCrustSeperated2 = selectedCrust2.split('\n');
      var _selectedSauceSeperated2 = selectedSauce2.split('\n');

      double _crustPrice2 = _selectedCrustSeperated2.length < 2
          ? 0.00
          : double.parse(_selectedCrustSeperated2[1].split('\$')[1]);
      double _saucePrice2 = _selectedSauceSeperated2.length < 2
          ? 0.00
          : double.parse(_selectedSauceSeperated2[1].split('\$')[1]);

      addPizzaAttributes(index, _selectedCrustSeperated2[0].toString(), 0.0);
      addPizzaAttributes(index, _selectedSauceSeperated2[0], 0.0);
      // cartList[index]
      //     .attribNameList
      //     .add(_selectedCrustSeperated2[0].toString());
      // cartList[index]
      //     .attribNameList
      //     .add(_selectedSauceSeperated2[0].toString());

      _total += _crustPrice2 + _saucePrice2;

      for (var topping2 in selectedToppings2) {
        addPizzaAttributes(index, topping2.name.toString(), 0.0);
        // cartList[index].attribNameList.add(topping2.name.toString());
        // cartList[index].attribPriceList.add(0.0);
        // _attribNameList.add();
        // _attribPriceList.add(0.0);
        _total += topping2.price;
      }
    }

    cartList[index].price += _total;

    discardPizza();
    update();
  }

  // add pizza data to attribute List
  void addPizzaAttributes(int index, String name, double price) {
    cartList[index].attribNameList.add(name);
    cartList[index].attribPriceList.add(price);
  }

  // reset values
  void discardPizza() {
    isHnH.value = false;
    isEditPizza = false;

    selectedSize.value = sizeList.reversed.toList()[0];

    selectedToppings1.clear();
    selectedCrust1.value = crustList.reversed.toList()[0];
    selectedSauce1.value = sauceList.reversed.toList()[0];

    selectedToppings2.clear();
    selectedCrust2.value = crustList.reversed.toList()[0];
    selectedSauce2.value = sauceList.reversed.toList()[0];
  }

  // category selector
  void changePressedIndex(int index) {
    pressedIndex = RxInt(index);
    update();
  }

  // get menu data with the search
  Future<void> getMenu(String searchStr, String selectedCat) async {
    QuerySnapshot menuSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc("/itemDetails")
        .collection('items')
        .orderBy('name')
        .get();

    filteredDocs.clear();

    for (var item in menuSnap.docs) {
      bool _containSearchStr = false;
      bool _containCat = false;
      var _itemCatList = List.from(item['cat']);

      if (_itemCatList
          .toString()
          .toLowerCase()
          .contains(RegExp('pizza', caseSensitive: false))) {
        getPizzaData();
      }

      _containSearchStr = item['name']
          .toString()
          .contains(RegExp(searchStr, caseSensitive: false));

      _containCat = pressedIndex.value != 0
          ? _itemCatList.toString().toLowerCase().contains(
              RegExp(catList[pressedIndex.value], caseSensitive: false))
          : true;

      if (_containSearchStr && _containCat) {
        Map _main = Map();
        Map _addons = Map();
        Map _drinks = Map();
        int _drinkLimit = 0, _addonLimit = 0;

        if (_itemCatList.toString().toLowerCase().contains('combo')) {
          _main = item['main'];
          _addons = item['addon'];
          _drinks = item['drinks'];
          _addonLimit = item['addon_limit'];
          _drinkLimit = item['drink_limit'];
        }

        filteredDocs.add(MenuModel(item.id, item.data(), _main, _addons,
            _drinks, _addonLimit, _drinkLimit));
      }
    }
    update();
  }

  // add to cart
  addToCart(CartModel cartModel) {
    cartList.add(cartModel);
    update();
  }

  // add qty
  addQty(int index) {
    cartList[index].qty++;
    update();
  }

  // remove qty
  removeQty(int index) {
    if (cartList[index].qty > 1) {
      cartList[index].qty--;
      update();
    }
  }

  // remove an item added
  removeItem(int index) {
    cartList.removeAt(index);
    update();
  }

  //void item
  voidItem(int index, String notes) {
    addNotes(index, notes);
    cartList[index].isVoid = true;
    cartList[index].price = 0.0;
    cartList[index].attribPriceList.clear();

    for (var i = 0; i < cartList[index].attribNameList.length; i++) {
      cartList[index].attribPriceList.add(0.0);
    }

    // for (var item in cartList[index].attribNameList) {}
    update();
  }

  // add/remove attributes
  attributeHandler(int index, String name, double price) {
    bool _isAvailable = false;

    for (var i = 0; i < cartList[index].attribNameList.length; i++) {
      if (cartList[index].attribNameList[i] == name) {
        cartList[index].attribNameList.removeAt(i);
        cartList[index].attribPriceList.removeAt(i);
        _isAvailable = true;
      }
    }

    if (!_isAvailable) {
      cartList[index].attribNameList.add(name);
      cartList[index].attribPriceList.add(price);
    }

    update();
  }

  // adding notes
  addNotes(int index, String notes) {
    cartList[index].notes = notes;
    update();
  }

  // reading the attributes
  Stream<dynamic> getAttributes() {
    return FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('itemDetails')
        .snapshots();
  }

  void scrollDown() {
    end.value = scrollController.position.maxScrollExtent;
    scrollController.jumpTo(end.value);
  }

  // make the kitchen order
  sendToKitchen(
      String orderId,
      String tableName,
      String cusName,
      String cusMobile,
      int seats,
      String tableId,
      bool dineIn,
      bool takeAway,
      String orderTime,
      bool isPrintTicket,
      bool isCusReceipt,
      String printerName,
      bool isKOT) async {
    isSendToKitchen = true;
    int count = 0;
    List<int> _qty = [];
    List<double> _itemPriceList = [];
    List<double> _attribPrice = [];
    List<String> _notes = [];
    List<String> _itemNameList = [];
    List<String> _attribName = [];
    List<int> _attribParentIndex = [];
    List<bool> _void = [];

    cartList.forEach((element) {
      _itemNameList.add(element.name);
      _itemPriceList.add(element.price);
      _qty.add(element.qty);
      _notes.add(element.notes);
      _void.add(element.isVoid);
      element.attribNameList.forEach((element) {
        _attribName.add(element);
        _attribParentIndex.add(count);
      });
      element.attribPriceList.forEach((element) => _attribPrice.add(element));
      count++;
    });

    try {
      FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('kitchenOrderTicket')
          .collection(
              isRead ? _readDate : globalController.currDateDashDelimated)
          .doc(orderId)
          .set(
        {
          'customerName': cusName,
          'customerNumber': cusMobile,
          'date': isRead ? _readDate : globalController.currDateDashDelimated,
          'dateTimeStampISO': DateTime.now().toIso8601String(),
          'guestNumber': seats,
          'itemname': _itemNameList,
          'notes': _notes,
          'void': _void,
          'orderId': orderId,
          'productPriceList': _itemPriceList,
          'qty': _qty,
          'attribNames': _attribName,
          'attribPrice': _attribPrice,
          'attribParentIndex': _attribParentIndex,
          'server': authController.userName.value,
          'serverId': authController.userId.value,
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
              'Status': 'Occupied',
              'dateStamp':
                  isRead ? _readDate : globalController.currDateDashDelimated,
              'orderId': orderId,
            });

            FirebaseFirestore.instance
                .collection(authController.shopName.toString())
                .doc("/tableDetails")
                .collection('TableNo')
                .doc(tableId)
                .set(
              {
                'isLocked': false,
              },
              SetOptions(merge: true),
            );
          } else {
            if (takeAway == true) {
              FirebaseFirestore.instance
                  .collection(authController.shopName.toString())
                  .doc("takeWay")
                  .collection('/' + 'takeWayDetails')
                  .doc(orderId)
                  .set({
                "orderId": orderId,
                "preparing": "0",
                "MobileNumber": cusMobile,
                "name": cusName,
                "time": orderTime,
                'dateStamp':
                    isRead ? _readDate : globalController.currDateDashDelimated,
                // "Status" : status,
              });
            } else {
              FirebaseFirestore.instance
                  .collection(authController.shopName.toString())
                  .doc("Delivery")
                  .collection('/' + 'DeliveryDetails')
                  .doc(orderId)
                  .set({
                "orderId": orderId,
                "preparing": "0",
                "MobileNumber": cusMobile,
                "name": cusName,
                "time": orderTime,
                'dateStamp':
                    isRead ? _readDate : globalController.currDateDashDelimated,
                // "Status" : status,
              });
            }
          }
        },
      );

      if (cartList.where((item) => item.isRead == false).length > 0 ||
          isPrintTicket ||
          isCusReceipt) {
        if (isKOT) {
          for (var item in cartList) {
            if (!item.isRead) {
              switch (item.printer) {
                case 1:
                  _posPrintList.add(item);
                  break;
                case 2:
                  _kot1PrintList.add(item);
                  break;
                case 3:
                  _kot2PrintList.add(item);
                  break;
                case 4:
                  _kot3PrintList.add(item);
                  break;
                default:
                  _kot1PrintList.add(item);
                  break;
              }
            }
          }
          printSpecific(orderId, tableName, cusName, isKOT);
        } else {
          await printTicket(
              orderId, tableName, cusName, 'posPrinter', isKOT, null);
        }
      }
      isSendToKitchen = false;
      Get.delete<OrderController>();
      // if (!isPrintTicket) {
      //   // cartList.clear();
      //   Get.back();
      // }

      if (dineController.isPreviousOrder) {
        Get.back();
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
  }

  // Printing KOT - Printer Specific
  Future<void> printSpecific(
      String orderId, String tableName, String cusName, bool isKOT) async {
    if (_kot1PrintList.length > 0) {
      await printTicket(
          orderId, tableName, cusName, 'kotPrinter', isKOT, _kot1PrintList);
    }

    if (_kot2PrintList.length > 0) {
      await printTicket(
          orderId, tableName, cusName, 'kot2Printer', isKOT, _kot2PrintList);
    }

    if (_kot3PrintList.length > 0) {
      await printTicket(
          orderId, tableName, cusName, 'kot3Printer', isKOT, _kot3PrintList);
    }

    if (_posPrintList.length > 0) {
      await printTicket(
          orderId, tableName, cusName, 'posPrinter', isKOT, _posPrintList);
    }
  }

  // Calling method for print a ticket
  Future<void> printTicket(String orderId, String tableName, String cusName,
      String printerName, bool isKOT, List<CartModel> itemList) async {
    if (cartList.length > 0) {
      List<String> printerList = [];

      DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('settings')
          .get();

      printerList = List.from(settingsSnap[printerName]);

      const PaperSize paper = PaperSize.mm80;
      for (var i = 0; i < printerList.length; i++) {
        String address = printerList[i];

        if (address.isIpAddress) {
          PrinterNetworkManager _printerNetworkManager =
              PrinterNetworkManager();
          _printerNetworkManager.selectPrinter(address);

          // if (isKOT) {
          //   await kotTicketTemplate(
          //       paper, orderId, tableName, cusName, itemList);
          // } else {
          //   await posTicketTemplate(
          //       paper, orderId, tableName, cusName, settingsSnap);
          // }
          final res = await _printerNetworkManager.printTicket(isKOT
              ? await kotTicketTemplate(
                  paper, orderId, tableName, cusName, itemList)
              : await posTicketTemplate(
                  paper, orderId, tableName, cusName, settingsSnap));

          print(res.msg);
        } else {
          //print("Error :e");
        }
      }
    }
    isSendPressed.value = false;
    update();
  }

  // upaid ticket template
  Future<Ticket> posTicketTemplate(PaperSize paper, String orderId,
      String tableName, String cusName, DocumentSnapshot settingsSnap) async {
    GlobalController globalController = Get.find<GlobalController>();

    DocumentSnapshot businessSnap = await FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('businessProfile')
        .get();

    final Ticket ticket = Ticket(paper);

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

    for (var i = 0; i < cartList.length; i++) {
      double _subTotal = 0;
      List<String> _attribName = [];
      List<double> _attribPrice = [];

      for (var j = 0; j < cartList[i].attribNameList.length; j++) {
        _attribName.add(cartList[i].attribNameList[j]);
        _attribPrice.add(cartList[i].attribPriceList[j]);
      }

      _subTotal = cartList[i].price +
          (_attribPrice.fold(0, (previous, element) => previous + element));

      ticket.row([
        PosColumn(
          text: '${cartList[i].name}',
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
          // text: '\$${cartList[i].price.toStringAsFixed(2)}',
          width: 4,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
            width: PosTextSize.size1,
          ),
        ),
      ]);

      ticket.text(
        '${cartList[i].qty}pc(s) x \$${cartList[i].price.toStringAsFixed(2)}',
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
      // for (var j = 0; j < cartList[i].attribNameList.length; j++) {
      //   ticket.text(
      //     '-${cartList[i].attribNameList[j]}  ${cartList[i].attribPriceList[j] > 0 ? 'x\$' + cartList[i].attribPriceList[j].toStringAsFixed(2) : ''}',
      //     styles: PosStyles(
      //       bold: true,
      //     ),
      //   );
      // }

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
    //     text: inclusiveGST
    //         ? '\$${((total * gstVal) - total).toStringAsFixed(2)}'
    //         : '\$0.00',
    //     width: 4,
    //     styles: PosStyles(
    //       bold: true,
    //       align: PosAlign.right,
    //       width: PosTextSize.size1,
    //     ),
    //   ),
    // ]);

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
        text: '\$${(totalPrice * settingsSnap['gstAmt']).toStringAsFixed(2)}',
        width: 4,
        styles: PosStyles(
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    ]);

    ticket.feed(1);

    // unpaid tag
    ticket.row([
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
        text: '[UNPAID]',
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
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
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
    ticket.row([
      PosColumn(
        text: 'THANK YOU! HAVE A NICE DAY!',
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

  // KOT Ticket Template
  Future<Ticket> kotTicketTemplate(PaperSize paper, String orderId,
      String tableName, String cusName, List<CartModel> itemList) async {
    final Ticket ticket = Ticket(paper);

    ticket.feed(4);

    ticket.text(
      'KOT# $orderId',
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
      'Table: $tableName',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    ticket.feed(1);
    ticket.text(
      'Customer: $cusName',
      styles: PosStyles(
        align: PosAlign.center,
        // height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    // ticket.feed(1);
    ticket.text(
      'Order taken by: ${authController.userName}',
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

    for (var i = 0; i < itemList.length; i++) {
      if (!itemList[i].isRead || itemList[i].isVoid) {
        ticket.text(
          itemList[i].qty.toString() + ' x ' + itemList[i].name,
          styles: PosStyles(
            // height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );
        itemList[i].notes.length > 0 || itemList[i].isVoid
            ? ticket.text(
                itemList[i].isVoid ? 'Void' : 'Notes:' + itemList[i].notes,
                styles: PosStyles(
                  // height: PosTextSize.size2,
                  width: PosTextSize.size2,
                  bold: itemList[i].isVoid,
                  reverse: itemList[i].isVoid,
                ),
                linesAfter: 1,
              )
            : ticket.beep();
        itemList[i].attribNameList.length > 0
            ? ticket.text(
                'Extras: \n-' + itemList[i].attribNameList.join('\n-'),
                maxCharsPerLine: 20,
                styles: PosStyles(
                  // height: PosTextSize.size2,
                  width: PosTextSize.size2,
                ),
                linesAfter: 1,
              )
            : ticket.beep();
      }
    }

    ticket.cut();
    // ticket.drawer();
    return ticket;
  }

  // get items from exisiting order
  getPrevOrder(String orderId, String date) async {
    _readDate = date;
    if (!isRead) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('kitchenOrderTicket')
          .collection(date)
          .doc(orderId)
          .get();

      List<String> _itemNamesList = List.from(snapshot['itemname']);
      List<String> _notesList = List.from(snapshot['notes']);
      List<double> _priceList = [];
      List<int> _qtyList = List.from(snapshot['qty']);
      List<bool> _isVoid = List.from(snapshot['void']);
      List<String> _attribNameList = List.from(snapshot['attribNames']);
      List<double> _attribPriceList = [];
      //= List.from(snapshot['attribPrice']);
      List<int> _attribParentIndexList =
          List.from(snapshot['attribParentIndex']);

      for (var productPriceList in snapshot['productPriceList']) {
        print(productPriceList);
        _priceList.add(double.parse(productPriceList.toString()));
      }

      for (var attribPrice in snapshot['attribPrice']) {
        print(attribPrice);
        _attribPriceList.add(double.parse(attribPrice.toString()));
      }

      for (var i = 0; i < _itemNamesList.length; i++) {
        // print(_itemNamesList[i]);
        // print(_priceList[i]);
        // print(_qtyList[i]);
        // print(_notesList[i]);

        List<String> _renderedAttriNameList = [];
        List<double> _renderedAttriPriceList = [];

        for (var j = 0; j < _attribPriceList.length; j++) {
          if (i == _attribParentIndexList[j]) {
            _renderedAttriNameList.add(_attribNameList[j]);
            _renderedAttriPriceList
                .add(double.parse(_attribPriceList[j].toStringAsFixed(2)));
          }
        }

        var _cartList = CartModel(
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

        addToCart(_cartList);
        isRead = true;
      }
    } else {
      // Get.snackbar(
      //   'Error loading data!',
      //   'Error occured while loading data',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 1),
      // );
    }
  }

  // checking if its a previous order
  previousOrderCheck() {
    if (dineController.isPreviousOrder) {
      cartList = dineController.previousOrderList;
      dineController.isPreviousOrder = false;
    }

    update();
  }

  // sending back
  routeBack(String tableId) async {
    if (!isSendPressed.value && tableId != null) {
      if (!dineController.isPreviousOrder && !isRead) {
        // int size = cartList.length;
        // for (var i = 0; i < size; i++) {
        //   removeItem(i);
        // }
        while (cartList.length > 0) {
          removeItem(0);
        }
      }

      isSendPressed.value = true;
      String tableStatus = cartList.length > 0 && isRead ? 'Occupied' : '';
      FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc("/tableDetails")
          .collection('TableNo')
          .doc(tableId)
          .set(
        {
          'isLocked': false,
          'Status': tableStatus,
        },
        SetOptions(merge: true),
      ).then((value) {
        dineController.isPreviousOrder = false;
        isSendPressed.value = false;
        Get.delete<OrderController>();
        Get.offAll(() => Dashboard());
      });

      // while (cartList.length > 0) {
      //   removeItem(0);
      // }

    }
  }

  void setItemAvalibility(String id, bool isAvailable) {
    FirebaseFirestore.instance
        .collection(authController.shopName.toString())
        .doc('itemDetails')
        .collection('items')
        .doc(id)
        .set(
      {
        'isAvailablity': !isAvailable,
      },
      SetOptions(merge: true),
    ).then((value) => getMenu('', 'All Items'));
  }
}
