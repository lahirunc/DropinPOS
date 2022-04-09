class MenuModel {
  final String id;
  var data;
  final Map main, addons, drinks;
  final int addonLimit, drinksLimit;

  MenuModel(this.id, this.data, this.main, this.addons, this.drinks,
      this.addonLimit, this.drinksLimit);
}
