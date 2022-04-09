
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class ItemListText extends StatelessWidget {
  const ItemListText({
    Key key,
    @required this.screenSize,
    @required this.item,
    @required this.price,
    @required this.isVisible,
    @required this.attributeList,
    this.itemTextSize = 0.018,
    this.priceTextSize = 0.018,
    this.isItemTextBold = true,
    this.isPriceTextBold = true,
  }) : super(key: key);

  final bool isVisible, isItemTextBold, isPriceTextBold;
  final double itemTextSize, priceTextSize;
  final Size screenSize;
  final String item, price;
  final List<String> attributeList;

  @override
  Widget build(BuildContext contex) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item,
              style: TextStyle(
                  color: Palette.black,
                  fontSize: screenSize.width * itemTextSize,
                  fontWeight:
                      isItemTextBold ? FontWeight.bold : FontWeight.normal),
            ),
            Visibility(
              visible: isVisible,
              child: Text(
                ' - ' + attributeList.join('\n - ').toString(),
                style: TextStyle(
                    color: Palette.black, fontSize: screenSize.width * 0.016),
              ),
            ),
          ],
        ),
        Spacer(),
        Text(
          '\$$price',
          style: TextStyle(
              color: Palette.black,
              fontSize: screenSize.width * priceTextSize,
              fontWeight:
                  isPriceTextBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
