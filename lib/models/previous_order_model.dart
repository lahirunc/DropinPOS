import 'package:cloud_firestore/cloud_firestore.dart';

class PreviousOrderModel {
  String id,
      cusName,
      mobile,
      date,
      dateISO,
      paymentType,
      server,
      serverId,
      tableName;
  double paidAmount, discount, gst, surcharge, total, subTotal;
  List<String> attributeNameList, itemList, noteList;
  List<int> qty, attribParentIndexList;
  List<double> priceList, attribPriceList;
  List<bool> isVoid;

  PreviousOrderModel(
    this.id,
    this.cusName,
    this.mobile,
    this.date,
    this.dateISO,
    this.paymentType,
    this.server,
    this.serverId,
    this.tableName,
    this.paidAmount,
    this.discount,
    this.gst,
    this.surcharge,
    this.attributeNameList,
    this.itemList,
    this.noteList,
    this.qty,
    this.attribParentIndexList,
    this.priceList,
    this.attribPriceList,
    this.isVoid,
    this.total,
    this.subTotal,
  );

  PreviousOrderModel.fromMap(DocumentSnapshot data) {
    try {
      id = data.id;
      cusName = data['customerName'] ?? '';
      mobile = data['customerNumber'] ?? '';
      date = data['date'] ?? '';
      dateISO = data['dateTimeStampISO'] ?? '';
      paymentType = data['paymentType'] ?? '';
      serverId = data['serverId'] ?? '';
      server = data['server'] ?? '';
      tableName = data['tableName'] ?? '';
      paidAmount = double.parse(data['AmountPaid'].toString()) ?? 0.0;
      discount = double.parse(data['discount'].toString()) ?? 0.0;
      gst = double.parse(data['gstAmt'].toString()) ?? 0.0;
      surcharge = double.parse(data['surcharge'].toString()) != null
          ? double.parse(data['surcharge'].toString())
          : 0.0;
      qty = List.from(data['qty']);
      isVoid = List.from(data['void']);
      noteList = List.from(data['notes']);
      attribParentIndexList = List.from(data['attribParentIndex']);
      attributeNameList = List.from(data['attribNames']);
      itemList = List.from(data['itemname']);

      attribPriceList = [];
      priceList = [];

      for (var attribPrice in data['attribPrice']) {
        attribPriceList.add(double.parse(attribPrice.toString()));
      }

      for (var itemPrice in data['productPriceList']) {
        priceList.add(double.parse(itemPrice.toString()));
      }

      double _total = 0;

      for (var i = 0; i < priceList.length; i++) {
        _total += priceList[i] * qty[i];

        for (var j = 0; j < attribParentIndexList.length; j++) {
          if (attribParentIndexList[j] == i) {
            _total += attribPriceList[j] * qty[i];
          }
        }
      }
      subTotal = _total;
      _total += gst + surcharge;
      discount = (_total * discount / 100);
      _total = _total - discount;
      total = _total;
    } catch (e) {
      print(data.id.toString() + ':' + e.toString());
    }
  }
}
