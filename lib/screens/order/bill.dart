import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';
import 'package:dropin_pos_v2/screens/pay/payScreen.dart';
import 'package:dropin_pos_v2/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:ionicons/ionicons.dart';

import 'localWidgets/dialog_header.dart';
import 'localWidgets/voidPin.dart';

class Bill extends StatefulWidget {
  final orderId;
  final tableId;
  final tableName;
  final cusName;
  final cusMobile;
  final seats;
  final isReOrder;
  final dateStamp;
  final orderTime;
  final bool dineIn;
  final bool takeAway;

  const Bill({
    Key key,
    this.orderId,
    this.cusName,
    this.seats,
    this.tableName,
    this.isReOrder,
    this.tableId,
    this.dateStamp,
    this.orderTime,
    this.takeAway,
    this.dineIn,
    this.cusMobile,
  }) : super(key: key);

  @override
  _BillState createState() => _BillState();
}

class _BillState extends State<Bill> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    Size screenSize = MediaQuery.of(context).size;
    bool isRead = false;
    return GetBuilder<OrderController>(
      init: OrderController(),
      builder: (orderController) {
        orderController.previousOrderCheck();
        if (widget.isReOrder && !isRead) {
          orderController.getPrevOrder(widget.orderId, widget.dateStamp);
          isRead = true;
        }
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: buildTableSelector(screenSize, authController,
                  widget.tableName, orderController, widget.tableId),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.height * 0.01,
                  horizontal: screenSize.width * 0.005,
                ),
                child: Column(
                  children: [
                    buildHeader(screenSize, authController, widget.orderId,
                        widget.cusName, widget.seats),
                    IconButton(
                        onPressed: () {
                          orderController.scrollController.jumpTo(0);
                        },
                        icon: Icon(Icons.arrow_circle_up_outlined)),
                    buildItemList(
                        screenSize, orderController, widget.isReOrder, isRead),
                    IconButton(
                        onPressed: () {
                          orderController.scrollDown();
                        },
                        icon: Icon(Icons.arrow_circle_down_outlined)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  children: [
                    Divider(),
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            buildSubTotal(screenSize),
                            buildTotal(screenSize),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          screenSize.width * 0.02,
                          screenSize.width * 0.01,
                          screenSize.width * 0.02,
                          screenSize.width * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildButton(
                              screenSize,
                              Icons.send,
                              'Send to\nKitchen',
                              Colors.green,
                              Palette.white,
                              onPressed: () {
                                if (!orderController.isSendPressed.value) {
                                  orderController.isSendPressed.value = true;
                                  if (orderController.cartList.length > 0) {
                                    orderController.sendToKitchen(
                                      widget.orderId,
                                      widget.tableName,
                                      widget.cusName,
                                      widget.cusMobile,
                                      int.parse(widget.seats.toString()),
                                      widget.tableId,
                                      widget.dineIn,
                                      widget.takeAway,
                                      widget.orderTime,
                                      true,
                                      false,
                                      'kotPrinter',
                                      true,
                                    );
                                    Get.back();
                                  } else {
                                    Get.snackbar(
                                      'Add items',
                                      'Add items to be sent to kitchen.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Palette.primaryColor,
                                      colorText: Palette.white,
                                    );
                                  }
                                }
                              },
                              angle: -0.6,
                            ),

                            // buildButton(
                            //   screenSize,
                            //   Icons.block_flipped,
                            //   'Void',z
                            //   Colors.red[100],
                            //   Colors.red,
                            //   onPressed: () {
                            //     print('void');
                            //     orderController.getPrevOrder(
                            //         orderId, dateStamp);
                            //   },
                            // ),
                            buildButton(
                              screenSize,
                              Icons.print_outlined,
                              'Print Receipt',
                              Colors.blue[100],
                              Colors.blue,
                              onPressed: () => orderController.sendToKitchen(
                                widget.orderId,
                                widget.tableName,
                                widget.cusName,
                                widget.cusMobile,
                                int.parse(widget.seats.toString()),
                                widget.tableId,
                                widget.dineIn,
                                widget.takeAway,
                                widget.orderTime,
                                true,
                                true,
                                'posPrinter',
                                false,
                              ),
                            ),
                            // buildButton(
                            //   screenSize,
                            //   Ionicons.file_tray_full_outline,
                            //   'Open Drawer',
                            //   Palette.lightGrey,
                            //   Colors.black,
                            //   onPressed: () {
                            //     print('print');
                            //   },
                            // ),
                            GetBuilder<GlobalController>(
                              init: GlobalController(),
                              builder: (controller) => buildButton(
                                screenSize,
                                Icons.attach_money,
                                'Pay',
                                Colors.green[100],
                                Colors.green,
                                onPressed: () async {
                                  if (!orderController.isSendPressed.value) {
                                    // if (orderController.cartList
                                    //         .where((item) =>
                                    //             item.isRead == false)
                                    //         .length >
                                    //     0) {
                                    print(orderController.cartList.length);
                                    orderController.sendToKitchen(
                                      widget.orderId,
                                      widget.tableName,
                                      widget.cusName,
                                      widget.cusMobile,
                                      int.parse(widget.seats.toString()),
                                      widget.tableId,
                                      widget.dineIn,
                                      widget.takeAway,
                                      widget.orderTime,
                                      true,
                                      false,
                                      'kotPrinter',
                                      true,
                                    );
                                    Get.offAll(() => Dashboard());
                                    // }
                                    Get.to(
                                      () => PayScreen(
                                        orderId: widget.orderId,
                                        tableName: widget.tableName,
                                        date: widget.dateStamp,
                                        cusName: widget.cusName,
                                        cusMobile: widget.cusMobile,
                                        dineIn: widget.dineIn,
                                        takeAway: widget.takeAway,
                                        tableId: widget.tableId,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget buildItemList(Size screenSize, OrderController controller,
        bool isReOrder, bool isRead) =>
    Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.01,
          vertical: screenSize.height * 0.01,
        ),
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.count,
          itemBuilder: (context, index) {
            // void check(){
            //   if(isReOrder && isRead) {
            //     controller.end.value= controller.scrollController.position.maxScrollExtent;
            //     controller.scrollController.jumpTo(controller.end.value);
            //   }
            // }

            return Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.addDefaultPizzaSelection(index);
                        controller.cartList[index].isRead
                            // ignore: unnecessary_statements
                            ? null
                            : controller.cartList[index].isPizza
                                ? controller.isEditPizza
                                    ? controller.setIsEditPizza(false)
                                    : pizzaOptions(
                                        context, screenSize, controller, index)
                                : addNotes(screenSize, controller, index);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  controller.cartList[index].name.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 5,
                                  // textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenSize.width * 0.018,
                                    decoration:
                                        controller.cartList[index].isVoid
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                    color: controller.cartList[index].isVoid ||
                                            controller.cartList[index].isRead
                                        ? Palette.darkGrey
                                        : Palette.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          controller.cartList[index].notes.toString() != ''
                              ? Text(
                                  'Notes: ' +
                                      controller.cartList[index].notes
                                          .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: controller.cartList[index].isVoid ||
                                            controller.cartList[index].isRead
                                        ? Palette.darkGrey
                                        : Palette.black,
                                  ),
                                )
                              : SizedBox.shrink(),
                          controller.cartList[index].attribNameList.length > 0
                              ? Text(
                                  '- ' +
                                      controller.cartList[index].attribNameList
                                          .join('\n- ')
                                          .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration:
                                        controller.cartList[index].isVoid
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                    color: controller.cartList[index].isVoid ||
                                            controller.cartList[index].isRead
                                        ? Palette.darkGrey
                                        : Palette.black,
                                  ),
                                )
                              : SizedBox.shrink(),
                          SizedBox(height: screenSize.height * 0.02),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.cartList[index].isRead
                            ? SizedBox.shrink()
                            : IconButton(
                                onPressed: () => controller.removeQty(index),
                                icon: Icon(Icons.remove)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.01,
                            horizontal: screenSize.width * 0.01,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: controller.cartList[index].isVoid ||
                                    controller.cartList[index].isRead
                                ? Palette.lightGrey
                                : Palette.lightGrey,
                          ),
                          child: Text(
                            controller.cartList[index].qty.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width * 0.016,
                              decoration: controller.cartList[index].isVoid
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: controller.cartList[index].isVoid ||
                                      controller.cartList[index].isRead
                                  ? Palette.darkGrey
                                  : Palette.black,
                            ),
                          ),
                        ),
                        controller.cartList[index].isRead
                            ? SizedBox.shrink()
                            : IconButton(
                                onPressed: () => controller.addQty(index),
                                icon: Icon(Icons.add)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${((controller.cartList[index].price + controller.cartList[index].attribPriceList.fold(0, (sum, attrib) => sum + attrib)) * controller.cartList[index].qty).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.016,
                            fontWeight: FontWeight.bold,
                            decoration: controller.cartList[index].isVoid
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: controller.cartList[index].isVoid ||
                                    controller.cartList[index].isRead
                                ? Palette.darkGrey
                                : Palette.black,
                          ),
                        ),
                        controller.cartList[index].isRead
                            ? !controller.cartList[index].isVoid
                                ? IconButton(
                                    onPressed: () => Get.defaultDialog(
                                        title: 'Enter Authorization PIN',
                                        content: VoidPIN(index: index)),
                                    icon: Icon(
                                      Icons.block_flipped,
                                      color: Colors.red,
                                      size: screenSize.width * 0.02,
                                    ),
                                  )
                                : //hidden button to keep the placment size
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.block_flipped,
                                      color: Colors.transparent,
                                      size: screenSize.width * 0.02,
                                    ),
                                  )
                            : IconButton(
                                onPressed: () => controller.removeItem(index),
                                icon: Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                  size: screenSize.width * 0.025,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

// pizza option
pizzaOptions(BuildContext context, Size screenSize, OrderController controller,
    int itemIndex) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: DialogHeader(
          title: controller.cartList[itemIndex].name.toString(),
          screenSize: screenSize,
          onSave: () {
            controller.pizzaSave(itemIndex);
            Navigator.of(context).pop();
          },
          onCancel: () {
            controller.discardPizza();
            Navigator.of(context).pop();
          },
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        'Select Size',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(width: screenSize.width * 0.02),
                  SizedBox(
                    height: screenSize.height * 0.1,
                    width: screenSize.width * 0.6,
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.sizeList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(() => BuildIconButtonWithText(
                                    onPressed: () => controller.setSelectedSize(
                                        controller.sizeList.reversed
                                            .toList()[index]
                                            .toString()),
                                    selectedVal: controller.selectedSize.value,
                                    screenSize: screenSize,
                                    controller: controller,
                                    title: controller.sizeList.reversed
                                        .toList()[index],
                                    icon: Ionicons.pizza_outline,
                                  )),
                              SizedBox(width: screenSize.width * 0.01)
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => FittedBox(
                        fit: BoxFit.contain,
                        child: Text('Full',
                            style: TextStyle(
                                color: !controller.isHnH.value
                                    ? Palette.black
                                    : Palette.darkGrey,
                                fontWeight: !controller.isHnH.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 18)),
                      )),
                  Obx(
                    () => Switch(
                      value: controller.isHnH.value,
                      onChanged: (value) {
                        if (!controller.isEditPizza) {
                          controller.isHnH.toggle();
                        }
                      },
                      activeTrackColor: !controller.isEditPizza
                          ? Palette.secondaryColor
                          : Palette.lightGrey,
                      activeColor: !controller.isEditPizza
                          ? Palette.primaryColor
                          : Palette.lightGrey,
                      inactiveTrackColor: !controller.isEditPizza
                          ? Palette.secondaryColor
                          : Palette.lightGrey,
                      inactiveThumbColor: !controller.isEditPizza
                          ? Palette.primaryColor
                          : Palette.lightGrey,
                    ),
                  ),
                  Obx(() => FittedBox(
                        fit: BoxFit.contain,
                        child: Text('H&H',
                            style: TextStyle(
                                color: controller.isHnH.value
                                    ? Palette.black
                                    : Palette.darkGrey,
                                fontWeight: controller.isHnH.value
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 18)),
                      )),
                ],
              ),
              Divider(thickness: 1, color: Palette.black),
              Obx(
                () => controller.isHnH.value
                    ? Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: buildSelections(
                              screenSize,
                              controller,
                              1,
                              controller.selectedCrust1,
                              controller.selectedSauce1,
                              controller.selectedToppings1,
                            ),
                          ),
                          // SizedBox(width: screenSize.width * 0.01),
                          Expanded(
                            flex: 1,
                            child: buildSelections(
                              screenSize,
                              controller,
                              2,
                              controller.selectedCrust2,
                              controller.selectedSauce2,
                              controller.selectedToppings2,
                            ),
                          ),
                        ],
                      )
                    : buildSelections(
                        screenSize,
                        controller,
                        1,
                        controller.selectedCrust1,
                        controller.selectedSauce1,
                        controller.selectedToppings1,
                      ),
              )
            ],
          ),
        ),
      );
    },
  );
}

