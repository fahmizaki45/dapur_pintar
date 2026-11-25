import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/favorite_service.dart';
import 'services/language_service.dart';
import 'services/my_recipe_service.dart';
import 'services/shopping_services.dart';
import 'services/survey_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadTheme();
  await LanguageService.loadLanguage();
  await FavoriteService.loadFavorites();
  await ShoppingService.loadItems();
  await MyRecipeService.loadMyRecipes();
  await SurveyService.loadSurvey();
  runApp(const DapurPintarApp());
}

class DapurPintarApp extends StatelessWidget {
  const DapurPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      notifier: LanguageService.language,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeService.themeMode,
        builder: (context, currentMode, _) {
          return MaterialApp(
            title: 'Dapur Pintar',
            debugShowCheckedModeBanner: false,
            themeMode: currentMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFFFBF8),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.dark,
              ),
            ),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}