class QuickIngredient {
  final String en;
  final String id;
  final List<String> keywords;

  const QuickIngredient({
    required this.en,
    required this.id,
    required this.keywords,
  });

  String label(bool isEnglish) => isEnglish ? en : id;
}

class IngredientTranslator {
  static const List<QuickIngredient> quickIngredients = [
    QuickIngredient(en: 'Chicken', id: 'Ayam', keywords: ['chicken', 'ayam']),
    QuickIngredient(en: 'Beef', id: 'Daging Sapi', keywords: ['beef', 'sapi']),
    QuickIngredient(en: 'Egg', id: 'Telur', keywords: ['egg', 'telur']),
    QuickIngredient(
        en: 'Garlic', id: 'Bawang Putih', keywords: ['garlic', 'bawang putih']),
    QuickIngredient(
        en: 'Onion',
        id: 'Bawang',
        keywords: ['onion', 'bawang merah', 'bawang bombay']),
    QuickIngredient(en: 'Tomato', id: 'Tomat', keywords: ['tomato', 'tomat']),
    QuickIngredient(en: 'Cheese', id: 'Keju', keywords: ['cheese', 'keju']),
    QuickIngredient(
        en: 'Olive Oil',
        id: 'Minyak Zaitun',
        keywords: ['olive oil', 'minyak zaitun', 'minyak']),
    QuickIngredient(
        en: 'Rice', id: 'Nasi / Beras', keywords: ['rice', 'nasi', 'beras']),
    QuickIngredient(en: 'Pasta', id: 'Pasta / Mi', keywords: ['pasta', 'noodle', 'mi']),
    QuickIngredient(en: 'Flour', id: 'Tepung', keywords: ['flour', 'tepung']),
    QuickIngredient(
        en: 'Butter', id: 'Mentega', keywords: ['butter', 'mentega', 'margarin']),
    QuickIngredient(en: 'Milk', id: 'Susu', keywords: ['milk', 'susu']),
    QuickIngredient(
        en: 'Soy Sauce',
        id: 'Kecap',
        keywords: ['soy sauce', 'kecap']),
    QuickIngredient(en: 'Sugar', id: 'Gula', keywords: ['sugar', 'gula']),
    QuickIngredient(en: 'Salt', id: 'Garam', keywords: ['salt', 'garam']),
  ];

  // Frasa multi-kata diterjemahkan lebih dulu agar susunan kalimat alami.
  static const Map<String, String> _phraseMap = {
    'salt and pepper to taste': 'garam dan lada secukupnya',
    'fresh mozzarella cheese': 'keju mozzarella segar',
    'fresh basil leaves': 'daun kemangi segar',
    'all-purpose flour': 'tepung serbaguna',
    'mozzarella cheese': 'keju mozzarella',
    'parmesan cheese': 'keju parmesan',
    'cheddar cheese': 'keju cheddar',
    'cream cheese': 'krim keju',
    'heavy cream': 'krim kental',
    'sour cream': 'krim asam',
    'tomato sauce': 'saus tomat',
    'soy sauce': 'kecap asin',
    'fish sauce': 'kecap ikan',
    'oyster sauce': 'saus tiram',
    'chili sauce': 'saus cabai',
    'olive oil': 'minyak zaitun',
    'sesame oil': 'minyak wijen',
    'vegetable oil': 'minyak sayur',
    'cooking oil': 'minyak goreng',
    'pizza dough': 'adonan pizza',
    'brown sugar': 'gula merah',
    'white sugar': 'gula pasir',
    'powdered sugar': 'gula halus',
    'baking soda': 'soda kue',
    'baking powder': 'bubuk pengembang',
    'vanilla extract': 'ekstrak vanila',
    'chocolate chips': 'butiran cokelat',
    'bell peppers': 'paprika',
    'bell pepper': 'paprika',
    'green onions': 'daun bawang',
    'spring onions': 'daun bawang',
    'basil leaves': 'daun kemangi',
    'bay leaves': 'daun salam',
    'mint leaves': 'daun mint',
    'coriander leaves': 'daun ketumbar',
    'chicken breast': 'dada ayam',
    'chicken thighs': 'paha ayam',
    'ground beef': 'daging sapi cincang',
    'minced garlic': 'bawang putih cincang',
    'minced ginger': 'jahe cincang',
    'red onion': 'bawang merah',
    'black pepper': 'lada hitam',
    'cooked rice': 'nasi matang',
    'lemon juice': 'air perasan lemon',
    'lime juice': 'air perasan jeruk nipis',
    'condensed milk': 'susu kental manis',
    'coconut milk': 'santan',
    'cocoa powder': 'bubuk cokelat',
    'green tea': 'teh hijau',
    'peanut butter': 'selai kacang',
    'to taste': 'secukupnya',
    'for serving': 'untuk penyajian',
    'for garnish': 'untuk hiasan',
  };

