import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/widgets/keypad/keyPad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClosingTill extends StatefulWidget {
  const ClosingTill({Key key}) : super(key: key);

  @override
  _ClosingTillState createState() => _ClosingTillState();
}

class _ClosingTillState extends State<ClosingTill> {
  TextEditingController actualController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return GetBuilder<AuthController>(builder: (authController) {
      // authController.isRead = false;
      authController.getSales(authController.recorededDateTimeISO);
      // actualController.text = '0';
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenSize.height * 0.02),
              Expanded(
                child: Text('Closing Cash Register',
                    style: TextStyle(
                        fontSize: screenSize.width * 0.034,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenSize.height * 0.05),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: screenSize.width * 0.02),
                              child: LeftTextValue(
                                screenSize: screenSize,
                                title: 'Recorded cash',
                                value: authController.initTillAmount
                                    .toStringAsFixed(2),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            ActualCash(
                                authController: authController,
                                screenSize: screenSize,
                                actualController: actualController)
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenSize.height * 0.04),
                            Text(
                              'Difference',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenSize.width * 0.02,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '\$' +
                                    authController.tillDiff.toStringAsFixed(2),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenSize.width * 0.06,
                                  color: Palette.primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: screenSize.width * 0.05,
                                horizontal: screenSize.height * 0.02,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey[300]),
                                color: Colors.grey[100],
                              ),
                              child: TextFormField(
                                maxLines: 6,
                                controller: reasonController,
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
                                  hintText: 'Enter reason for the difference',
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.04),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Palette.secondaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width * 0.05,
                                    vertical: screenSize.height * 0.02,
                                  ),
                                ),
                                onPressed: () {
                                  DateTime now = DateTime.now();
                                  DateFormat formatter =
                                      DateFormat('yyyy-MM-dd');
                                  String formatted =
                                      DateTime.parse(formatter.format(now))
                                          .toIso8601String();

                                  authController.printReport(
                                      formatted,
                                      'Y Report',
                                      reasonController.text.trim(),
                                      actualController.text.trim());

                                  // authController.isRead = false;
                                  // authController.getSales(formatted);
                                },
                                child: Text(
                                  'Print Y Report',
                                  style: TextStyle(
                                      fontSize: screenSize.width * 0.018),
                                ),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.04),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Palette.mediumGrey,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenSize.width * 0.05,
                                      vertical: screenSize.height * 0.02,
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: const Text('Back'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenSize.width * 0.08,
                                      vertical: screenSize.height * 0.02,
                                    ),
                                  ),
                                  onPressed: () => authController.storeClosing(
                                      actualController.text.trim(),
                                      reasonController.text.trim()),
                                  child: Text(
                                    'Clock Off',
                                    style: TextStyle(
                                        fontSize: screenSize.width * 0.018),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ActualCash extends StatelessWidget {
  const ActualCash({
    Key key,
    @required this.screenSize,
    @required this.actualController,
    @required this.authController,
  }) : super(key: key);

  final authController;
  final Size screenSize;
  final TextEditingController actualController;

  @override
  Widget build(BuildContext context) {
    // actualController.text = '0';
    // authController.calcTillDiff(0.00);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenSize.width * 0.02),
            child: Text(
              'Actual cash in register',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.02,
              ),
            ),
          ),
          Container(
            // margin: EdgeInsets.symmetric(
            //     horizontal: screenSize.width * 0.00),
            child: Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.01),
              child: TextFormField(
                // initialValue: 0,
                controller: actualController,
                obscureText: false,
                readOnly: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                  // letterSpacing: screenSize.width * 0.010,
                  color: Palette.primaryColor,
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.attach_money,
                    size: screenSize.width * 0.05,
                    color: Palette.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: KeyPad(
              pinController: actualController,
              onChange: (String pin) {
                if (actualController.text != '') {
                  authController
                      .calcTillDiff(double.parse(actualController.text.trim()));
                } else {
                  authController.calcTillDiff(0.0);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class LeftTextValue extends StatelessWidget {
  LeftTextValue({
    Key key,
    @required this.screenSize,
    @required this.title,
    @required this.value,
  }) : super(key: key);

  final Size screenSize;
  final String title;
  String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.02,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        Text(
          '\$' + value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.06,
            color: Palette.primaryColor,
          ),
        ),
      ],
    );
  }
}
