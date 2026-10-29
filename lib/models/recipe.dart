/// Model data resep, dipetakan dari JSON milik DummyJSON Recipes API.
class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final String image;
  final double rating;
  final int reviewCount;
  final List<String> mealType;

  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
  });

  /// Total waktu (persiapan + memasak) dalam menit.
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  /// Mengonversi Map hasil jsonDecode menjadi objek [Recipe].
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> toStringList(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? <String>[];

    return Recipe(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Tanpa nama',
      ingredients: toStringList(json['ingredients']),
      instructions: toStringList(json['instructions']),
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      difficulty: json['difficulty']?.toString() ?? '-',
      cuisine: json['cuisine']?.toString() ?? '-',
      caloriesPerServing: (json['caloriesPerServing'] as num?)?.toInt() ?? 0,
      tags: toStringList(json['tags']),
      image: json['image']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      mealType: toStringList(json['mealType']),
    );
  }
}
