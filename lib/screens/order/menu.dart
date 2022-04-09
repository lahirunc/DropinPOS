import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/authController.dart';
import 'package:dropin_pos_v2/controllers/orderController.dart';
import 'package:dropin_pos_v2/models/cartModel.dart';
import 'package:dropin_pos_v2/widgets/loader.dart';
import 'localWidgets/combo_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Menu extends StatelessWidget {
  const Menu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String _selectedCat = "All Items";

    // final globalController = Get.put(GlobalController());
    final authController = Get.find<AuthController>();

    TextEditingController _searchController = TextEditingController();

    Stream<dynamic> getCategories() {
      return FirebaseFirestore.instance
          .collection(authController.shopName.toString())
          .doc('categories')
          .collection('category')
          .orderBy('catOrder')
          .snapshots();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          return Container(
            child: Column(
              children: [
                SizedBox(height: screenSize.height * 0.01),
                // cats
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: StreamBuilder(
                        stream: getCategories(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Loader(),
                            );
                          }

                          orderController.catList.clear();
                          orderController.catList.add('All Items');

                          for (var i = 0; i < snapshot.data.docs.length; i++) {
                            orderController.catList
                                .add(snapshot.data.docs[i]['category']);
                          }
                          orderController.update();

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: orderController.catList.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      orderController.changePressedIndex(index);
                                      orderController.getMenu(
                                          _searchController.text.trim(),
                                          _selectedCat);
                                      _selectedCat = orderController.catList[
                                          int.parse(orderController.pressedIndex
                                                  .toString()) ??
                                              0];
                                    },
                                    child: Obx(
                                      () => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenSize.width * 0.02,
                                          vertical: screenSize.height * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          color: index ==
                                                      int.parse(orderController
                                                          .pressedIndex
                                                          .toString()) ??
                                                  0
                                              ? Palette.primaryColor
                                              : Palette.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[400],
                                              blurRadius: 2.0,
                                              spreadRadius: 0.0,
                                              offset: Offset(2.0,
                                                  2.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Obx(() => Text(
                                                  orderController
                                                      .catList[index],
                                                  style: TextStyle(
                                                    fontSize: screenSize.width *
                                                        0.016,
                                                    color: index ==
                                                                int.parse(orderController
                                                                    .pressedIndex
                                                                    .toString()) ??
                                                            0
                                                        ? Palette.white
                                                        : Palette.black,
                                                    fontWeight: index ==
                                                                int.parse(orderController
                                                                    .pressedIndex
                                                                    .toString()) ??
                                                            0
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                // search
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: EdgeInsets.only(
                      left: screenSize.width * 0.012,
                      right: screenSize.width * 0.012,
                      bottom: screenSize.width * 0.024,
                    ),
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (val) {
                        orderController.getMenu(
                            _searchController.text, _selectedCat);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search",
                      ),
                    ),
                  ),
                ),
                // Menu
                Expanded(
                  flex: 10,
                  child: Container(
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: orderController.filteredDocs.length,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: screenSize.height * 0.01,
                        crossAxisSpacing: screenSize.width * 0.01,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        bool _isAvailable = orderController.filteredDocs[index]
                                    .data['isAvailablity'] ==
                                null
                            ? false
                            : orderController
                                .filteredDocs[index].data['isAvailablity'];
                        return InkWell(
                          onLongPress: () => orderController.setItemAvalibility(
                              orderController.filteredDocs[index].id,
                              _isAvailable),
                          onTap: () {
                            if (_isAvailable) {
                              List<String> _attribNames = [];
                              List<double> _attribPrice = [];

                              var _cartList = CartModel(
                                1,
                                double.parse(orderController
                                    .filteredDocs[index].data['price']
                                    .toString()),
                                orderController
                                    .filteredDocs[index].data['name'],
                                '',
                                _attribNames,
                                _attribPrice,
                                false,
                                false,
                                orderController.filteredDocs[index].data['cat']
                                    .toString()
                                    .toLowerCase()
                                    .contains('pizza'),
                                orderController.filteredDocs[index].data['cat']
                                    .toString()
                                    .toLowerCase()
                                    .contains('combo'),
                                orderController.filteredDocs[index]
                                            .data['printer'] ==
                                        null
                                    ? 2
                                    : int.parse(orderController
                                        .filteredDocs[index].data['printer']
                                        .toString()),
                              );

                              if (orderController
                                  .filteredDocs[index].data['cat']
                                  .toString()
                                  .toLowerCase()
                                  .contains('combo')) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext contex) {
                                      return ComboDialog(
                                        controller: orderController,
                                        itemIndex: index,
                                        screenSize: screenSize,
                                      );
                                    });
                              }

                              orderController.addToCart(_cartList);
                            } else {
                              Get.snackbar(
                                'Item not Available',
                                'Enable the item by long press if the item is avaialble!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Palette.primaryColor,
                                colorText: Palette.white,
                              );
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      color: Colors.red,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: !_isAvailable
                                          ? Center(
                                              child: Text(
                                              'N/A',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      screenSize.width * 0.03),
                                            ))
                                          : CachedNetworkImage(
                                              memCacheHeight: 1500,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              imageUrl: orderController
                                                  .filteredDocs[index]
                                                  .data['imgUrl']
                                                  .toString(),
                                              placeholder: (context, url) =>
                                                  Loader(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      FittedBox(
                                                fit: BoxFit.cover,
                                                child: Image.asset(
                                                    'assets/images/placeholderFood.png'),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      orderController
                                          .filteredDocs[index].data['name'],
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