// Widget buildPizzaSelection(Size screenSize, OrderController controller)=>

Widget buildSelections(Size screenSize, OrderController controller, int side,
        var selectedCrust, var selectedSauce, var selectedToppings) =>
    Container(
      // padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.01),
          BuildCrust(
              controller: controller,
              screenSize: screenSize,
              side: side,
              selectedCrust: selectedCrust),
          SizedBox(height: screenSize.height * 0.04),
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    ' Select Sauce',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.015),
              Align(
                  alignment: Alignment.centerLeft,
                  child: BuildDropDown(
                      screenSize: screenSize,
                      list: controller.sauceList,
                      onChanged: (value) =>
                          controller.setSelectedSauce(side, value),
                      value: selectedSauce.value.toString())),
            ],
          ),
          SizedBox(height: screenSize.height * 0.03),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                ' Select Toppings',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: screenSize.width * 0.8,
                height: screenSize.height * 1,
                child: GridView.builder(
                  physics: !controller.isHnH.value
                      ? NeverScrollableScrollPhysics()
                      : null,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: controller.isHnH.value ? 3 : 6,
                      crossAxisSpacing: screenSize.width * 0.01,
                      mainAxisSpacing: screenSize.width * 0.01),
                  itemCount: controller.toppingsList.length,
                  itemBuilder: (context, index) {
                    return Obx(() => ElevatedButton(
                        onPressed: () => controller.addToppings(
                            controller.toppingsList[index], side),
                        style: ElevatedButton.styleFrom(
                            primary: selectedToppings
                                    .where((element) =>
                                        element.name ==
                                        controller.toppingsList[index]
                                            .split('\n')[0])
                                    .isNotEmpty
                                ? Palette.primaryColor
                                : Palette.white,
                            elevation: 0,
                            side: BorderSide(
                              color: selectedToppings
                                      .where((element) =>
                                          element.name ==
                                          controller.toppingsList[index]
                                              .split('\n')[0])
                                      .isNotEmpty
                                  ? Palette.primaryColor
                                  : Palette.black,
                            ),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.0,
                                horizontal: screenSize.width * 0.02)),
                        child: Center(
                            child: Text(
                          controller.toppingsList[index],
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: selectedToppings
                                      .where((element) =>
                                          element.name ==
                                          controller.toppingsList[index]
                                              .split('\n')[0])
                                      .isNotEmpty
                                  ? Palette.white
                                  : Palette.black,
                              fontSize: screenSize.width * 0.016),
                        ))));
                  },
                ),
              )),
        ],
      ),
    );

