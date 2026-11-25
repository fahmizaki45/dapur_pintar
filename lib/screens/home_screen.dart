import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/favorite_service.dart';
import '../services/language_service.dart';
import '../services/my_recipe_service.dart';
import '../services/recipe_service.dart';
import '../services/survey_service.dart';
import '../services/theme_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';
import 'survey_screen.dart';

enum SortOption { none, rating, fastest }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _mealTypes = [
    'all',
    'favorite',
    'community',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  final RecipeService _service = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  final Random _random = Random();

  late Future<List<Recipe>> _recipesFuture;
  List<Recipe> _cachedApiRecipes = [];
  Timer? _debounce;
  String _query = '';
  String _selectedMeal = 'all';
  SortOption _sort = SortOption.none;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _fetchAndCache();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Recipe>> _fetchAndCache({String query = ''}) async {
    final data = await _service.fetchRecipes(query: query);
    _cachedApiRecipes = data;
    return data;
  }

  void _load() {
    setState(() {
      _recipesFuture = _fetchAndCache(query: _query);
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _load();
    });
  }

  Future<void> _refresh() async {
    final future = _fetchAndCache(query: _query);
    setState(() => _recipesFuture = future);
    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  String _mealLabel(BuildContext context, String key) {
    if (key == 'all') return context.tr('Semua', 'All');
    if (key == 'favorite') return context.tr('Favorit', 'Favorites');
    if (key == 'community') return context.tr('Komunitas', 'Community');
    return key;
  }

  /// Menggabungkan resep publik dari Resep Saya + Hasil Survei + API DummyJSON.
  List<Recipe> _mergeExploreRecipes(List<Recipe> apiRecipes) {
    final kw = _query.trim().toLowerCase();
    final List<Recipe> community = [
      ...MyRecipeService.publishedRecipes,
      ...SurveyService.approvedRecipes,
    ].where((r) {
      if (kw.isEmpty) return true;
      return r.name.toLowerCase().contains(kw) ||
          r.cuisine.toLowerCase().contains(kw) ||
          r.ingredients.any((i) => i.toLowerCase().contains(kw));
    }).toList();

    return [...community, ...apiRecipes];
  }

  List<Recipe> _applyFilters(List<Recipe> all, Set<int> favIds) {
    var result = all.where((r) {
      if (_selectedMeal == 'all') return true;
      if (_selectedMeal == 'favorite') return favIds.contains(r.id);
      if (_selectedMeal == 'community') return r.id < 0;
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

  void _openGachaSheet() {
    final pool = _mergeExploreRecipes(_cachedApiRecipes);
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LanguageService.tr(
              'Tunggu resep selesai dimuat dulu ya.',
              'Please wait until recipes finish loading.',
            ),
          ),
        ),
      );
      return;
    }

    Recipe picked = pool[_random.nextInt(pool.length)];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final minLabel = LanguageService.tr('mnt', 'min');
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LanguageService.tr(
                    'Rekomendasi Masak Hari Ini',
                    "Today's Cooking Pick",
                  ),
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: NetworkImageBox(url: picked.image),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  picked.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${picked.cuisine} • ${picked.totalTimeMinutes} $minLabel • ${picked.difficulty} • ★ ${picked.rating.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            if (pool.length > 1) {
                              Recipe next;
                              do {
                                next = pool[_random.nextInt(pool.length)];
                              } while (next.id == picked.id);
                              picked = next;
                            }
                          });
                        },
                        icon: const Icon(Icons.casino_outlined),
                        label: Text(LanguageService.tr('Acak Lagi', 'Shuffle')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(recipe: picked),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu),
                        label: Text(
                            LanguageService.tr('Lihat Resep', 'View Recipe')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dapur Pintar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: context.tr('Survei & Usul Menu', 'Menu Survey'),
            icon: const Icon(Icons.poll_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SurveyScreen()),
            ),
          ),
          const LanguageToggleButton(),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark
                    ? context.tr('Mode Terang', 'Light Mode')
                    : context.tr('Mode Gelap', 'Dark Mode'),
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: ThemeService.toggleTheme,
              );
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: context.tr('Urutkan', 'Sort'),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: SortOption.none,
                child: Text(LanguageService.tr('Default', 'Default')),
              ),
              PopupMenuItem(
                value: SortOption.rating,
                child: Text(
                    LanguageService.tr('Rating tertinggi', 'Highest rating')),
              ),
              PopupMenuItem(
                value: SortOption.fastest,
                child: Text(
                    LanguageService.tr('Tercepat dimasak', 'Fastest to cook')),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGachaSheet,
        icon: const Icon(Icons.casino_outlined),
        label: Text(context.tr('Bingung Masak?', 'Surprise Me')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.tr(
                  'Cari resep (contoh: pizza, nasi goreng)...',
                  'Search recipes (e.g., pizza, salad)...',
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _debounce?.cancel();
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
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
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
                  label: Text(_mealLabel(context, meal)),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingView(
                    message:
                    context.tr('Mengambil resep...', 'Loading recipes...'),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _load,
                  );
                }

                return ListenableBuilder(
                  listenable: Listenable.merge([
                    FavoriteService.favoriteIds,
                    MyRecipeService.recipes,
                    MyRecipeService.publishedIds,
                    SurveyService.items,
                  ]),
                  builder: (context, _) {
                    final combined = _mergeExploreRecipes(snapshot.data ?? []);
                    final recipes = _applyFilters(
                      combined,
                      FavoriteService.favoriteIds.value,
                    );

                    if (recipes.isEmpty) {
                      return EmptyView(
                        message: _selectedMeal == 'favorite'
                            ? context.tr(
                          'Belum ada resep favorit.\nKetuk ikon hati di detail resep untuk menyimpan.',
                          'No favorite recipes yet.\nTap the heart icon on a recipe to save it.',
                        )
                            : _selectedMeal == 'community'
                            ? context.tr(
                          'Belum ada menu komunitas.\nPublikasikan dari Resep Saya atau dukung menu di Survei!',
                          'No community recipes yet.\nPublish from My Recipes or vote in Menu Survey!',
                        )
                            : context.tr(
                          'Resep tidak ditemukan.\nCoba kata kunci atau filter lain.',
                          'No recipes found.\nTry another keyword or filter.',
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}