import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class IconLastButton extends StatefulWidget {
  final Function onTap;
  final Size screenSize;
  final Color color;
  final String text;
  final double borderRadius;
  final IconData icon;
  final Color iconColor;

  const IconLastButton({
    Key key,
    @required this.onTap,
    @required this.screenSize,
    @required this.color,
    @required this.text,
    @required this.borderRadius,
    @required this.icon,
    @required this.iconColor,
  }) : super(key: key);
  @override
  _IconLastButtonState createState() => _IconLastButtonState();
}

class _IconLastButtonState extends State<IconLastButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        height: widget.screenSize.height * 0.055,
        width: widget.screenSize.width * 0.13,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(widget.screenSize.width * 0.012),
              child: Row(
                children: [
                  Spacer(),
                  Text(
                    widget.text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: widget.screenSize.width * 0.014,
                      color: Palette.white,
                    ),
                  ),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Spacer(),
                  Icon(
                    widget.icon,
                    color: widget.iconColor,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
