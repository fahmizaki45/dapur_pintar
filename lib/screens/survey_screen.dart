import 'package:flutter/material.dart';

import '../services/language_service.dart';
import '../services/survey_service.dart';
import 'detail_screen.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  void _openProposalForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ProposeMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final minLabel = context.tr('mnt', 'min');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('Survei & Usul Menu', 'Menu Survey & Requests'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          LanguageToggleButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProposalForm(context),
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(context.tr('Usulkan Menu', 'Propose Menu')),
      ),
      body: ValueListenableBuilder<List<SurveyMenuItem>>(
        valueListenable: SurveyService.items,
        builder: (context, items, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              Card(
                elevation: 0,
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.poll_outlined,
                          size: 32, color: colors.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr(
                            'Bantu tentukan menu baru di Eksplor! Menu yang mencapai ${SurveyMenuItem.approvalThreshold} suara otomatis tayang di halaman Eksplor.',
                            'Help pick new Explore menus! Any dish reaching ${SurveyMenuItem.approvalThreshold} votes is automatically added to Explore.',
                          ),
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...items.map((item) {
                final recipe = item.recipe;
                final progress =
                (item.votes / SurveyMenuItem.approvalThreshold)
                    .clamp(0.0, 1.0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                  const SizedBox(height: 2),
                                  Text(
                                    '${context.tr('Dari', 'From')}: ${item.proposedBy}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.isApproved)
                              Chip(
                                avatar: const Icon(Icons.check_circle,
                                    size: 16, color: Colors.green),
                                label: Text(
                                  context.tr('Di Eksplor', 'In Explore'),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr(
                                '${item.votes} / ${SurveyMenuItem.approvalThreshold} suara',
                                '${item.votes} / ${SurveyMenuItem.approvalThreshold} votes',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                              ),
                            ),
                            Text(
                              item.isApproved
                                  ? context.tr('Target tercapai!', 'Goal reached!')
                                  : context.tr(
                                'Butuh ${SurveyMenuItem.approvalThreshold - item.votes} suara lagi',
                                '${SurveyMenuItem.approvalThreshold - item.votes} more needed',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: item.hasVoted
                                  ? OutlinedButton.icon(
                                onPressed: () =>
                                    SurveyService.toggleVote(item.id),
                                icon: const Icon(Icons.thumb_up),
                                label: Text(
                                  context.tr('Sudah Dukung', 'Voted'),
                                ),
                              )
                                  : FilledButton.icon(
                                onPressed: () async {
                                  final approved =
                                  await SurveyService.toggleVote(
                                      item.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        approved
                                            ? LanguageService.tr(
                                          '"${recipe.name}" resmi masuk ke halaman Eksplor!',
                                          '"${recipe.name}" is now live on Explore!',
                                        )
                                            : LanguageService.tr(
                                          'Terima kasih! Suara untuk "${recipe.name}" tercatat.',
                                          'Thanks! Your vote for "${recipe.name}" is counted.',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.thumb_up_outlined),
                                label: Text(
                                  context.tr('Dukung Menu', 'Vote Menu'),
                                ),
                              ),
                            ),
                            if (item.isApproved) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(recipe: recipe),
                                  ),
                                ),
                                child: Text(context.tr('Lihat', 'Open')),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ProposeMenuScreen extends StatefulWidget {
  const _ProposeMenuScreen();

  @override
  State<_ProposeMenuScreen> createState() => _ProposeMenuScreenState();
}

class _ProposeMenuScreenState extends State<_ProposeMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController(text: 'Indonesia');
  final _cookCtrl = TextEditingController(text: '20');
  final _ingredientsCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  String _difficulty = 'Easy';
  String _mealType = 'Lunch';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cuisineCtrl.dispose();
    _cookCtrl.dispose();
    _ingredientsCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await SurveyService.proposeMenu(
      name: _nameCtrl.text.trim(),
      cuisine: _cuisineCtrl.text.trim(),
      mealType: _mealType,
      difficulty: _difficulty,
      cookTimeMinutes: int.tryParse(_cookCtrl.text.trim()) ?? 20,
      ingredients: _ingredientsCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      instructions: _instructionsCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LanguageService.tr(
            'Usulan menu masuk ke daftar survei!',
            'Your menu proposal has been added to the survey!',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Usulkan Menu Baru', 'Propose New Menu')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: context.tr('Nama Menu *', 'Menu Name *'),
                hintText: context.tr('Contoh: Rawon Malang', 'e.g., Beef Rawon'),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr('Wajib diisi', 'Required')
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cuisineCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr('Asal Masakan', 'Cuisine'),
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
                      labelText: context.tr('Waktu (mnt)', 'Time (min)'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Easy', 'Medium', 'Hard']
                  .map(
                    (d) => ChoiceChip(
                  label: Text(d),
                  selected: _difficulty == d,
                  onSelected: (_) => setState(() => _difficulty = d),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert']
                  .map(
                    (m) => ChoiceChip(
                  label: Text(m),
                  selected: _mealType == m,
                  onSelected: (_) => setState(() => _mealType = m),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr(
                  'Bahan Utama * (1 baris = 1 bahan)',
                  'Ingredients * (1 line = 1 item)',
                ),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr('Isi minimal 1 bahan', 'Add at least 1 item')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructionsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr(
                  'Langkah Singkat * (1 baris = 1 langkah)',
                  'Short Steps * (1 line = 1 step)',
                ),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? LanguageService.tr('Isi minimal 1 langkah', 'Add at least 1 step')
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_outlined),
              label: Text(context.tr('Kirim Usulan ke Survei', 'Submit Proposal')),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}