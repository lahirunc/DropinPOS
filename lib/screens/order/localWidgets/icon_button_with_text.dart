import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class IconButtonWithText extends StatelessWidget {
  final screenSize, title, icon, onPressed;
  final selectedVal;

  IconButtonWithText(
      {Key key,
      @required this.screenSize,
      @required this.title,
      @required this.icon,
      @required this.selectedVal,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        label: Text(title,
            style: TextStyle(
                color: selectedVal == title ? Palette.white : Palette.black,
                fontSize: 16)));
  }
}
