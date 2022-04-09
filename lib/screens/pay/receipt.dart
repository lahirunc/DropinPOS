import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/payController.dart';
import 'package:flutter/material.dart';

class Receipt extends StatelessWidget {
  final orderId;
  final tableName;
  final date;
  final payController;

  const Receipt({
    Key key,
    @required this.orderId,
    @required this.tableName,
    @required this.date,
    @required this.payController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // payController.calcAmountToPay(0.0);
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.03,
        horizontal: screenSize.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: Palette.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          buildHeader(screenSize, orderId),
          buildBody(screenSize, payController),
          buildFooter(screenSize, payController),
        ],
      ),
    );
  }

  Widget buildBody(Size screenSize, PayController payController) => Expanded(
        flex: 6,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
          child: ListView.builder(
            itemCount: payController.receiptList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            payController.receiptList[index].name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width * 0.016,
                            ),
                          ),
                          Text(
                            ' x${payController.receiptList[index].qty}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenSize.width * 0.016,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        '\$${payController.getItemTotal(index).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.width * 0.016,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      payController.receiptList[index].notes.toString() != ''
                          ? Text(
                              'Notes: ${payController.receiptList[index].notes}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Palette.darkGrey),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      payController.receiptList[index].attribNameList.length > 0
                          ? Expanded(
                              flex: 2,
                              child: Text(
                                '\t- ${payController.receiptList[index].attribNameList.join('\n\t- ').toString()}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: TextStyle(color: Palette.darkGrey),
                              ),
                            )
                          : SizedBox.shrink(),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                ],
              );
            },
          ),
        ),
      );

  Widget buildFooter(Size screenSize, PayController payController) => Expanded(
        flex: 2,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.015,
            vertical: screenSize.width * 0.01,
          ),
          child: Column(
            children: [
              SizedBox(
                width: screenSize.width * 0.4,
                child: Divider(thickness: 1.5),
              ),
              SizedBox(height: screenSize.height * 0.01),
              buildFooterText(screenSize, 'Sub Total',
                  payController.totalPrice.toStringAsFixed(2)),
              SizedBox(height: screenSize.height * 0.01),
              buildFooterText(
                  screenSize, 'G.S.T', payController.gstAmt.toStringAsFixed(2)),
              SizedBox(height: screenSize.height * 0.01),
              buildFooterText(screenSize, 'Discount',
                  payController.discountAmt.toStringAsFixed(2)),
              SizedBox(height: screenSize.height * 0.01),
              buildFooterText(screenSize, 'Surcharge',
                  payController.surchargeAmt.toStringAsFixed(2)),
            ],
          ),
        ),
      );

  Widget buildFooterText(Size screenSize, String footerText, String value) =>
      Row(
        children: [
          Text(
            footerText,
            style: TextStyle(
              fontSize: screenSize.width * 0.016,
              color: Palette.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            '\$$value',
            style: TextStyle(
              fontSize: screenSize.width * 0.016,
              color: Palette.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget buildHeader(Size screenSize, String orderId) => Expanded(
        flex: 1,
        child: Column(
          children: [
            SizedBox(height: screenSize.height * .02),
            Center(
              child: Text(
                'Table $tableName | $orderId',
                style: TextStyle(
                  color: Palette.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: screenSize.width * 0.018,
                ),
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.03,
              width: screenSize.width * 0.4,
              child: Divider(thickness: 1.5),
            ),
          ],
        ),
      );
}
