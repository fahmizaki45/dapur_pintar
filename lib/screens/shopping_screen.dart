import 'package:flutter/material.dart';

import '../services/ingredient_translator.dart';
import '../services/language_service.dart';
import '../services/shopping_services.dart';
import '../widgets/state_views.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addManual() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ShoppingService.addItem(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEn = context.isEn;

    return ValueListenableBuilder<List<ShoppingItem>>(
      valueListenable: ShoppingService.items,
      builder: (context, items, _) {
        final boughtCount = items.where((e) => e.isBought).length;
        final pendingCount = items.length - boughtCount;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr('Daftar Belanja', 'Shopping List'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              const LanguageToggleButton(),
              if (boughtCount > 0)
                TextButton.icon(
                  onPressed: ShoppingService.clearBought,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: Text(
                    context.tr(
                      'Hapus ($boughtCount)',
                      'Clear ($boughtCount)',
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addManual(),
                        decoration: InputDecoration(
                          hintText: context.tr(
                            'Tambah belanjaan (contoh: Bawang putih)...',
                            'Add grocery item (e.g., Garlic)...',
                          ),
                          prefixIcon: const Icon(Icons.add_shopping_cart),
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
                      onPressed: _addManual,
                      icon: const Icon(Icons.add),
                      tooltip: context.tr('Tambah item', 'Add item'),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        context.tr(
                          '$pendingCount belum dibeli • $boughtCount selesai',
                          '$pendingCount to buy • $boughtCount done',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? EmptyView(
                  message: context.tr(
                    'Daftar belanja masih kosong.\nTambahkan manual di atas atau kirim bahan kurang dari halaman detail resep.',
                    'Your shopping list is empty.\nAdd items above or send missing ingredients from a recipe.',
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final displayName = IngredientTranslator.translate(
                      item.name,
                      isEnglish: isEn,
                    );

                    return Card(
                      elevation: 0,
                      color: item.isBought
                          ? colors.surfaceContainerHighest
                          .withValues(alpha: 0.45)
                          : colors.surfaceContainerLow,
                      child: CheckboxListTile(
                        value: item.isBought,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          displayName,
                          style: TextStyle(
                            decoration: item.isBought
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isBought
                                ? colors.onSurfaceVariant
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${context.tr('Sumber', 'Source')}: ${item.sourceRecipe}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        secondary: IconButton(
                          tooltip: context.tr('Hapus', 'Delete'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ShoppingService.removeItem(item.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  LanguageService.tr(
                                    '$displayName dihapus',
                                    '$displayName removed',
                                  ),
                                ),
                                action: SnackBarAction(
                                  label: LanguageService.tr(
                                      'BATALKAN', 'UNDO'),
                                  onPressed: () =>
                                      ShoppingService.addItem(
                                        item.name,
                                        sourceRecipe: item.sourceRecipe,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                        onChanged: (_) =>
                            ShoppingService.toggleBought(item.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}