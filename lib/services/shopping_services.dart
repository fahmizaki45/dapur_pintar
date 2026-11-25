import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String sourceRecipe;
  final bool isBought;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.sourceRecipe,
    this.isBought = false,
  });

  ShoppingItem copyWith({bool? isBought}) => ShoppingItem(
    id: id,
    name: name,
    sourceRecipe: sourceRecipe,
    isBought: isBought ?? this.isBought,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sourceRecipe': sourceRecipe,
    'isBought': isBought,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    sourceRecipe: json['sourceRecipe']?.toString() ?? 'Manual',
    isBought: json['isBought'] == true,
  );
}

class ShoppingService {
  static const _key = 'shopping_list_items';
  static final ValueNotifier<List<ShoppingItem>> items = ValueNotifier([]);

  static Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      items.value = [];
      return;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    items.value = decoded
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _save(List<ShoppingItem> updated) async {
    items.value = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> addItem(String name, {String sourceRecipe = 'Manual'}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      ShoppingItem(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
        sourceRecipe: sourceRecipe,
      ),
      ...items.value,
    ];
    await _save(updated);
  }

  /// Menambahkan banyak bahan sekaligus & otomatis melewati item yang sudah ada.
  static Future<int> addMultiple(
      List<String> names, {
        required String sourceRecipe,
      }) async {
    final existing = items.value
        .where((e) => !e.isBought)
        .map((e) => e.name.toLowerCase().trim())
        .toSet();

    final toAdd = <ShoppingItem>[];
    var counter = 0;
    for (final rawName in names) {
      final clean = rawName.trim();
      if (clean.isEmpty || existing.contains(clean.toLowerCase())) continue;
      existing.add(clean.toLowerCase());
      toAdd.add(
        ShoppingItem(
          id: '${DateTime.now().microsecondsSinceEpoch}_${counter++}',
          name: clean,
          sourceRecipe: sourceRecipe,
        ),
      );
    }

    if (toAdd.isNotEmpty) {
      await _save([...toAdd, ...items.value]);
    }
    return toAdd.length;
  }

  static Future<void> toggleBought(String id) async {
    final updated = items.value
        .map((e) => e.id == id ? e.copyWith(isBought: !e.isBought) : e)
        .toList();
    await _save(updated);
  }

  static Future<void> removeItem(String id) async {
    final updated = items.value.where((e) => e.id != id).toList();
    await _save(updated);
  }

  static Future<void> clearBought() async {
    final updated = items.value.where((e) => !e.isBought).toList();
    await _save(updated);
  }
}