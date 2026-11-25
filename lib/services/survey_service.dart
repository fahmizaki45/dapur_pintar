import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class SurveyMenuItem {
  final String id;
  final Map<String, dynamic> recipeJson;
  final int votes;
  final bool hasVoted;
  final String proposedBy;

  const SurveyMenuItem({
    required this.id,
    required this.recipeJson,
    required this.votes,
    required this.hasVoted,
    required this.proposedBy,
  });

  static const int approvalThreshold = 5;

  bool get isApproved => votes >= approvalThreshold;
  Recipe get recipe => Recipe.fromJson(recipeJson);

  SurveyMenuItem copyWith({int? votes, bool? hasVoted}) => SurveyMenuItem(
    id: id,
    recipeJson: recipeJson,
    votes: votes ?? this.votes,
    hasVoted: hasVoted ?? this.hasVoted,
    proposedBy: proposedBy,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipeJson': recipeJson,
    'votes': votes,
    'hasVoted': hasVoted,
    'proposedBy': proposedBy,
  };

  factory SurveyMenuItem.fromJson(Map<String, dynamic> json) => SurveyMenuItem(
    id: json['id']?.toString() ?? '',
    recipeJson: Map<String, dynamic>.from(json['recipeJson'] as Map),
    votes: (json['votes'] as num?)?.toInt() ?? 0,
    hasVoted: json['hasVoted'] == true,
    proposedBy: json['proposedBy']?.toString() ?? 'Survei User',
  );
}

class SurveyService {
  static const _key = 'user_survey_menus';
  static final ValueNotifier<List<SurveyMenuItem>> items = ValueNotifier([]);

  /// Daftar resep hasil survei yang sudah mencapai target suara (>= 5 vote).
  static List<Recipe> get approvedRecipes =>
      items.value.where((e) => e.isApproved).map((e) => e.recipe).toList();