class BuildCrust extends StatelessWidget {
  final screenSize, controller, side, selectedCrust;
  const BuildCrust({
    Key key,
    this.screenSize,
    this.controller,
    @required this.side,
    @required this.selectedCrust,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    ' Select Crust',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.02),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: screenSize.height * 0.1,
                  width: screenSize.width * 0.8,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.crustList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() => BuildIconButtonWithText(
                                  onPressed: () => controller.setSelectedCrust(
                                      side,
                                      controller.crustList.reversed
                                          .toList()[index]
                                          .toString()),
                                  screenSize: screenSize,
                                  controller: controller,
                                  selectedVal: selectedCrust.value,
                                  title: controller.crustList.reversed
                                      .toList()[index],
                                  icon: Ionicons.pizza_outline,
                                )),
                            SizedBox(width: screenSize.width * 0.01),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BuildIconButtonWithText extends StatelessWidget {
  final controller, screenSize, title, icon, onPressed;
  final selectedVal;

  BuildIconButtonWithText(
      {Key key,
      @required this.controller,
      @required this.screenSize,
      @required this.title,
      @required this.icon,
      @required this.selectedVal,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(selectedVal);
    return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: screenSize.width * 0.03,
          color: selectedVal == title ? Palette.white : Palette.black,
        ),
        style: ElevatedButton.styleFrom(
            primary:
                selectedVal == title ? Palette.primaryColor : Palette.white,
            elevation: 0,
            side: BorderSide(
              color:
                  selectedVal == title ? Palette.primaryColor : Palette.black,
            ),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.02,
                horizontal: screenSize.width * 0.02)),
        label: FittedBox(
          fit: BoxFit.contain,
          child: Text(title,
              style: TextStyle(
                  color: selectedVal == title ? Palette.white : Palette.black,
                  fontSize: 16)),
        ));
  }
}

