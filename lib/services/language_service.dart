import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const _key = 'app_language';

  /// Nilai yang didukung: 'id' (Indonesia) atau 'en' (English)
  static final ValueNotifier<String> language = ValueNotifier('id');

  static bool get isEnglish => language.value == 'en';

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    language.value = (saved == 'en') ? 'en' : 'id';
  }

  static Future<void> toggleLanguage() async {
    final next = isEnglish ? 'id' : 'en';
    language.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next);
  }

  /// Dipakai di dalam callback (onPressed, validator, SnackBar, dialog).
  static String tr(String id, String en) => isEnglish ? en : id;
}

class LanguageScope extends InheritedNotifier<ValueNotifier<String>> {
  const LanguageScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}

extension LangContextExt on BuildContext {
  /// Dipakai di dalam method build() agar tampilan otomatis berubah saat bahasa diganti.
  String tr(String id, String en) {
    final scope = dependOnInheritedWidgetOfExactType<LanguageScope>();
    final code = scope?.notifier?.value ?? LanguageService.language.value;
    return code == 'en' ? en : id;
  }

  bool get isEn {
    final scope = dependOnInheritedWidgetOfExactType<LanguageScope>();
    final code = scope?.notifier?.value ?? LanguageService.language.value;
    return code == 'en';
  }
}

/// Tombol praktis ID / EN untuk ditaruh di AppBar.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;
    return Tooltip(
      message: isEn ? 'Ganti ke Bahasa Indonesia' : 'Switch to English',
      child: TextButton.icon(
        onPressed: LanguageService.toggleLanguage,
        icon: const Icon(Icons.translate, size: 18),
        label: Text(
          isEn ? 'EN' : 'ID',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}