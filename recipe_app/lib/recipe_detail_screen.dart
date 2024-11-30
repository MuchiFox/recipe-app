import 'package:flutter/material.dart';
import 'database_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _ingredientUnitControllers = [];

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    for (var controller in _ingredientNameControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientQuantityControllers) {
      controller.dispose();
    }
    for (var controller in _ingredientUnitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRecipeDetails() async {
    final dbHelper = DatabaseHelper.instance;

    // 从数据库加载食谱数据
    Map<String, dynamic> recipe = await dbHelper.getRecipeById(widget.recipeId);
    List<Map<String, dynamic>> ingredients = await dbHelper.getIngredientsByRecipeId(widget.recipeId);

    setState(() {
      _recipeNameController.text = recipe['name'];
      for (var ingredient in ingredients) {
        _ingredientNameControllers.add(TextEditingController(text: ingredient['name']));
        _ingredientQuantityControllers.add(TextEditingController(text: ingredient['quantity'].toString()));
        _ingredientUnitControllers.add(TextEditingController(text: ingredient['unit']));
      }
    });
  }

  List<Map<String, dynamic>> _collectIngredients() {
    List<Map<String, dynamic>> ingredients = [];
    for (int i = 0; i < _ingredientNameControllers.length; i++) {
      ingredients.add({
        'name': _ingredientNameControllers[i].text,
        'quantity': double.tryParse(_ingredientQuantityControllers[i].text) ?? 0.0,
        'unit': _ingredientUnitControllers[i].text,
      });
    }
    return ingredients;
  }

  Future<void> _updateRecipe() async {
    final dbHelper = DatabaseHelper.instance;

    String recipeName = _recipeNameController.text;
    List<Map<String, dynamic>> ingredients = _collectIngredients();

    await dbHelper.updateRecipe(widget.recipeId, recipeName, ingredients);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe updated successfully!')),
    );
    Navigator.pop(context);
  }

  Future<void> _deleteRecipe() async {
    final dbHelper = DatabaseHelper.instance;

    await dbHelper.deleteRecipe(widget.recipeId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recipe deleted successfully!')),
    );
    Navigator.pop(context);
  }

  void _addIngredientField() {
    setState(() {
      _ingredientNameControllers.add(TextEditingController());
      _ingredientQuantityControllers.add(TextEditingController());
      _ingredientUnitControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteRecipe,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _recipeNameController,
              decoration: InputDecoration(labelText: 'Recipe Name'),
            ),
            SizedBox(height: 20),
            Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _ingredientNameControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientNameControllers[index],
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ingredientQuantityControllers[index],
                          decoration: InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ingredientUnitControllers[index],
                          decoration: InputDecoration(labelText: 'Unit'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _ingredientNameControllers.removeAt(index);
                            _ingredientQuantityControllers.removeAt(index);
                            _ingredientUnitControllers.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addIngredientField,
              child: Text('Add Ingredient'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRecipe,
              child: Text('Update Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
