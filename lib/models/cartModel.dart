class CartModel {
  int qty;
  double price;
  final String name;
  String notes;
  List<String> attribNameList;
  List<double> attribPriceList;
  bool isRead;
  bool isVoid;
  bool isPizza;
  bool isCombo;
  int printer;

  CartModel(
    this.qty,
    this.price,
    this.name,
    this.notes,
    this.attribNameList,
    this.attribPriceList,
    this.isRead,
    this.isVoid,
    this.isPizza,
    this.isCombo,
    this.printer,
  );
}
