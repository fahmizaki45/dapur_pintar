import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favorite_recipe_ids';
  static final ValueNotifier<Set<int>> favoriteIds = ValueNotifier({});

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    favoriteIds.value = list.map(int.parse).toSet();
  }

  static Future<bool> toggleFavorite(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = Set<int>.from(favoriteIds.value);
    final bool isNowFav;

    if (updated.contains(recipeId)) {
      updated.remove(recipeId);
      isNowFav = false;
    } else {
      updated.add(recipeId);
      isNowFav = true;
    }

    favoriteIds.value = updated;
    await prefs.setStringList(_key, updated.map((e) => e.toString()).toList());
    return isNowFav;
  }
}