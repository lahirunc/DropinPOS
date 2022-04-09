import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ionicons/ionicons.dart';

class Header extends StatelessWidget {
  const Header({
    Key key,
    @required this.screenSize,
    @required this.title,
  }) : super(key: key);

  final Size screenSize;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Ionicons.arrow_back_circle_outline,
              size: screenSize.width * 0.03,
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: screenSize.width * 0.028,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
