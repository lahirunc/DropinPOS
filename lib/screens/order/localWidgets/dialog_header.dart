import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    Key key,
    @required this.onSave,
    @required this.onCancel,
    @required this.title,
    this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  final VoidCallback onSave, onCancel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  title,
                ),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  primary: Palette.primaryColor,
                ),
                onPressed: onSave,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.005),
              TextButton(
                onPressed: onCancel,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Palette.darkGrey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(thickness: 2, color: Palette.black)
        ],
      ),
    );
  }
}
