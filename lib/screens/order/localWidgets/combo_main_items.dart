import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'icon_button_with_text.dart';

class ComboMainItems extends StatelessWidget {
  const ComboMainItems({
    Key key,
    @required this.screenSize,
    @required this.data,
    @required this.title,
    this.onPressFunction,
    this.selectVar,
  }) : super(key: key);

  final String title;
  final Size screenSize;
  final data, onPressFunction, selectVar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(screenSize.height * 0.01),
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.018,
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height * 0.1,
          width: screenSize.width * 0.6,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => IconButtonWithText(
                        onPressed: () => onPressFunction(
                            data.keys.toList()[index], selectVar),
                        selectedVal: selectVar.value,
                        screenSize: screenSize,
                        title: data.keys.toList()[index],
                        icon: Icons.fastfood_outlined,
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.01)
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(height: screenSize.width * 0.01),
      ],
    );
  }
}
