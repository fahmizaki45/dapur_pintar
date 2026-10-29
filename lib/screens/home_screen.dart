import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

enum SortOption { none, rating, fastest }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _mealTypes = [
    'Semua',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  final RecipeService _service = RecipeService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Recipe>> _recipesFuture;
  String _query = '';
  String _selectedMeal = 'Semua';
  SortOption _sort = SortOption.none;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _service.fetchRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mengambil ulang data dari API (dipakai oleh pencarian & tombol coba lagi).
  void _load() {
    setState(() {
      _recipesFuture = _service.fetchRecipes(query: _query);
    });
  }

  Future<void> _refresh() async {
    final future = _service.fetchRecipes(query: _query);
    setState(() => _recipesFuture = future);
    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  /// Pengolahan data di sisi aplikasi: filter jenis hidangan + pengurutan.
  List<Recipe> _applyFilters(List<Recipe> all) {
    var result = all.where((r) {
      if (_selectedMeal == 'Semua') return true;
      return r.mealType.contains(_selectedMeal);
    }).toList();

    switch (_sort) {
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.fastest:
        result.sort((a, b) => a.totalTimeMinutes.compareTo(b.totalTimeMinutes));
        break;
      case SortOption.none:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dapur Pintar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: SortOption.none, child: Text('Default')),
              PopupMenuItem(
                  value: SortOption.rating, child: Text('Rating tertinggi')),
              PopupMenuItem(
                  value: SortOption.fastest, child: Text('Tercepat dimasak')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari resep (contoh: pizza, salad)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _query = '';
                          _load();
                        },
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                _query = value;
                _load();
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _mealTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final meal = _mealTypes[i];
                return ChoiceChip(
                  label: Text(meal),
                  selected: _selectedMeal == meal,
                  onSelected: (_) => setState(() => _selectedMeal = meal),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                // 1. LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(message: 'Mengambil resep...');
                }
                // 2. ERROR
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _load,
                  );
                }
                // 3. SUCCESS
                final recipes = _applyFilters(snapshot.data ?? []);
                if (recipes.isEmpty) {
                  return const EmptyView(
                      message:
                          'Resep tidak ditemukan.\nCoba kata kunci atau filter lain.');
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, i) => RecipeCard(
                      recipe: recipes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(recipe: recipes[i]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
