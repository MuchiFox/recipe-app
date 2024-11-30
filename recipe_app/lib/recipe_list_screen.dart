import 'package:flutter/material.dart';
import 'package:recipe_app/recipe_detail_screen.dart';
import 'package:recipe_app/database_helper.dart';



class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();

    // 监听搜索框输入变化
    _searchController.addListener(() {
      _filterRecipes(_searchController.text);
    });
  }

  Future<void> _loadRecipes() async {
    final dbHelper = DatabaseHelper.instance;
    final data = await dbHelper.getAllRecipes();
    setState(() {
      recipes = data;
      filteredRecipes = data; // 初始时显示全部数据
    });
  }

  void _filterRecipes(String query) {
    final filtered = recipes
        .where((recipe) =>
            recipe['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredRecipes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Recipes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(child: Text('No recipes found!'))
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      final ingredients = recipe['ingredients']
                          .split(';')
                          .map((ingredient) => ingredient.trim())
                          .join(', ');

                      return ListTile(
                        title: Text(recipe['name']),
                        subtitle: Text('Ingredients: $ingredients'),
onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetailScreen(
        recipeId: recipe['id'], // 只传递 recipeId
      ),
    ),
  );
},

                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
