import 'package:dropin_pos_v2/config/palette.dart';
import 'package:flutter/material.dart';

class PrinterList extends StatelessWidget {
  const PrinterList({
    Key key,
    @required this.screenSize,
    @required this.printerName,
    @required this.itemCount,
    @required this.printerList,
    @required this.onDeleteFunc,
  }) : super(key: key);

  final Size screenSize;
  final int itemCount;
  final List printerList;
  final String printerName;
  final onDeleteFunc;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: EdgeInsets.only(
          left: screenSize.width * 0.1,
          right: screenSize.width * 0.1,
          bottom: screenSize.width * 0.01,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Palette.blueGrey,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(screenSize.height * 0.05),
                child: SizedBox(
                  width: double.infinity,
                  height: screenSize.height * .46,
                  child: ListView.builder(
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.account_tree_outlined),
                          title: Row(
                            children: [
                              Text(
                                printerList[index],
                                style: TextStyle(),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => onDeleteFunc(index.toString(),
                                printerName, printerList, false),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
