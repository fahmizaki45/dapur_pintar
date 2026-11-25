import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/language_service.dart';
import '../services/my_recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  Future<void> _openForm(BuildContext context, {Recipe? existing}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RecipeFormScreen(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LanguageService.tr('Hapus Resep?', 'Delete Recipe?')),
        content: Text(
          LanguageService.tr(
            'Resep "${recipe.name}" akan dihapus permanen.',
            'Recipe "${recipe.name}" will be permanently deleted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(LanguageService.tr('Batal', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LanguageService.tr('Hapus', 'Delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MyRecipeService.deleteRecipe(recipe.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LanguageService.tr(
                'Resep "${recipe.name}" berhasil dihapus',
                'Recipe "${recipe.name}" deleted',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final minLabel = context.tr('mnt', 'min');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('Resep Saya', 'My Recipes'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          LanguageToggleButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(context.tr('Buat Resep', 'New Recipe')),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          MyRecipeService.recipes,
          MyRecipeService.publishedIds,
        ]),
        builder: (context, _) {
          final recipes = MyRecipeService.recipes.value;
          if (recipes.isEmpty) {
            return EmptyView(
              message: context.tr(
                'Kamu belum punya resep pribadi.\nTekan "Buat Resep" untuk menyimpan kreasi masakanmu sendiri!',
                'You have no personal recipes yet.\nTap "New Recipe" to save your own creations!',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final isPublic = MyRecipeService.isPublished(recipe.id);

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(recipe: recipe),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        height: 108,
                        child: NetworkImageBox(url: recipe.image),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe.cuisine} • ${recipe.totalTimeMinutes} $minLabel • ${recipe.difficulty}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPublic
                                      ? colors.primaryContainer
                                      : colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isPublic
                                      ? context.tr(
                                    'Publik • Tayang di Eksplor',
                                    'Public • Shown in Explore',
                                  )
                                      : context.tr(
                                    'Privat • Hanya di Resep Saya',
                                    'Private • My Recipes Only',
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isPublic
                                        ? colors.onPrimaryContainer
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: context.tr('Edit', 'Edit'),
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _openForm(context, existing: recipe),
                          ),
                          IconButton(
                            tooltip: context.tr('Hapus', 'Delete'),
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(context, recipe),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeFormScreen extends StatefulWidget {
  final Recipe? existing;
  const _RecipeFormScreen({this.existing});

  @override
  State<_RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<_RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _cuisineCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _cookCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _instructionsCtrl;

  String _difficulty = 'Easy';
  String _mealType = 'Lunch';
  bool _publishToExplore = false;

  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _mealOptions = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _cuisineCtrl = TextEditingController(text: r?.cuisine ?? 'Indonesia');
    _prepCtrl = TextEditingController(text: '${r?.prepTimeMinutes ?? 10}');
    _cookCtrl = TextEditingController(text: '${r?.cookTimeMinutes ?? 15}');
    _servingsCtrl = TextEditingController(text: '${r?.servings ?? 2}');
    _caloriesCtrl =
        TextEditingController(text: '${r?.caloriesPerServing ?? 350}');
    _imageCtrl = TextEditingController(text: r?.image ?? '');
    _ingredientsCtrl =
        TextEditingController(text: r?.ingredients.join('\n') ?? '');
    _instructionsCtrl =
        TextEditingController(text: r?.instructions.join('\n') ?? '');

    if (r != null) {
      if (_difficulties.contains(r.difficulty)) _difficulty = r.difficulty;
      if (r.mealType.isNotEmpty) _mealType = r.mealType.first;
      _publishToExplore = MyRecipeService.isPublished(r.id);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cuisineCtrl.dispose();
    _prepCtrl.dispose();
    _cookCtrl.dispose();
    _servingsCtrl.dispose();
    _caloriesCtrl.dispose();
    _imageCtrl.dispose();
    _ingredientsCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = _ingredientsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final instructions = _instructionsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final id = widget.existing?.id ?? -DateTime.now().millisecondsSinceEpoch;

    await MyRecipeService.saveRecipeMap(
      {
        'id': id,
        'name': _nameCtrl.text.trim(),
        'cuisine': _cuisineCtrl.text.trim().isEmpty
            ? 'Indonesia'
            : _cuisineCtrl.text.trim(),
        'prepTimeMinutes': int.tryParse(_prepCtrl.text.trim()) ?? 10,
        'cookTimeMinutes': int.tryParse(_cookCtrl.text.trim()) ?? 15,
        'servings': int.tryParse(_servingsCtrl.text.trim()) ?? 1,
        'caloriesPerServing': int.tryParse(_caloriesCtrl.text.trim()) ?? 0,
        'difficulty': _difficulty,
        'mealType': [_mealType],
        'tags': ['ResepPribadi', _cuisineCtrl.text.trim()],
        'image': _imageCtrl.text.trim(),
        'rating': 5.0,
        'reviewCount': 1,
        'ingredients': ingredients,
        'instructions': instructions,
      },
      publishToExplore: _publishToExplore,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _publishToExplore
              ? LanguageService.tr(
            'Resep disimpan & langsung tayang di Eksplor!',
            'Recipe saved & published to Explore!',
          )
              : LanguageService.tr(
            'Resep disimpan secara privat di Resep Saya.',
            'Recipe saved privately to My Recipes.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? context.tr('Edit Resep', 'Edit Recipe')
              : context.tr('Buat Resep Baru', 'Create New Recipe'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: context.tr('Nama Masakan *', 'Recipe Name *'),
                hintText: context.tr(
                  'Contoh: Nasi Goreng Kosan',
                  'e.g., Homemade Fried Rice',
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr('Nama wajib diisi', 'Name is required')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cuisineCtrl,
              decoration: InputDecoration(
                labelText: context.tr('Asal Masakan', 'Cuisine'),
                hintText: context.tr(
                  'Contoh: Indonesia, Jawa, Sunda',
                  'e.g., Indonesian, Italian, Asian',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Tingkat Kesulitan', 'Difficulty Level'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _difficulties
                  .map(
                    (d) => ChoiceChip(
                  label: Text(d),
                  selected: _difficulty == d,
                  onSelected: (_) => setState(() => _difficulty = d),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('Jenis Hidangan', 'Meal Type'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _mealOptions
                  .map(
                    (m) => ChoiceChip(
                  label: Text(m),
                  selected: _mealType == m,
                  onSelected: (_) => setState(() => _mealType = m),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                      context.tr('Persiapan (mnt)', 'Prep Time (min)'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cookCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.tr('Masak (mnt)', 'Cook Time (min)'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.tr('Porsi', 'Servings'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                      context.tr('Kalori / porsi', 'Calories / serving'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageCtrl,
              decoration: InputDecoration(
                labelText:
                context.tr('URL Foto (Opsional)', 'Image URL (Optional)'),
                hintText: 'https://...',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.tr(
                  'Bahan-bahan * (1 baris = 1 bahan)',
                  'Ingredients * (1 line = 1 item)',
                ),
                hintText: context.tr(
                  '2 piring nasi putih\n2 butir telur\n3 siung bawang putih',
                  '2 cups cooked rice\n2 eggs\n3 cloves garlic',
                ),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr(
                'Minimal isi satu bahan',
                'Enter at least one ingredient',
              )
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructionsCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.tr(
                  'Langkah Memasak * (1 baris = 1 langkah)',
                  'Cooking Steps * (1 line = 1 step)',
                ),
                hintText: context.tr(
                  'Tumis bawang putih hingga harum\nMasukkan telur lalu orak-arik\nTambahkan nasi dan kecap, aduk rata',
                  'Saute garlic until fragrant\nScramble the eggs in the pan\nAdd rice and soy sauce, stir well',
                ),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr(
                'Minimal isi satu langkah',
                'Enter at least one step',
              )
                  : null,
            ),
            const SizedBox(height: 16),

            // PERSETUJUAN PEMBUAT RESEP UNTUK PUBLIKASI KE EKSPLOR
            Card(
              elevation: 0,
              color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
              child: SwitchListTile(
                value: _publishToExplore,
                onChanged: (val) => setState(() => _publishToExplore = val),
                secondary: Icon(
                  _publishToExplore ? Icons.public : Icons.lock_outline,
                  color: _publishToExplore ? colors.primary : null,
                ),
                title: Text(
                  context.tr(
                    'Publikasikan ke Halaman Eksplor',
                    'Publish to Explore Page',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  context.tr(
                    'Saya setuju resep buatan saya ini ditampilkan di tab Eksplor.',
                    'I agree to share this recipe publicly on the Explore tab.',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                isEdit
                    ? context.tr('Simpan Perubahan', 'Save Changes')
                    : context.tr('Simpan Resep', 'Save Recipe'),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}