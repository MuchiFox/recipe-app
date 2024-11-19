import 'package:flutter/material.dart';
import 'add_recipe_screen.dart';
import 'recipe.dart';
import 'recipe_detail_screen.dart';

/// 主入口函数
void main() {
  runApp(RecipeApp());
}

/// 主应用类
class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecipeListScreen(),
    );
  }
}

/// 显示食谱列表的页面
class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  /// 保存所有食谱的列表
  List<Recipe> recipes = [];

  /// 添加新的食谱到列表
  void _addRecipe(String name, List<Ingredient> ingredients) {
    setState(() {
      recipes.add(Recipe(name: name, ingredients: ingredients));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
      ),
      /// 如果没有食谱则显示提示信息，否则显示食谱列表
      body: recipes.isEmpty
          ? Center(child: Text('No recipes added yet!'))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recipes[index].name),
                  /// 将食谱的每个材料格式化成字符串，并作为列表项的副标题
                  subtitle: Text(recipes[index].ingredients.map((ingredient) {
                    return '${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}';
                  }).join(', ')),
                  /// 点击列表项时导航到食谱详情页面
onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailScreen(recipe: recipes[index]),
    ),
  );

  if (result is Recipe) {
    // 如果返回的是 Recipe 对象，则更新食谱列表
    setState(() {
      recipes[index] = result;
    });
  } else if (result == 'delete') {
    // 如果返回的是 'delete' 字符串，则删除食谱
    setState(() {
      recipes.removeAt(index);
    });
  }
},
                );
              },
            ),
      /// 点击浮动按钮添加新食谱
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );

          /// 如果从添加页面返回了新的食谱信息，则添加到列表中
          if (result is Recipe) {
            _addRecipe(result.name, result.ingredients);
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Recipe',
      ),
    );
  }
}
