import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:dropin_pos_v2/screens/settings/localWidgets/item_list_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody(
      {Key key,
      @required this.screenSize,
      @required this.controller,
      @required this.itemIndex})
      : super(key: key);

  final Size screenSize;
  final SettingsController controller;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: SingleChildScrollView(
        child: Scrollbar(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.02),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Payment Type : ',
                      style: TextStyle(
                          color: Palette.black,
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.width * 0.018),
                      children: [
                        TextSpan(
                          text: controller.prevOrderList[itemIndex].paymentType,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('dd-MM-yyyy')
                        .add_jm()
                        .format(DateTime.parse(
                            controller.prevOrderList[itemIndex].dateISO))
                        .toString(),
                    style: TextStyle(
                      fontSize: screenSize.width * 0.018,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.03),
              Text(
                'Items',
                style: TextStyle(
                    color: Palette.black,
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.018),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Divider(),
              SizedBox(height: screenSize.height * 0.02),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: screenSize.height * 0.01),
                  itemCount:
                      controller.prevOrderList[itemIndex].itemList.length,
                  itemBuilder: (context, index) => ItemListText(
                      screenSize: screenSize,
                      item: controller.prevOrderList[itemIndex].itemList[index]
                          .toString(),
                      price: controller
                          .prevOrderList[itemIndex].priceList[index]
                          .toStringAsFixed(2),
                      isVisible: controller.prevOrderList[itemIndex]
                              .attributeNameList.length >
                          0,
                      attributeList: controller
                          .prevOrderList[itemIndex].attributeNameList)),
              SizedBox(height: screenSize.height * 0.01),
              Divider(),
              SizedBox(height: screenSize.height * 0.02),
              ItemListText(
                screenSize: screenSize,
                item: 'Sub Total',
                price: controller.prevOrderList[itemIndex].subTotal
                    .toStringAsFixed(2),
                isVisible: false,
                isItemTextBold: false,
                isPriceTextBold: false,
                attributeList: [],
                itemTextSize: 0.018,
                priceTextSize: 0.018,
              ),
              SizedBox(height: screenSize.height * 0.02),
              ItemListText(
                screenSize: screenSize,
                item: 'G.S.T',
                price:
                    controller.prevOrderList[itemIndex].gst.toStringAsFixed(2),
                isVisible: false,
                isItemTextBold: false,
                isPriceTextBold: false,
                attributeList: [],
                itemTextSize: 0.018,
                priceTextSize: 0.018,
              ),
              SizedBox(height: screenSize.height * 0.02),
              ItemListText(
                screenSize: screenSize,
                item: 'Surcharge',
                price: controller.prevOrderList[itemIndex].surcharge
                    .toStringAsFixed(2),
                isVisible: false,
                isItemTextBold: false,
                isPriceTextBold: false,
                attributeList: [],
                itemTextSize: 0.018,
                priceTextSize: 0.018,
              ),
              SizedBox(height: screenSize.height * 0.02),
              ItemListText(
                screenSize: screenSize,
                item: 'Discount',
                price: controller.prevOrderList[itemIndex].discount
                    .toStringAsFixed(2),
                isVisible: false,
                isItemTextBold: false,
                isPriceTextBold: false,
                attributeList: [],
                itemTextSize: 0.018,
                priceTextSize: 0.018,
              ),
              SizedBox(height: screenSize.height * 0.02),
              ItemListText(
                screenSize: screenSize,
                item: 'Total',
                price: controller.prevOrderList[itemIndex].total
                    .toStringAsFixed(2),
                isVisible: false,
                attributeList: [],
                itemTextSize: 0.02,
                priceTextSize: 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
