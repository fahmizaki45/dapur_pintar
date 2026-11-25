import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/favorite_service.dart';
import '../services/ingredient_translator.dart';
import '../services/language_service.dart';
import '../services/recipe_service.dart';
import '../services/shopping_services.dart';
import '../widgets/cooking_timer_card.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'cooking_mode_screen.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final RecipeService _service = RecipeService();
  late Future<Recipe> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.recipe.id < 0
        ? Future.value(widget.recipe)
        : _service.fetchRecipeById(widget.recipe.id);
  }

  void _retry() {
    setState(() {
      _future = widget.recipe.id < 0
          ? Future.value(widget.recipe)
          : _service.fetchRecipeById(widget.recipe.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          const LanguageToggleButton(),
          ValueListenableBuilder<Set<int>>(
            valueListenable: FavoriteService.favoriteIds,
            builder: (context, favIds, _) {
              final isFav = favIds.contains(widget.recipe.id);
              return IconButton(
                tooltip: isFav
                    ? context.tr('Hapus dari Favorit', 'Remove from Favorites')
                    : context.tr('Simpan ke Favorit', 'Save to Favorites'),
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () async {
                  final added =
                  await FavoriteService.toggleFavorite(widget.recipe.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? LanguageService.tr(
                          '${widget.recipe.name} disimpan ke Favorit',
                          '${widget.recipe.name} added to Favorites',
                        )
                            : LanguageService.tr(
                          '${widget.recipe.name} dihapus dari Favorit',
                          '${widget.recipe.name} removed from Favorites',
                        ),
                      ),
                      action: !added
                          ? SnackBarAction(
                        label: LanguageService.tr('BATALKAN', 'UNDO'),
                        onPressed: () => FavoriteService.toggleFavorite(
                            widget.recipe.id),
                      )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingView(
              message: context.tr(
                'Memuat detail resep...',
                'Loading recipe details...',
              ),
            );
          }
          if (snapshot.hasError) {
            return ErrorView(
                message: snapshot.error.toString(), onRetry: _retry);
          }
          return _DetailContent(recipe: snapshot.data!);
        },
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final Recipe recipe;
  const _DetailContent({required this.recipe});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  final Set<int> _checkedIngredients = {};

  Future<void> _sendMissingToShopping() async {
    final recipe = widget.recipe;
    final missing = <String>[];
    for (var i = 0; i < recipe.ingredients.length; i++) {
      if (!_checkedIngredients.contains(i)) {
        missing.add(recipe.ingredients[i]);
      }
    }

    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LanguageService.tr(
              'Semua bahan sudah siap!',
              'All ingredients are ready!',
            ),
          ),
        ),
      );
      return;
    }

    final addedCount = await ShoppingService.addMultiple(
      missing,
      sourceRecipe: recipe.name,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addedCount > 0
              ? LanguageService.tr(
            '$addedCount bahan ditambahkan ke Daftar Belanja',
            '$addedCount items added to Shopping List',
          )
              : LanguageService.tr(
            'Bahan kurang sudah ada di Daftar Belanja',
            'Missing ingredients are already in Shopping List',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isEn = context.isEn;
    final missingCount = recipe.ingredients.length - _checkedIngredients.length;
    final minLabel = context.tr('mnt', 'min');

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: NetworkImageBox(url: recipe.image),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.rating} (${recipe.reviewCount} ${context.tr('ulasan', 'reviews')})',
                  ),
                  const SizedBox(width: 12),
                  Text(
                    recipe.cuisine,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoTile(
                      icon: Icons.timer_outlined,
                      label: context.tr('Waktu', 'Time'),
                      value: '${recipe.totalTimeMinutes} $minLabel'),
                  _InfoTile(
                      icon: Icons.people_outline,
                      label: context.tr('Porsi', 'Servings'),
                      value: '${recipe.servings}'),
                  _InfoTile(
                      icon: Icons.local_fire_department_outlined,
                      label: context.tr('Kalori', 'Calories'),
                      value: '${recipe.caloriesPerServing}'),
                  _InfoTile(
                      icon: Icons.speed,
                      label: context.tr('Level', 'Level'),
                      value: recipe.difficulty,
                      color: difficultyColor(recipe.difficulty)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...recipe.mealType.map((m) => Chip(label: Text(m))),
                  ...recipe.tags.map((t) => Chip(
                    label: Text('#$t'),
                    backgroundColor: colors.surfaceContainerHighest,
                  )),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CookingModeScreen(recipe: recipe),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(
                    context.tr(
                      'Mulai Memasak (Mode Fokus)',
                      'Start Cooking (Focus Mode)',
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CookingTimerCard(cookTimeMinutes: recipe.cookTimeMinutes),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('Bahan-bahan', 'Ingredients'),
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${_checkedIngredients.length}/${recipe.ingredients.length} ${context.tr('siap', 'ready')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...recipe.ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = IngredientTranslator.translate(
                  entry.value,
                  isEnglish: isEn,
                );
                final isChecked = _checkedIngredients.contains(index);

                return CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isChecked,
                  title: Text(
                    ingredient,
                    style: TextStyle(
                      decoration:
                      isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? colors.onSurfaceVariant : null,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _checkedIngredients.add(index);
                      } else {
                        _checkedIngredients.remove(index);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sendMissingToShopping,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    missingCount > 0
                        ? context.tr(
                      'Masukkan $missingCount Bahan Kurang ke Belanja',
                      'Add $missingCount Missing Items to Shopping List',
                    )
                        : context.tr(
                      'Semua Bahan Sudah Siap',
                      'All Ingredients Ready',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('Langkah Memasak', 'Instructions'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...recipe.instructions.asMap().entries.map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          radius: 12,
                          child: Text('${e.key + 1}',
                              style: const TextStyle(fontSize: 12))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.value)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _InfoTile(
      {required this.icon,
        required this.label,
        required this.value,
        this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? colors.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}