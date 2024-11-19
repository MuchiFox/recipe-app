import 'package:flutter/material.dart';
import 'recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe;

  AddRecipeScreen({this.existingRecipe});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController nameController = TextEditingController();
  List<Ingredient> ingredients = [];
  final TextEditingController ingredientNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String selectedUnit = 'g';
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      nameController.text = widget.existingRecipe!.name;
      ingredients = List.from(widget.existingRecipe!.ingredients);
    }
  }

  /// 添加或更新一个材料
  void _addOrUpdateIngredient() {
    setState(() {
      final newIngredient = Ingredient(
        name: ingredientNameController.text,
        quantity: double.tryParse(quantityController.text) ?? 0,
        unit: selectedUnit,
      );

      if (editingIndex == null) {
        ingredients.add(newIngredient); // 添加新材料
      } else {
        ingredients[editingIndex!] = newIngredient; // 更新已有材料
        editingIndex = null; // 重置编辑索引
      }

      // 清空输入框
      ingredientNameController.clear();
      quantityController.clear();
      selectedUnit = 'g';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Recipe Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: ingredientNameController,
              decoration: InputDecoration(labelText: 'Ingredient Name'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            DropdownButton<String>(
              value: selectedUnit,
              onChanged: (newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              items: ['g', 'cups', 'per', 'tsp', 'tbsp'].map<DropdownMenuItem<String>>((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _addOrUpdateIngredient,
              child: Text(editingIndex == null ? 'Add Ingredient' : 'Update Ingredient'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return ListTile(
                    title: Text('${ingredient.name} - ${ingredient.quantity.toStringAsFixed(2)} ${ingredient.unit}'),
                    onTap: () {
                      // 点击材料项时加载到输入框用于编辑
                      ingredientNameController.text = ingredient.name;
                      quantityController.text = ingredient.quantity.toString();
                      selectedUnit = ingredient.unit;
                      setState(() {
                        editingIndex = index; // 设置当前编辑的材料索引
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, Recipe(name: nameController.text, ingredients: ingredients));
              },
              child: Text(widget.existingRecipe == null ? 'Save Recipe' : 'Update Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