  static Future<void> loadSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      items.value = _defaultCandidates();
      await _save(items.value);
      return;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    items.value = decoded
        .map((e) => SurveyMenuItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _save(List<SurveyMenuItem> updated) async {
    items.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  /// Vote / batal vote. Mengembalikan true jika menu BARU SAJA lolos ke Eksplor.
  static Future<bool> toggleVote(String id) async {
    bool newlyApproved = false;
    final updated = items.value.map((item) {
      if (item.id != id) return item;
      final wasApproved = item.isApproved;
      final nextVoted = !item.hasVoted;
      final nextVotes = nextVoted ? item.votes + 1 : item.votes - 1;
      final nextItem = item.copyWith(votes: nextVotes, hasVoted: nextVoted);
      if (!wasApproved && nextItem.isApproved) {
        newlyApproved = true;
      }
      return nextItem;
    }).toList();

    await _save(updated);
    return newlyApproved;
  }

  /// Menambahkan usulan menu baru dari pengguna ke daftar survei.
  static Future<void> proposeMenu({
    required String name,
    required String cuisine,
    required String mealType,
    required String difficulty,
    required int cookTimeMinutes,
    required List<String> ingredients,
    required List<String> instructions,
    String proposedBy = 'Usulan User',
  }) async {
    final uniqueId = -1000 - (DateTime.now().millisecondsSinceEpoch % 100000);
    final newItem = SurveyMenuItem(
      id: 'survey_${DateTime.now().microsecondsSinceEpoch}',
      votes: 1,
      hasVoted: true,
      proposedBy: proposedBy,
      recipeJson: {
        'id': uniqueId,
        'name': name,
        'cuisine': cuisine.isEmpty ? 'Indonesia' : cuisine,
        'prepTimeMinutes': 10,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': 2,
        'caloriesPerServing': 380,
        'difficulty': difficulty,
        'mealType': [mealType],
        'tags': ['SurveiUser', cuisine],
        'image': '',
        'rating': 4.8,
        'reviewCount': 1,
        'ingredients': ingredients,
        'instructions': instructions,
      },
    );

    await _save([newItem, ...items.value]);
  }

  static List<SurveyMenuItem> _defaultCandidates() => [
    const SurveyMenuItem(
      id: 'srv_nasgor',
      votes: 4, // 1 vote lagi langsung masuk Eksplor!
      hasVoted: false,
      proposedBy: 'Survei Mahasiswa',
      recipeJson: {
        'id': -101,
        'name': 'Nasi Goreng Kampung Spesial',
        'cuisine': 'Indonesia',
        'prepTimeMinutes': 10,
        'cookTimeMinutes': 15,
        'servings': 2,
        'caloriesPerServing': 450,
        'difficulty': 'Easy',
        'mealType': ['Dinner', 'Breakfast'],
        'tags': ['SurveiUser', 'Indonesia', 'Praktis'],
        'image': '',
        'rating': 4.9,
        'reviewCount': 24,
        'ingredients': [
          '2 piring nasi putih dingin',
          '2 butir telur ayam',
          '4 siung bawang putih, cincang',
          '5 siung bawang merah, iris',
          '2 sdm kecap manis',
          '1 sdm kecap asin',
          'Garam dan lada secukupnya',
          '2 sdm minyak goreng',
        ],
        'instructions': [
          'Panaskan minyak goreng, tumis bawang merah dan bawang putih hingga harum.',
          'Geser bumbu ke pinggir wajan, masukkan telur lalu buat orak-arik.',
          'Masukkan nasi putih, aduk rata dengan api besar.',
          'Tambahkan kecap manis, kecap asin, garam, dan lada. Aduk hingga berasap dan matang merata.',
          'Sajikan hangat dengan kerupuk dan irisan timun.',
        ],
      },
    ),
    const SurveyMenuItem(
      id: 'srv_geprek',
      votes: 4, // 1 vote lagi langsung masuk Eksplor!
      hasVoted: false,
      proposedBy: 'Survei Kosan',
      recipeJson: {
        'id': -102,
        'name': 'Ayam Geprek Sambal Bawang',
        'cuisine': 'Indonesia',
        'prepTimeMinutes': 15,
        'cookTimeMinutes': 20,
        'servings': 2,
        'caloriesPerServing': 520,
        'difficulty': 'Medium',
        'mealType': ['Lunch', 'Dinner'],
        'tags': ['SurveiUser', 'Pedas', 'Indonesia'],
        'image': '',
        'rating': 4.8,
        'reviewCount': 19,
        'ingredients': [
          '2 potong dada ayam fillet',
          '5 sdm tepung serbaguna',
          '10 buah cabai rawit merah',
          '4 siung bawang putih',
          'Garam secukupnya',
          'Minyak goreng secukupnya',
        ],
        'instructions': [
          'Balur dada ayam dengan tepung serbaguna basah lalu tepung kering.',
          'Goreng ayam dalam minyak panas hingga kuning keemasan dan renyah, tiriskan.',
          'Ulek kasar cabai rawit, bawang putih, dan garam, lalu siram 2 sdm minyak panas.',
          'Letakkan ayam goreng di atas cobek, geprek bersama sambal bawang, lalu sajikan dengan nasi hangat.',
        ],
      },
    ),
    const SurveyMenuItem(
      id: 'srv_soto',
      votes: 3,
      hasVoted: false,
      proposedBy: 'Survei Komunitas',
      recipeJson: {
        'id': -103,
        'name': 'Soto Ayam Lamongan',
        'cuisine': 'Jawa Timur',
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 35,
        'servings': 4,
        'caloriesPerServing': 390,
        'difficulty': 'Medium',
        'mealType': ['Lunch', 'Breakfast'],
        'tags': ['SurveiUser', 'Kuah', 'JawaTimur'],
        'image': '',
        'rating': 4.9,
        'reviewCount': 31,
        'ingredients': [
          '500 gr daging ayam',
          '2 liter air',
          '5 siung bawang putih',
          '6 siung bawang merah',
          '2 ruas kunyit dan 1 ruas jahe',
          '2 batang serai dan 3 lembar daun salam',
          'Soun, kol iris, telur rebus, dan koya',
        ],
        'instructions': [
          'Rebus ayam hingga empuk, angkat lalu suwir-suwir dagingnya.',
          'Haluskan bawang putih, bawang merah, kunyit, dan jahe, lalu tumis bersama serai dan daun salam.',
          'Masukkan bumbu tumis ke dalam air kaldu ayam, bumbui garam dan gula, masak hingga harum.',
          'Tata soun, kol, ayam suwir, dan telur di mangkuk, siram kuah panas dan taburi koya.',
        ],
      },
    ),
    const SurveyMenuItem(
      id: 'srv_pisang',
      votes: 3,
      hasVoted: false,
      proposedBy: 'Survei User',
      recipeJson: {
        'id': -104,
        'name': 'Pisang Goreng Krispi Keju',
        'cuisine': 'Indonesia',
        'prepTimeMinutes': 10,
        'cookTimeMinutes': 12,
        'servings': 3,
        'caloriesPerServing': 280,
        'difficulty': 'Easy',
        'mealType': ['Snack', 'Dessert'],
        'tags': ['SurveiUser', 'Camilan', 'Manis'],
        'image': '',
        'rating': 4.7,
        'reviewCount': 14,
        'ingredients': [
          '6 buah pisang kepok matang',
          '6 sdm tepung terigu',
          '2 sdm tepung beras',
          '2 sdm gula pasir dan sejumput garam',
          'Keju cheddar parut dan susu kental manis',
        ],
        'instructions': [
          'Campur tepung terigu, tepung beras, gula, garam, dan air hingga menjadi adonan kental.',
          'Belah pisang bentuk kipas, celupkan ke adonan tepung.',
          'Goreng hingga matang kecokelatan dan renyah, tiriskan.',
          'Beri susu kental manis dan taburan keju parut di atasnya.',
        ],
      },
    ),
  ];
}