import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/globalController.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:dropin_pos_v2/models/previous_order_model.dart';
import 'package:flutter/material.dart';

class PrinterForm extends StatefulWidget {
  const PrinterForm({
    Key key,
    @required this.screenSize,
    @required this.controller,
    @required this.printerName,
    @required this.printerList,
  }) : super(key: key);

  final Size screenSize;
  final SettingsController controller;
  final String printerName;
  final List printerList;

  @override
  State<PrinterForm> createState() => _PrinterFormState();
}

class _PrinterFormState extends State<PrinterForm> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Spacer(),
          // TextField
          SizedBox(
            width: widget.screenSize.width * 0.3,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter IP address',
                helperText: 'Eg: 192.168.1.1',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Palette.primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Palette.primaryColor),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Palette.primaryColor),
                ),
                prefixIcon: const Icon(
                  Icons.account_tree_outlined,
                  color: Palette.primaryColor,
                ),
              ),
              controller: _textController,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(widget.screenSize.width * 0.02),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Palette.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: widget.screenSize.height * 0.015,
                  horizontal: widget.screenSize.width * 0.025,
                ),
              ),
              onPressed: () {
                widget.controller.updatePrinterIPs(_textController.text.trim(),
                    widget.printerName, widget.printerList, true);

                _textController.clear();
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: widget.screenSize.width * 0.014,
                ),
              ),
            ),
          ),
          Spacer(),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(widget.screenSize.width * 0.02),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Palette.darkGrey,
                padding: EdgeInsets.symmetric(
                  vertical: widget.screenSize.height * 0.015,
                  horizontal: widget.screenSize.width * 0.05,
                ),
              ),
              onPressed: () => widget.controller.printTicket(
                widget.printerList,
                widget.printerName == 'posPrinter',
                0,
                <PreviousOrderModel>[
                  PreviousOrderModel(
                      '9999999',
                      'Dropin Customer',
                      '042123456',
                      GlobalController().currDateTimeSlashed,
                      '',
                      'Cash',
                      'Dropin',
                      'Dropin',
                      'Test Print',
                      999.99,
                      999.99,
                      999.99,
                      999.99,
                      ['Extra 1', 'Extra 2'],
                      ['Test Item'],
                      ['Test Note'],
                      [1],
                      [0],
                      [999.99],
                      [99.99, 99.99],
                      [false],
                      999.99,
                      999.99)
                ],
              ),
              child: Text(
                'Test',
                style: TextStyle(
                  fontSize: widget.screenSize.width * 0.014,
                ),
              ),
            ),
          ),
          Spacer(),
          Spacer(),
        ],
      ),
    );
  }
}
