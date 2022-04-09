import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:dropin_pos_v2/screens/dashboard/dashboard.dart';
import 'package:dropin_pos_v2/screens/pay/localWidgets/cashKeypad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'localWidgets/discountPin.dart';

class Amount extends StatelessWidget {
  final payController;
  final date;
  final orderId;
  final tableId;
  final tableName;
  final bool dineIn;
  final bool takeAway;
  const Amount({
    Key key,
    @required this.payController,
    @required this.date,
    this.orderId,
    this.dineIn,
    this.takeAway,
    @required this.tableId,
    @required this.tableName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.fromLTRB(
        0,
        0,
        screenSize.height * 0.02,
        screenSize.height * 0.03,
      ),
      child: Column(
        children: [
          buildHeader(screenSize),
          buildAmount(screenSize, payController),
          buildPaymentOptions(screenSize, payController),
          Expanded(
            flex: 2,
            child: PayButton(screenSize),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container PayButton(Size screenSize) {
    return Container(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: double.infinity,
              height: screenSize.height * 0.06,
            ),
            child: ElevatedButton(
              onPressed: () => !payController.isPayPressed.value
                  ? payController.savePayment(
                      date,
                      orderId,
                      tableId,
                      tableName,
                      dineIn,
                      takeAway,
                    )
                  : null,
              child: Text(
                'Pay',
                style: TextStyle(fontSize: screenSize.width * 0.016),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.04),
          // ConstrainedBox(
          //   constraints: BoxConstraints.tightFor(
          //     width: double.infinity,
          //     height: screenSize.height * 0.05,
          //   ),
          //   child: ElevatedButton(
          //     onPressed: () {},
          //     child: Text(
          //       'Cancel Order',
          //       style: TextStyle(fontSize: screenSize.width * 0.016),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       primary: Colors.red,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildPaymentOptions(Size screenSize, PayController payController) =>
      Expanded(
        flex: 4,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a payment method',
                style: TextStyle(color: Palette.darkGrey),
              ),
              SizedBox(height: screenSize.height * 0.02),
              buildDiscountBar(screenSize),
              SizedBox(height: screenSize.height * 0.02),
              buildCardOrCash(screenSize),
              SizedBox(height: screenSize.height * 0.02),
              payController.isCash.value
                  ? buildCashBar(screenSize)
                  : buildCardType(screenSize),
              SizedBox(height: screenSize.height * 0.03),
              printCusCopySwitch(payController, screenSize),
            ],
          ),
        ),
      );

  Widget printCusCopySwitch(PayController payController, Size screenSize) =>
      Row(
        children: [
          Text(
            'Customer Copy:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.016,
            ),
          ),
          Obx(
            () => Switch(
              value: payController.isCusCopy.value,
              onChanged: (value) {
                payController.isCusCopy.toggle();
              },
              activeTrackColor: Palette.secondaryColor,
              activeColor: Palette.primaryColor,
            ),
          ),
          Spacer(),
          Text(
            'No Reciept:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.016,
            ),
          ),
          Obx(
            () => Switch(
              value: payController.isNoPrint.value,
              onChanged: (value) {
                payController.isNoPrint.toggle();
              },
              activeTrackColor: Colors.redAccent,
              activeColor: Colors.red,
            ),
          ),
        ],
      );

  Widget buildCardType(Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        // vertical: screenSize.width * 0.01,
        horizontal: screenSize.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(
            Ionicons.card_outline,
            size: screenSize.width * 0.02,
            color: Palette.darkGrey,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            'Card Type',
            style: TextStyle(
              color: Palette.darkGrey,
              fontSize: screenSize.width * 0.014,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => payController.changeCardType(),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.ccMastercard,
                  size: !payController.isAmex.value
                      ? screenSize.width * 0.025
                      : screenSize.width * 0.02,
                  color: !payController.isAmex.value
                      ? Palette.primaryColor
                      : Palette.darkGrey,
                ),
                SizedBox(width: screenSize.width * 0.005),
                FaIcon(
                  FontAwesomeIcons.ccVisa,
                  size: !payController.isAmex.value
                      ? screenSize.width * 0.025
                      : screenSize.width * 0.02,
                  color: !payController.isAmex.value
                      ? Palette.primaryColor
                      : Palette.darkGrey,
                ),
                SizedBox(width: screenSize.width * 0.005),
                Text(
                  'Card',
                  style: TextStyle(
                    color: !payController.isAmex.value
                        ? Palette.primaryColor
                        : Palette.darkGrey,
                    fontWeight: !payController.isAmex.value
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: !payController.isAmex.value
                        ? screenSize.width * 0.016
                        : screenSize.width * 0.014,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          TextButton.icon(
            onPressed: () => payController.changeCardType(),
            icon: FaIcon(
              FontAwesomeIcons.ccAmex,
              size: payController.isAmex.value
                  ? screenSize.width * 0.025
                  : screenSize.width * 0.02,
              color: payController.isAmex.value
                  ? Palette.primaryColor
                  : Palette.darkGrey,
            ),
            label: Text(
              'Amex',
              style: TextStyle(
                color: payController.isAmex.value
                    ? Palette.primaryColor
                    : Palette.darkGrey,
                fontWeight: payController.isAmex.value
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: payController.isAmex.value
                    ? screenSize.width * 0.016
                    : screenSize.width * 0.014,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildCardOrCash(Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        // vertical: screenSize.width * 0.01,
        horizontal: screenSize.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment_outlined,
            size: screenSize.width * 0.02,
            color: Palette.darkGrey,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            'Payment Type',
            style: TextStyle(
              color: Palette.darkGrey,
              fontSize: screenSize.width * 0.014,
            ),
          ),
          Spacer(),
          TextButton.icon(
            onPressed: () => payController.changePayment(),
            icon: Icon(
              Ionicons.cash_outline,
              size: payController.isCash.value
                  ? screenSize.width * 0.025
                  : screenSize.width * 0.02,
              color: payController.isCash.value
                  ? Palette.primaryColor
                  : Palette.darkGrey,
            ),
            label: Text(
              'Cash',
              style: TextStyle(
                color: payController.isCash.value
                    ? Palette.primaryColor
                    : Palette.darkGrey,
                fontWeight: payController.isCash.value
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: payController.isCash.value
                    ? screenSize.width * 0.016
                    : screenSize.width * 0.014,
              ),
            ),
          ),
          Spacer(),
          TextButton.icon(
            onPressed: () => payController.changePayment(),
            icon: Icon(
              Ionicons.card_outline,
              size: !payController.isCash.value
                  ? screenSize.width * 0.025
                  : screenSize.width * 0.02,
              color: !payController.isCash.value
                  ? Palette.primaryColor
                  : Palette.darkGrey,
            ),
            label: Text(
              'Card',
              style: TextStyle(
                color: !payController.isCash.value
                    ? Palette.primaryColor
                    : Palette.darkGrey,
                fontWeight: !payController.isCash.value
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: !payController.isCash.value
                    ? screenSize.width * 0.016
                    : screenSize.width * 0.014,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildDiscountBar(Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        // vertical: screenSize.width * 0.01,
        horizontal: screenSize.width * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(
            Ionicons.repeat_outline,
            size: screenSize.width * 0.02,
            color: Palette.darkGrey,
          ),
          SizedBox(width: screenSize.width * 0.01),
          Text(
            'Discount',
            style: TextStyle(
              color: Palette.darkGrey,
              fontSize: screenSize.width * 0.014,
            ),
          ),
          Spacer(),
          Obx(
            () => buildAmountButtons(
                text: '10%',
                onPressed: () => Get.defaultDialog(
                    title: 'Enter Authorization PIN',
                    content: DiscountPIN(
                      discountVal: 10.0,
                      selectDiscountStr: '10%',
                    )),
                screenSize: screenSize,
                val: payController.selectedDiscount.toString()),
          ),
          Spacer(),
          buildAmountButtons(
              text: '20%',
              onPressed: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: DiscountPIN(
                    discountVal: 20.0,
                    selectDiscountStr: '20%',
                  )),
              screenSize: screenSize,
              val: payController.selectedDiscount.toString()),
          Spacer(),
          buildAmountButtons(
              text: '50%',
              onPressed: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: DiscountPIN(
                    discountVal: 50.0,
                    selectDiscountStr: '50%',
                  )),
              screenSize: screenSize,
              val: payController.selectedDiscount.toString()),
          Spacer(),
          buildAmountButtons(
              text: '100%',
              onPressed: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: DiscountPIN(
                    discountVal: 100.0,
                    selectDiscountStr: '100%',
                  )),
              screenSize: screenSize,
              val: payController.selectedDiscount.toString()),
          Spacer(),
          // buildAmountButtons(
          //     text: 'Custom',
          //     onPressed: () {
          //       payController.selectedDiscount = RxString('Custom');
          //       Get.defaultDialog(content: DiscountKeypad());
          //     },
          //     screenSize: screenSize,
          //     val: payController.selectedDiscount.toString()),
          // Spacer(),
          buildAmountButtons(
              text: 'X',
              onPressed: () => Get.defaultDialog(
                  title: 'Enter Authorization PIN',
                  content: DiscountPIN(
                    discountVal: 0.0,
                    selectDiscountStr: 'X',
                  )),
              screenSize: screenSize,
              val: payController.selectedDiscount.toString()),
        ],
      ),
    );
  }

  Widget buildCashBar(Size screenSize, {bool isSelected = false}) => Container(
        padding: EdgeInsets.symmetric(
          // vertical: screenSize.width * 0.01,
          horizontal: screenSize.width * 0.01,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Obx(
          () => Row(
            children: [
              Icon(
                Ionicons.cash_outline,
                size: screenSize.width * 0.02,
                color: Palette.darkGrey,
              ),
              SizedBox(width: screenSize.width * 0.01),
              Text(
                'Cash',
                style: TextStyle(
                  color: Palette.darkGrey,
                  fontSize: screenSize.width * 0.014,
                ),
              ),
              Spacer(),
              buildAmountButtons(
                  text: '\$0',
                  onPressed: () {
                    payController.calcAmountToPay(0.0);
                    payController.color.value = '0';
                  },
                  screenSize: screenSize,
                  val: '\$${payController.color.value == '0' ? '0' : 'null'}'),
              Spacer(),
              buildAmountButtons(
                  text: '\$10',
                  onPressed: () {
                    payController.calcAmountToPay(10.0);
                    payController.color.value = '10';
                  },
                  screenSize: screenSize,
                  val:
                      '\$${payController.color.value == '10' ? '10' : 'null'}'),
              Spacer(),
              buildAmountButtons(
                  text: '\$20',
                  onPressed: () {
                    payController.calcAmountToPay(20.0);
                    payController.color.value = '20';
                  },
                  screenSize: screenSize,
                  val:
                      '\$${payController.color.value == '20' ? '20' : 'null'}'),
              Spacer(),
              buildAmountButtons(
                  text: '\$50',
                  onPressed: () {
                    payController.calcAmountToPay(50.0);
                    payController.color.value = '50';
                  },
                  screenSize: screenSize,
                  val:
                      '\$${payController.color.value == '50' ? '50' : 'null'}'),
              Spacer(),
              buildAmountButtons(
                  text: '\$100',
                  onPressed: () {
                    payController.calcAmountToPay(100.0);
                    payController.color.value = '100';
                  },
                  screenSize: screenSize,
                  val:
                      '\$${payController.color.value == '100' ? '100' : 'null'}'),
              Spacer(),
              buildAmountButtons(
                  text: 'Custom',
                  onPressed: () {
                    payController.color.value = 'Custom';
                    Get.defaultDialog(
                        title: 'Custom Amount', content: CashKeypad());
                  },
                  screenSize: screenSize,
                  val:
                      '${payController.color.value == 'Custom' ? 'Custom' : 'null'}'),
            ],
          ),
        ),
      );

  Widget buildAmountButtons(
          {String text, Function onPressed, Size screenSize, String val}) =>
      TextButton(
        onPressed: onPressed,
        child: Text(
          '$text',
          style: TextStyle(
              color: text == val ? Palette.primaryColor : Palette.mediumGrey,
              fontSize: screenSize.width * 0.014),
        ),
      );

  Widget buildAmount(Size screenSize, PayController payController) => Expanded(
        flex: 2,
        child: Container(
          margin: EdgeInsets.only(right: screenSize.width * 0.05),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildAmountTextLeft(
                          screenSize,
                          'Amount To Pay',
                          payController.amountToPay.toStringAsFixed(2),
                          0.016,
                          0.022,
                          CrossAxisAlignment.start),
                      SizedBox(height: screenSize.height * 0.02),
                      buildAmountTextLeft(
                          screenSize,
                          'Paid',
                          payController.paid.toStringAsFixed(2),
                          0.016,
                          0.022,
                          CrossAxisAlignment.start),
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      SizedBox(height: screenSize.height * 0.02),
                      buildAmountTextLeft(
                          screenSize,
                          'Balance',
                          payController.balance.toStringAsFixed(2),
                          0.016,
                          0.055,
                          CrossAxisAlignment.end),
                    ],
                  ),
                ],
              ),
              Divider(thickness: 1.5),
            ],
          ),
        ),
      );

  Widget buildAmountTextLeft(
          Size screenSize,
          String titleText,
          String value,
          double titleTextSize,
          double valueTextSize,
          CrossAxisAlignment textAlignment) =>
      Column(
        crossAxisAlignment: textAlignment,
        children: [
          Text(
            titleText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * titleTextSize,
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            '\$' + value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * valueTextSize,
              color: Palette.primaryColor,
            ),
          ),
        ],
      );

  Widget buildHeader(Size screenSize) => Expanded(
        flex: 2,
        child: Container(
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => Get.offAll(() => Dashboard()),
                icon: Icon(
                  Ionicons.arrow_back_circle_outline,
                  size: screenSize.width * 0.025,
                  color: Palette.black,
                ),
                label: Text(
                  'Back to menu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.014,
                    color: Palette.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
