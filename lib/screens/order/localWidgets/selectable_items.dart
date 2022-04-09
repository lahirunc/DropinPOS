import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SelectableItems extends StatelessWidget {
  const SelectableItems({
    Key key,
    @required this.screenSize,
    @required this.title,
    @required this.data,
    @required this.onPressFunction,
    @required this.selectedArray,
    @required this.limit,
  }) : super(key: key);

  final Size screenSize;
  final String title;
  final Map data;
  final int limit;
  final onPressFunction, selectedArray;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            screenSize.height * 0.01,
            screenSize.height * 0.01,
            0,
            screenSize.height * 0.02,
          ),
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.018,
            ),
          ),
        ),
        Container(
          height: screenSize.height * ((data.length / 5) * 0.18),
          width: screenSize.width * 0.6,
          child: Center(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: screenSize.width * 0.12,
                  crossAxisSpacing: screenSize.width * 0.01,
                  mainAxisSpacing: 20),
              itemCount: data.length,
              itemBuilder: (BuildContext ctx, index) {
                String _value = data.values.toList()[index] != 0
                    ? '\n\$' + data.values.toList()[index].toStringAsFixed(2)
                    : '';

                return Obx(() => ElevatedButton(
                      onPressed: () => onPressFunction(
                          data.keys.toList()[index], selectedArray, limit),
                      style: ElevatedButton.styleFrom(
                          primary: selectedArray
                                  .where((element) =>
                                      element == data.keys.toList()[index])
                                  .isNotEmpty
                              ? Palette.primaryColor
                              : Palette.white,
                          elevation: 0,
                          side: BorderSide(
                            color: selectedArray
                                    .where((element) =>
                                        element == data.keys.toList()[index])
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
                          '${data.keys.toList()[index]}$_value',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selectedArray
                                    .where((element) =>
                                        element == data.keys.toList()[index])
                                    .isNotEmpty
                                ? Palette.white
                                : Palette.black,
                            fontSize: data.keys.toList()[index].length < 8
                                ? screenSize.width * 0.016
                                : screenSize.width * 0.015,
                          ),
                        ),
                      ),
                    ));
              },
            ),
          ),
        ),
        SizedBox(height: screenSize.width * 0.01),
      ],
    );
  }
}
