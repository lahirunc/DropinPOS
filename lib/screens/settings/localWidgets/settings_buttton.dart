import 'package:flutter/material.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({
    Key key,
    @required this.screenSize,
    this.title,
    this.onTap,
    this.icon,
  }) : super(key: key);

  final Size screenSize;
  final String title;
  final Function onTap;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.016,
            ),
          ),
        ],
      ),
    );
  }
}
