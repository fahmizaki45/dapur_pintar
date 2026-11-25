import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class MyRecipeService {
  static const _key = 'my_custom_recipes';
  static const _publishedKey = 'my_published_recipe_ids';

  static final ValueNotifier<List<Recipe>> recipes = ValueNotifier([]);
  static final ValueNotifier<Set<int>> publishedIds = ValueNotifier({});

  static List<Recipe> get publishedRecipes => recipes.value
      .where((r) => publishedIds.value.contains(r.id))
      .toList();

  static bool isPublished(int id) => publishedIds.value.contains(id);

  static Future<void> loadMyRecipes() async {
    final prefs = await SharedPreferences.getInstance();

    final pubList = prefs.getStringList(_publishedKey) ?? [];
    publishedIds.value = pubList.map(int.parse).toSet();

    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      recipes.value = [];
      return;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    recipes.value = decoded
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _toJson(Recipe r) => {
    'id': r.id,
    'name': r.name,
    'ingredients': r.ingredients,
    'instructions': r.instructions,
    'prepTimeMinutes': r.prepTimeMinutes,
    'cookTimeMinutes': r.cookTimeMinutes,
    'servings': r.servings,
    'difficulty': r.difficulty,
    'cuisine': r.cuisine,
    'caloriesPerServing': r.caloriesPerServing,
    'tags': r.tags,
    'image': r.image,
    'rating': r.rating,
    'reviewCount': r.reviewCount,
    'mealType': r.mealType,
  };

  static Future<void> _saveAll(List<Recipe> updated) async {
    recipes.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map(_toJson).toList()),
    );
  }

  static Future<void> _savePublished(Set<int> updated) async {
    publishedIds.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _publishedKey,
      updated.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> saveRecipeMap(
      Map<String, dynamic> data, {
        required bool publishToExplore,
      }) async {
    final recipe = Recipe.fromJson(data);
    final list = List<Recipe>.from(recipes.value);
    final idx = list.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      list[idx] = recipe;
    } else {
      list.insert(0, recipe);
    }
    await _saveAll(list);

    final pub = Set<int>.from(publishedIds.value);
    if (publishToExplore) {
      pub.add(recipe.id);
    } else {
      pub.remove(recipe.id);
    }
    await _savePublished(pub);
  }

  static Future<void> deleteRecipe(int id) async {
    final updated = recipes.value.where((r) => r.id != id).toList();
    await _saveAll(updated);

    if (publishedIds.value.contains(id)) {
      final pub = Set<int>.from(publishedIds.value)..remove(id);
      await _savePublished(pub);
    }
  }
}