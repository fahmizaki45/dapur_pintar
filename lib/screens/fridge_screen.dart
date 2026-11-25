import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/ingredient_translator.dart';
import '../services/language_service.dart';
import '../services/my_recipe_service.dart';
import '../services/recipe_service.dart';
import '../services/survey_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class _MatchedRecipe {
  final Recipe recipe;
  final int matchedCount;
  final int totalIngredients;

  const _MatchedRecipe({
    required this.recipe,
    required this.matchedCount,
    required this.totalIngredients,
  });

  double get ratio =>
      totalIngredients == 0 ? 0 : matchedCount / totalIngredients;
  int get missingCount => totalIngredients - matchedCount;
}

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final RecipeService _service = RecipeService();
  final TextEditingController _inputController = TextEditingController();

  /// Menyimpan kunci bahasa Inggris untuk bahan cepat, atau teks bebas untuk bahan custom.
  final Set<String> _selectedKeys = {};

  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _service.fetchRecipes();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _recipesFuture = _service.fetchRecipes());
  }

  void _addCustomIngredient() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _selectedKeys.add(text);
      _inputController.clear();
    });
  }

  List<_MatchedRecipe> _matchRecipes(List<Recipe> allRecipes) {
    if (_selectedKeys.isEmpty) return [];

    final expandedGroups = _selectedKeys
        .map((key) => IngredientTranslator.expandKeywords(key))
        .toList();

    final matches = <_MatchedRecipe>[];

    for (final recipe in allRecipes) {
      var matched = 0;
      for (final ing in recipe.ingredients) {
        final lower = ing.toLowerCase();
        final isMatch = expandedGroups.any(
              (group) => group.any((kw) => lower.contains(kw)),
        );
        if (isMatch) matched++;
      }
      if (matched > 0) {
        matches.add(
          _MatchedRecipe(
            recipe: recipe,
            matchedCount: matched,
            totalIngredients: recipe.ingredients.length,
          ),
        );
      }
    }

    matches.sort((a, b) {
      final cmp = b.ratio.compareTo(a.ratio);
      if (cmp != 0) return cmp;
      return a.missingCount.compareTo(b.missingCount);
    });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEn = context.isEn;
    final minLabel = context.tr('mnt', 'min');
    final quickEnKeys =
    IngredientTranslator.quickIngredients.map((e) => e.en).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('Isi Kulkas', 'My Fridge'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const LanguageToggleButton(),
          if (_selectedKeys.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selectedKeys.clear()),
              child: Text(context.tr('Reset', 'Reset')),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addCustomIngredient(),
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'Tambah bahan lain (contoh: tahu, wortel)...',
                        'Add other ingredient (e.g., tofu, carrot)...',
                      ),
                      prefixIcon: const Icon(Icons.kitchen_outlined),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addCustomIngredient,
                  icon: const Icon(Icons.add),
                  tooltip: context.tr('Tambah bahan', 'Add ingredient'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...IngredientTranslator.quickIngredients.map((item) {
                  final selected = _selectedKeys.contains(item.en);
                  return FilterChip(
                    label: Text(item.label(isEn)),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedKeys.add(item.en);
                        } else {
                          _selectedKeys.remove(item.en);
                        }
                      });
                    },
                  );
                }),
                ..._selectedKeys.where((k) => !quickEnKeys.contains(k)).map(
                      (custom) => InputChip(
                    label: Text(
                      IngredientTranslator.translate(
                        custom,
                        isEnglish: isEn,
                      ),
                    ),
                    selected: true,
                    onDeleted: () =>
                        setState(() => _selectedKeys.remove(custom)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingView(
                    message: context.tr(
                      'Menyiapkan data resep...',
                      'Preparing recipe data...',
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: _retry,
                  );
                }
                if (_selectedKeys.isEmpty) {
                  return EmptyView(
                    message: context.tr(
                      'Pilih bahan yang kamu punya di atas.\nAplikasi akan mencarikan resep paling cocok.',
                      'Select the ingredients you have above.\nThe app will find the best matching recipes.',
                    ),
                  );
                }

                return ListenableBuilder(
                  listenable: Listenable.merge([
                    MyRecipeService.recipes,
                    SurveyService.items,
                  ]),
                  builder: (context, _) {
                    final List<Recipe> combined = [
                      ...MyRecipeService.recipes.value,
                      ...SurveyService.approvedRecipes,
                      ...?snapshot.data,
                    ];
                    final matches = _matchRecipes(combined);

                    if (matches.isEmpty) {
                      return EmptyView(
                        message: context.tr(
                          'Belum ada resep yang cocok dengan bahan tersebut.\nCoba pilih bahan tambahan lain.',
                          'No matching recipes found for those ingredients.\nTry selecting more ingredients.',
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: matches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = matches[i];
                        final pct = (item.ratio * 100).round();
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(recipe: item.recipe),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child:
                                  NetworkImageBox(url: item.recipe.image),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.recipe.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.recipe.totalTimeMinutes} $minLabel • ${item.recipe.difficulty}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.primaryContainer,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.missingCount == 0
                                                ? context.tr(
                                              'Cocok 100% • Semua bahan siap!',
                                              '100% Match • All ingredients ready!',
                                            )
                                                : context.tr(
                                              'Cocok $pct% • Kurang ${item.missingCount} bahan',
                                              '$pct% Match • Missing ${item.missingCount} items',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colors.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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