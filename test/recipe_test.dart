import 'package:flutter_test/flutter_test.dart';
import 'package:dapur_pintar/models/recipe.dart';

void main() {
  group('Recipe.fromJson', () {
    test('mengonversi JSON lengkap menjadi objek Recipe', () {
      final json = {
        'id': 1,
        'name': 'Classic Margherita Pizza',
        'ingredients': ['Pizza dough', 'Tomato sauce'],
        'instructions': ['Preheat oven', 'Bake'],
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 15,
        'servings': 4,
        'difficulty': 'Easy',
        'cuisine': 'Italian',
        'caloriesPerServing': 300,
        'tags': ['Pizza'],
        'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
        'rating': 4.6,
        'reviewCount': 98,
        'mealType': ['Dinner'],
      };
      final r = Recipe.fromJson(json);
      expect(r.id, 1);
      expect(r.name, 'Classic Margherita Pizza');
      expect(r.ingredients.length, 2);
      expect(r.totalTimeMinutes, 35);
      expect(r.rating, 4.6);
      expect(r.mealType, ['Dinner']);
    });

    test('tidak crash saat field kosong/null (nilai default)', () {
      final r = Recipe.fromJson({'id': 2});
      expect(r.name, 'Tanpa nama');
      expect(r.ingredients, isEmpty);
      expect(r.totalTimeMinutes, 0);
    });
  });
}
