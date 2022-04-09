import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class LegendBar extends StatelessWidget {
  const LegendBar({
    Key key,
    @required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.only(left: screenSize.width * 0.02),
          child: Row(
            children: [
              buildColoredCircleAndText(
                  screenSize, Palette.primaryColor, 'Preparing'),
              SizedBox(width: screenSize.width * 0.05),
              buildColoredCircleAndText(screenSize, Colors.green, 'Waiting'),
            ],
          ),
        ));
  }

  Row buildColoredCircleAndText(Size screenSize, Color color, String textStr) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: screenSize.width * 0.01,
        ),
        SizedBox(
          width: screenSize.width * 0.008,
        ),
        Text(
          textStr,
          style: TextStyle(fontSize: screenSize.width * 0.018),
        ),
      ],
    );
  }
}