class BuildDropDown extends StatelessWidget {
  final onChanged, value, screenSize;

  final List<String> list;

  BuildDropDown({
    Key key,
    @required this.onChanged,
    @required this.value,
    @required this.list,
    @required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
      decoration: BoxDecoration(
          color: Palette.lightGrey, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          onChanged: onChanged,
          value: value,
          items: list.map((selectedType) {
            return DropdownMenuItem(
              child: Text(
                selectedType,
              ),
              value: selectedType,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// add notes and attributes
addNotes(Size screenSize, OrderController controller, int itemIndex) {
  TextEditingController _notesController = TextEditingController();
  TextEditingController _extrasController = TextEditingController();

  _notesController.text = controller.cartList[itemIndex].notes;
  _extrasController.text =
      controller.cartList[itemIndex].attribNameList.join(',').toString();

  Get.defaultDialog(
    title: controller.cartList[itemIndex].name.toString(),
    titleStyle: TextStyle(fontWeight: FontWeight.bold),
    content: Expanded(
      flex: 1,
      child: Container(
        width: screenSize.width * 0.5,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.01,
          vertical: screenSize.height * 0.02,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey[300]),
                            color: Colors.grey[100],
                          ),
                          child: TextFormField(
                            maxLines: 6,
                            controller: _notesController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: screenSize.width * .01,
                                top: screenSize.height * .01,
                              ),
                              hintText: 'Add notes here...',
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.03),
                        Text(
                          'Extras',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Container(
                          child: TextFormField(
                            maxLines: 3,
                            enabled: false,
                            controller: _extrasController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: screenSize.width * .01,
                              ),
                              hintText: 'No extras to be shown...',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.01),
                  // attributes
                  Expanded(
                    flex: 1,
                    child: Container(
                      // height: 200,
                      // color: Colors.purple,
                      child: StreamBuilder(
                        stream: controller.getAttributes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Loader(),
                            );
                          }
                          return Container(
                            height: screenSize.height * .445,
                            width: screenSize.width * .1,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data['attributesName'].length,
                              itemBuilder: (BuildContext context, int index) {
                                return FittedBox(
                                  fit: BoxFit.contain,
                                  child: Obx(
                                    () => ActionChip(
                                      backgroundColor:
                                          // controller.check
                                          //         .contains(snapshot
                                          //                 .data['attributesName']
                                          //             [index])
                                          //     ? Palette.primaryColor
                                          //     :
                                          Palette.mediumGrey,
                                      label: Text(
                                        '${snapshot.data['attributesName'][index]} - \$${snapshot.data['attributesPrice'][index].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          // fontSize: 100,
                                          color: controller.cartList[itemIndex]
                                                  .attribNameList
                                                  .contains(snapshot.data[
                                                      'attributesName'][index])
                                              ? Palette.white
                                              : Palette.black,
                                        ),
                                      ),
                                      onPressed: () {
                                        controller.attributeHandler(
                                          itemIndex,
                                          snapshot.data['attributesName'][index]
                                              .toString(),
                                          double.parse(snapshot
                                              .data['attributesPrice'][index]
                                              .toString()),
                                        );
                                        _extrasController.text = controller
                                            .cartList[itemIndex].attribNameList
                                            .join(',')
                                            .toString();
                                        controller.check.value =
                                            _extrasController.text;
                                        // print(
                                        //     'checking the cart list item index ${controller.cartList[itemIndex].attribNameList}');
                                        // print(
                                        //     '_extrasController ${_extrasController.text}');
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.1),
              // Buttons close / Save
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text('Close'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.06),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.addNotes(itemIndex, _notesController.text);
                        Get.back();
                      },
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        primary: Palette.primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.06),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

// customer name, order id, date, seats/people, server
Widget buildHeader(Size screenSize, AuthController authController,
        String orderId, var cusName, var seats) =>
    Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GetBuilder<GlobalController>(
            builder: (controller) => buildStaticData(
                screenSize, controller.currDateTimeSlashed.toString(), orderId,
                horzVal: 0.02),
          ),
          buildStaticData(screenSize, 'CUSTOMER', cusName.toString()),
          buildStaticData(screenSize, 'PEOPLE', seats.toString()),
          buildStaticData(
            screenSize,
            'SERVER',
            authController.userName.toString(),
            horzVal: 0.05,
            color: Colors.teal[100],
          ),
        ],
      ),
    );

//  buildHeader template
Widget buildStaticData(Size screenSize, String header, String statText,
        {double horzVal = 0.01, color = Palette.lightGrey}) =>
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * horzVal,
        vertical: screenSize.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              color: Palette.darkGrey,
              fontSize: screenSize.width * 0.012,
            ),
          ),
          SizedBox(height: screenSize.height * 0.005),
          Text(
            statText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color == Palette.lightGrey
                  ? Palette.darkGrey
                  : Colors.teal[400],
              fontSize: screenSize.width * 0.016,
            ),
          ),
        ],
      ),
    );

// send to kitchen, void, print, pay, open drawer button template
Widget buildButton(Size screenSize, IconData icon, String textStr,
        Color bgColor, Color iconColor,
        {double angle = 0, Function onPressed}) =>
    InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: CircleAvatar(
              maxRadius: screenSize.width * 0.025,
              backgroundColor: bgColor,
              child: Transform.rotate(
                angle: angle,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: screenSize.width * 0.03,
                ),
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            textStr,
            softWrap: true,
            style: TextStyle(
              fontSize: screenSize.width * 0.012,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

// Total footer
Widget buildTotal(Size screenSize) => Expanded(
      flex: 1,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.018,
              ),
            ),
            GetBuilder<OrderController>(
              init: OrderController(),
              builder: (controller) {
                return Text(
                  '${controller.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.026,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

// sub total - not shown ATM
Widget buildSubTotal(Size screenSize) => Expanded(
      flex: 2,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Text(
            //       'Sub Total',
            //       style: TextStyle(
            //         color: Palette.darkGrey,
            //         fontSize: screenSize.width * 0.014,
            //       ),
            //     ),
            //     Text(
            //       '\$0.00',
            //       style: TextStyle(
            //         color: Palette.darkGrey,
            //         fontSize: screenSize.width * 0.014,
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: screenSize.height * 0.01),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Text(
            //       'G.S.T      ',
            //       style: TextStyle(
            //         color: Palette.darkGrey,
            //         fontSize: screenSize.width * 0.014,
            //       ),
            //     ),
            //     Text(
            //       '\$0.00',
            //       style: TextStyle(
            //         color: Palette.darkGrey,
            //         fontSize: screenSize.width * 0.014,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );

// Black header showing table no.
Widget buildTableSelector(Size screenSize, AuthController authController,
        String tableName, OrderController orderController, String tableId) =>
    Container(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
      color: Colors.black87,
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.03),
          Expanded(
            flex: 2,
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        tableName,
                        style: TextStyle(
                            color: Palette.white,
                            fontWeight: FontWeight.w900,
                            fontSize: screenSize.width * 0.036),
                      ),
                    ),
                    // child: StreamBuilder(
                    //   stream: FirebaseFirestore.instance
                    //       .collection(authController.shopName.toString())
                    //       .doc("/tableDetails")
                    //       .collection('TableNo')
                    //       .orderBy('Name')
                    //       .snapshots(),
                    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //     if (!snapshot.hasData) {
                    //       return Center(
                    //         child: Loader(),
                    //       );
                    //     }

                    //     return ListView.builder(
                    //       scrollDirection: Axis.horizontal,
                    //       itemCount: snapshot.data.docs.length,
                    //       itemBuilder: (context, index) {
                    //         RxString _tableName = RxString(
                    //             snapshot.data.docs[index]['Name'].toString());
                    //         RxString _status =
                    //             RxString(snapshot.data.docs[index]['Status']);

                    //         return _status.toString() == 'Occupied' ||
                    //                 _status.toString() == 'Hold'
                    //             ? Row(
                    //                 children: [
                    //                   InkWell(
                    //                     onTap: () {
                    //                       print(_tableName.toString());
                    //                     },
                    //                     child: CircleAvatar(
                    //                       maxRadius: screenSize.width * 0.025,
                    //                       backgroundColor: Palette.darkGrey,
                    //                       child: Text(
                    //                         _tableName.toString(),
                    //                         style: TextStyle(
                    //                           color: Palette.white,
                    //                           fontSize:
                    //                               screenSize.width * 0.018,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   SizedBox(width: 10.0),
                    //                 ],
                    //               )
                    //             : SizedBox.shrink();
                    //       },
                    //     );
                    //   },
                    // ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: screenSize.width * 0.01),
                      child: ElevatedButton(
                        onPressed: () => Get.defaultDialog(
                          title: 'Are you sure?',
                          content: Column(
                            children: [
                              Text(
                                'You will loose all the changes made!',
                                maxLines: 3,
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Get.back(),
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                          color: Palette.white, fontSize: 24),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: Palette.darkGrey,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenSize.width * 0.05,
                                            vertical: screenSize.height * 0.01),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () =>
                                        orderController.routeBack(tableId),
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Palette.white, fontSize: 24),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenSize.width * 0.05,
                                            vertical: screenSize.height * 0.01),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Palette.white,
                            fontSize: screenSize.width * 0.016,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          primary: Palette.darkGrey,
                          padding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.02),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
