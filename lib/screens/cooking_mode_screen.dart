import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/language_service.dart';
import '../widgets/cooking_timer_card.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;
  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showIngredientsSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              LanguageService.tr('Daftar Bahan', 'Ingredients List'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.recipe.ingredients.map(
                  (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle,
                        size: 8, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: CookingTimerCard(
          cookTimeMinutes: widget.recipe.cookTimeMinutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe.instructions;
    final colors = Theme.of(context).colorScheme;
    final total = steps.isEmpty ? 1 : steps.length;
    final progress = (_currentStep + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: context.tr('Lihat Bahan', 'View Ingredients'),
            icon: const Icon(Icons.list_alt),
            onPressed: _showIngredientsSheet,
          ),
          IconButton(
            tooltip: context.tr('Buka Timer', 'Open Timer'),
            icon: const Icon(Icons.timer_outlined),
            onPressed: _showTimerSheet,
          ),
        ],
      ),
      body: steps.isEmpty
          ? Center(
        child: Text(
          context.tr(
            'Belum ada langkah memasak untuk resep ini.',
            'No cooking instructions available for this recipe.',
          ),
        ),
      )
          : Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    context.tr(
                      'Langkah ${_currentStep + 1} dari ${steps.length}',
                      'Step ${_currentStep + 1} of ${steps.length}',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: steps.length,
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Card(
                      elevation: 0,
                      color: colors.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                steps[index],
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentStep > 0
                        ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    )
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(context.tr('Sebelumnya', 'Previous')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (_currentStep < steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              LanguageService.tr(
                                'Selamat! ${widget.recipe.name} selesai dimasak.',
                                'Great job! ${widget.recipe.name} is ready to serve.',
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      _currentStep < steps.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      _currentStep < steps.length - 1
                          ? context.tr('Lanjut', 'Next')
                          : context.tr('Selesai!', 'Done!'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}