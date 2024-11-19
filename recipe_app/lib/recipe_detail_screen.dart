import 'package:flutter/material.dart';
import 'recipe.dart';
import 'add_recipe_screen.dart';

/// 食谱详情页面，用于查看和管理单个食谱
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  /// 用于存储每个材料的数量控制器
  List<TextEditingController> quantityControllers = [];

  @override
  void initState() {
    super.initState();
    // 初始化每个材料的数量控制器，默认显示当前的数量
    quantityControllers = widget.recipe.ingredients.map((ingredient) {
      return TextEditingController(text: ingredient.quantity.toString());
    }).toList();
  }

  /// 当某个材料的数量发生变化时，调整其他材料的数量
  void _updateQuantities(int changedIndex, double newQuantity) {
    setState(() {
      // 获取当前被调整的材料的原始数量
      double originalQuantity = widget.recipe.ingredients[changedIndex].quantity;
      // 计算调整比例
      double ratio = newQuantity / originalQuantity;

      // 更新当前材料的数量
      widget.recipe.ingredients[changedIndex].quantity = newQuantity;

      // 按比例调整其他材料的数量
      for (int i = 0; i < widget.recipe.ingredients.length; i++) {
        if (i != changedIndex) {
          // 更新每个材料的数量并更新对应的控制器显示
          double updatedQuantity = widget.recipe.ingredients[i].quantity * ratio;
          widget.recipe.ingredients[i].quantity = updatedQuantity;
          quantityControllers[i].text = updatedQuantity.toStringAsFixed(2); // 保留两位小数
        }
      }
    });
  }

/// 保存并返回更新后的食谱
void _saveAndReturn() {
  // 保留每个材料的数量为两位小数
  for (var ingredient in widget.recipe.ingredients) {
    ingredient.quantity = double.parse(ingredient.quantity.toStringAsFixed(2));
  }
  Navigator.pop(context, widget.recipe); // 返回更新的 Recipe 对象
}


  /// 删除并返回删除标记
  void _deleteAndReturn() {
    Navigator.pop(context, 'delete'); // 返回 'delete' 标记
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedRecipe = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRecipeScreen(existingRecipe: widget.recipe),
                ),
              );

              if (updatedRecipe != null) {
                setState(() {
                  widget.recipe.name = updatedRecipe.name;
                  widget.recipe.ingredients = updatedRecipe.ingredients;
                  quantityControllers = widget.recipe.ingredients.map((ingredient) {
                    return TextEditingController(text: ingredient.quantity.toString());
                  }).toList();
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveAndReturn, // 点击保存并返回更新的食谱
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAndReturn, // 点击删除并返回删除标记
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.recipe.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = widget.recipe.ingredients[index];
                  return ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.quantity.toStringAsFixed(2)} ${ingredient.unit}'), // 保留两位小数
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 数量输入框，用户可以调整数量
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: quantityControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'Quantity'),
                            onChanged: (value) {
                              double? newQuantity = double.tryParse(value);
                              if (newQuantity != null && newQuantity > 0) {
                                _updateQuantities(index, newQuantity);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(ingredient.unit), // 显示单位
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
