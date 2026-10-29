import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';

/// Halaman detail. Data lengkap diambil lewat request kedua: GET /recipes/{id}.
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
    _future = _service.fetchRecipeById(widget.recipe.id);
  }

  void _retry() {
    setState(() => _future = _service.fetchRecipeById(widget.recipe.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.name)),
      body: FutureBuilder<Recipe>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Memuat detail resep...');
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

class _DetailContent extends StatelessWidget {
  final Recipe recipe;
  const _DetailContent({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Text('${recipe.rating} (${recipe.reviewCount} ulasan)'),
                  const SizedBox(width: 12),
                  Text(recipe.cuisine,
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoTile(
                      icon: Icons.timer_outlined,
                      label: 'Waktu',
                      value: '${recipe.totalTimeMinutes} mnt'),
                  _InfoTile(
                      icon: Icons.people_outline,
                      label: 'Porsi',
                      value: '${recipe.servings}'),
                  _InfoTile(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Kalori',
                      value: '${recipe.caloriesPerServing}'),
                  _InfoTile(
                      icon: Icons.speed,
                      label: 'Level',
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
                        backgroundColor: Colors.grey.shade200,
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Text('Bahan-bahan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...recipe.ingredients.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Langkah Memasak', style: theme.textTheme.titleMedium),
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
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
