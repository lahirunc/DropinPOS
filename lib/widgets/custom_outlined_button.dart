import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    Key key,
    @required this.screenSize,
    @required this.onPressed,
    @required this.title,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final Size screenSize;
  final VoidCallback onPressed;
  final String title;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: width,
          vertical: height,
        ),
      ),
      child: Text(
        title,
        style:
            TextStyle(color: Palette.black, fontSize: screenSize.width * 0.016),
      ),
    );
  }
}
