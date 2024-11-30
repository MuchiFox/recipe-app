import 'package:flutter/material.dart';
import 'add_recipe_screen.dart';
import 'recipe.dart';
import 'recipe_detail_screen.dart';
import 'package:recipe_app/database_helper.dart';

import 'recipe_list_screen.dart';



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
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final dbHelper = DatabaseHelper.instance;
    final data = await dbHelper.getAllRecipes();
    setState(() {
      recipes = data;
    });
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('My Recipes'),
    ),
    // 如果没有食谱则提示没有信息，否则显示食谱列表
    body: recipes.isEmpty
        ? Center(child: Text('No recipes added yet!'))
        : ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe['name']),
                subtitle: Text(
                  // 将食谱的每个材料格式化为字符串，并作为列表项的副标题
                  recipe['ingredients']
                      .split(';')
                      .map((ingredient) => ingredient)
                      .join('\n'),
                ),
onTap: () async {
  // 点击列表项时导航到食谱详情页面
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailScreen(
        recipeId: recipe['id'],
      ),
    ),
  );
},

              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        // 点击添加按钮导航到添加食谱页面
        final newRecipe = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddRecipeScreen()),
        );

        // 如果有新的食谱则刷新数据
        if (newRecipe != null) {
          _loadRecipes();
        }
      },
      child: Icon(Icons.add),
    ),
  );
}

}