  static const Map<String, String> _wordMap = {
    'chicken': 'ayam',
    'beef': 'daging sapi',
    'shrimp': 'udang',
    'fish': 'ikan',
    'tofu': 'tahu',
    'eggs': 'telur',
    'egg': 'telur',
    'garlic': 'bawang putih',
    'onions': 'bawang bombay',
    'onion': 'bawang bombay',
    'tomatoes': 'tomat',
    'tomato': 'tomat',
    'cheese': 'keju',
    'rice': 'nasi',
    'flour': 'tepung',
    'butter': 'mentega',
    'milk': 'susu',
    'sugar': 'gula',
    'salt': 'garam',
    'pepper': 'lada',
    'ginger': 'jahe',
    'carrots': 'wortel',
    'carrot': 'wortel',
    'broccoli': 'brokoli',
    'spinach': 'bayam',
    'lettuce': 'selada',
    'cucumber': 'timun',
    'mushrooms': 'jamur',
    'mushroom': 'jamur',
    'potatoes': 'kentang',
    'potato': 'kentang',
    'avocado': 'alpukat',
    'lime': 'jeruk nipis',
    'honey': 'madu',
    'vinegar': 'cuka',
    'water': 'air',
    'oil': 'minyak',
    'sauce': 'saus',
    'fresh': 'segar',
    'sliced': 'iris',
    'chopped': 'cincang',
    'diced': 'potong dadu',
    'minced': 'cincang halus',
    'softened': 'lunak',
    'melted': 'leleh',
    'cooked': 'matang',
    'grated': 'parut',
    'cubed': 'potong dadu',
    'florets': 'kuntum',
    'cloves': 'siung',
    'clove': 'siung',
    'tablespoons': 'sdm',
    'tablespoon': 'sdm',
    'teaspoons': 'sdt',
    'teaspoon': 'sdt',
    'cups': 'gelas',
    'cup': 'gelas',
    'slices': 'lembar',
    'slice': 'lembar',
    'and': 'dan',
    'or': 'atau',
    'with': 'dengan',
    'for': 'untuk',
  };

  /// Menerjemahkan nama bahan Inggris ke Indonesia saat mode ID aktif.
  static String translate(String raw, {required bool isEnglish}) {
    if (isEnglish || raw.trim().isEmpty) return raw;

    var text = raw;

    for (final entry in _phraseMap.entries) {
      final regex = RegExp(
        r'\b' + RegExp.escape(entry.key) + r'\b',
        caseSensitive: false,
      );
      text = text.replaceAll(regex, entry.value);
    }

    for (final entry in _wordMap.entries) {
      final regex = RegExp(
        r'\b' + RegExp.escape(entry.key) + r'\b',
        caseSensitive: false,
      );
      text = text.replaceAll(regex, entry.value);
    }

    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }
    return text;
  }

  /// Memperluas kata kunci bahan agar input Indonesia (mis. "ayam")
  /// tetap cocok dengan resep Inggris (mis. "chicken") dan sebaliknya.
  static List<String> expandKeywords(String input) {
    final lower = input.toLowerCase().trim();
    if (lower.isEmpty) return [];

    final keys = <String>{lower};

    for (final q in quickIngredients) {
      if (q.en.toLowerCase() == lower ||
          q.id.toLowerCase() == lower ||
          q.keywords.contains(lower)) {
        keys.addAll(q.keywords);
      }
    }

    for (final entry in _wordMap.entries) {
      if (entry.key == lower || entry.value == lower) {
        keys.add(entry.key);
        keys.add(entry.value);
      }
    }

    for (final entry in _phraseMap.entries) {
      if (entry.key == lower || entry.value == lower) {
        keys.add(entry.key);
        keys.add(entry.value);
      }
    }

    return keys.toList();
  }
}