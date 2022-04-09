import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/screens/order/localWidgets/selectable_items.dart';
import 'package:flutter/material.dart';

import 'combo_main_items.dart';
import 'dialog_header.dart';

class ComboDialog extends StatelessWidget {
  const ComboDialog({
    Key key,
    @required this.screenSize,
    @required this.itemIndex,
    @required this.controller,
  }) : super(key: key);

  final Size screenSize;
  final int itemIndex;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    controller.flushComboData();

    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: DialogHeader(
        title: controller.filteredDocs[itemIndex].data['name'].toString(),
        screenSize: screenSize,
        onSave: () {
          controller.addComboToOrder(itemIndex);
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
            ComboMainItems(
              title: 'Main',
              data: controller.filteredDocs[itemIndex].main,
              screenSize: screenSize,
              onPressFunction: controller.setSelectedValue,
              selectVar: controller.selectedSize,
            ),
            Divider(),
            SelectableItems(
              screenSize: screenSize,
              title: 'Add-ons',
              data: controller.filteredDocs[itemIndex].addons,
              onPressFunction: controller.addItemsToArray,
              selectedArray: controller.selectedAddons,
              limit: controller.filteredDocs[itemIndex].addonLimit,
            ),
            Divider(),
            SelectableItems(
              screenSize: screenSize,
              title: 'Dinks',
              data: controller.filteredDocs[itemIndex].drinks,
              onPressFunction: controller.addItemsToArray,
              selectedArray: controller.selectedDrinks,
              limit: controller.filteredDocs[itemIndex].drinksLimit,
            ),
          ],
        ),
      ),
    );
  }
}
