class OnlineOrderModel {
  final String orderId, time, address, date, name, mobile,docID;
  bool isVisible, isDelivery;

  OnlineOrderModel(this.orderId, this.time, this.isDelivery, this.address, this.date, this.name, this.mobile,this.docID,
      {this.isVisible});
}
