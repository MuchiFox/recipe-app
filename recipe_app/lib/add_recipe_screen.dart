import 'package:flutter/material.dart';
import 'database_helper.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final List<TextEditingController> _ingredientNameControllers = [];
  final List<TextEditingController> _ingredientQuantityControllers = [];
  final List<TextEditingController> _ingredientUnitControllers = [];

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

  // 收集用户输入的原料数据
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

  // 添加新食谱的函数
  Future<void> _addRecipe(String name, List<Map<String, dynamic>> ingredients) async {
    final dbHelper = DatabaseHelper.instance;

    // 确保原料数据是正确的格式
    List<Map<String, dynamic>> formattedIngredients = ingredients.map((ingredient) {
      return {
        'name': ingredient['name'] ?? '',
        'quantity': ingredient['quantity'] ?? 0,
        'unit': ingredient['unit'] ?? '',
      };
    }).toList();

    // 插入到数据库
    await dbHelper.insertRecipe(name, formattedIngredients);
  }

  // 添加新的原料输入框
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
        title: Text('Add Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入食谱名称
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
                      // 原料名称输入框
                      Expanded(
                        child: TextField(
                          controller: _ingredientNameControllers[index],
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                      ),
                      SizedBox(width: 10),
                      // 原料数量输入框
                      Expanded(
                        child: TextField(
                          controller: _ingredientQuantityControllers[index],
                          decoration: InputDecoration(labelText: 'Quantity'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      // 原料单位输入框
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
  onPressed: () async {
    String recipeName = _recipeNameController.text;
    List<Map<String, dynamic>> ingredients = _collectIngredients();

    // 检查用户输入是否有效
    if (recipeName.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a recipe name and at least one ingredient.')),
      );
      return;
    }

    try {
      print('Saving recipe: $recipeName');
      print('Ingredients: $ingredients');

      // 保存到数据库
      await _addRecipe(recipeName, ingredients);

      // 显示保存成功信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe saved successfully!')),
      );

      // 返回到主页面并携带新添加的食谱
      Navigator.pop(context, {"name": recipeName, "ingredients": ingredients});
    } catch (e) {
      print('Error saving recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe. Please try again.')),
      );
    }
  },
  child: Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
