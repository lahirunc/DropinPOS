import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:dropin_pos_v2/screens/settings/localWidgets/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Orders extends StatelessWidget {
  const Orders({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      initState: (_) {},
      builder: (_) {
        // _.prevOrderList.bindStream(_.getPeviousOrders());
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Palette.black,
              title: Header(
                screenSize: screenSize,
                title: 'Previous Orders',
              ),
            ),
            body: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Order Type: ',
                          style: TextStyle(
                              fontSize: screenSize.width * 0.016,
                              color: Palette.mediumGrey),
                        ),
                        Text(
                          'Date: ',
                          style: TextStyle(
                              fontSize: screenSize.width * 0.016,
                              color: Palette.mediumGrey),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: Obx(
                        () => GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: screenSize.width * 0.2,
                            // mainAxisExtent: screenSize.height * 0.28,
                            crossAxisSpacing: screenSize.width * 0.01,
                            mainAxisSpacing: screenSize.height * 0.02,
                          ),
                          itemCount: _.prevOrderList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => print(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Palette.lightGrey,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Order: ${_.prevOrderList[index].id}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.016,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenSize.height * 0.02),
                                      Text(
                                        'Date: ${_.prevOrderList[index].date}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.016,
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenSize.height * 0.02),
                                      Text(
                                        'Total: \$999.00',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.016,
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenSize.height * 0.02),
                                      Text(
                                        'Payment: ${_.prevOrderList[index].paymentType}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.016,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
