class Ingredient {
  String name;
  double quantity;
  String unit;

  Ingredient({required this.name, required this.quantity, required this.unit});
}

class Recipe {
  String name;
  List<Ingredient> ingredients;

  Recipe({required this.name, required this.ingredients});
}
