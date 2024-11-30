import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init() {
    // 初始化数据库工厂（仅在非移动端环境下需要）
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id)
      )
    ''');
  }

  // 插入新食谱
  Future<int> insertRecipe(String name, List<Map<String, dynamic>> ingredients) async {
    final db = await database;

    // 插入食谱主表
    final recipeId = await db.insert('recipes', {'name': name});

    // 插入对应的原料表
    for (final ingredient in ingredients) {
      ingredient['recipe_id'] = recipeId;
      await db.insert('ingredients', ingredient);
    }

    return recipeId;
  }

  // 获取所有食谱
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await database;
    return await db.query('recipes');
  }

  // 查询特定食谱的详情
  Future<Map<String, dynamic>> getRecipeById(int recipeId) async {
    final db = await database;
    final recipes = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    if (recipes.isNotEmpty) {
      return recipes.first;
    } else {
      throw Exception('Recipe not found');
    }
  }

  // 查询食谱的所有原料
  Future<List<Map<String, dynamic>>> getIngredientsByRecipeId(int recipeId) async {
    final db = await database;

    return await db.query(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }

  // 更新食谱
  Future<int> updateRecipe(int recipeId, String name, List<Map<String, dynamic>> ingredients) async {
    final db = await database;

    // 更新食谱主表
    await db.update(
      'recipes',
      {'name': name},
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    // 删除旧的原料
    await db.delete(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    // 插入新的原料
    for (final ingredient in ingredients) {
      ingredient['recipe_id'] = recipeId;
      await db.insert('ingredients', ingredient);
    }

    return recipeId;
  }

  // 删除食谱
  Future<int> deleteRecipe(int recipeId) async {
    final db = await database;

    // 删除原料表中的记录
    await db.delete(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    // 删除主表中的记录
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
