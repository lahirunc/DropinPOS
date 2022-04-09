import 'package:dropin_pos_v2/config/palette.dart';
import 'package:dropin_pos_v2/controllers/settingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'localWidgets/printer_form.dart';
import 'localWidgets/header.dart';
import 'localWidgets/printer_list.dart';

class Printer extends StatelessWidget {
  const Printer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    TabController _tabController;

    const List<Tab> _tabs = <Tab>[
      Tab(
        icon: Icon(Icons.print_outlined),
        text: 'Front',
      ),
      Tab(
        icon: Icon(Icons.print_outlined),
        text: 'KOT 1',
      ),
      Tab(
        icon: Icon(Icons.print_outlined),
        text: 'KOT 2',
      ),
      Tab(
        icon: Icon(Icons.print_outlined),
        text: 'KOT 3',
      ),
    ];

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      initState: (_) {},
      builder: (_) {
        _.getPrinterList();
        return DefaultTabController(
          length: _tabs.length,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              bottom: const TabBar(
                indicatorColor: Palette.secondaryColor,
                tabs: _tabs,
              ),
              backgroundColor: Palette.black,
              title: Header(
                screenSize: screenSize,
                title: 'Printer Management',
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                PrinterBody(
                  screenSize: screenSize,
                  controller: _,
                  itemCount: _.posList.length,
                  printerList: _.posList,
                  printerName: 'posPrinter',
                ),
                PrinterBody(
                  screenSize: screenSize,
                  controller: _,
                  itemCount: _.kot1List.length,
                  printerList: _.kot1List,
                  printerName: 'kotPrinter',
                ),
                PrinterBody(
                  screenSize: screenSize,
                  controller: _,
                  itemCount: _.kot2List.length,
                  printerList: _.kot2List,
                  printerName: 'kot2Printer',
                ),
                PrinterBody(
                  screenSize: screenSize,
                  controller: _,
                  itemCount: _.kot3List.length,
                  printerList: _.kot3List,
                  printerName: 'kot3Printer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PrinterBody extends StatelessWidget {
  const PrinterBody({
    Key key,
    @required this.screenSize,
    @required this.controller,
    @required this.printerName,
    @required this.itemCount,
    @required this.printerList,
  }) : super(key: key);

  final Size screenSize;
  final SettingsController controller;
  final String printerName;
  final int itemCount;
  final List printerList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // printer form
        PrinterForm(
          screenSize: screenSize,
          controller: controller,
          printerName: printerName,
          printerList: printerList,
        ),
        // Printer List
        PrinterList(
          screenSize: screenSize,
          itemCount: itemCount,
          printerList: printerList,
          printerName: printerName,
          onDeleteFunc: controller.updatePrinterIPs,
        ),
      ],
    );
  }
}
