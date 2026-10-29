import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

/// Exception khusus agar pesan error mudah ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Service yang bertanggung jawab atas semua permintaan HTTP ke API.
class RecipeService {
  static const String _host = 'dummyjson.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;
  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  /// GET https://dummyjson.com/recipes?limit=50
  /// atau GET https://dummyjson.com/recipes/search?q=<kata kunci>
  Future<List<Recipe>> fetchRecipes({String query = ''}) {
    final keyword = query.trim();
    final uri = keyword.isEmpty
        ? Uri.https(_host, '/recipes', {'limit': '50'})
        : Uri.https(_host, '/recipes/search', {'q': keyword, 'limit': '50'});

    return _guard(() async {
      final json = await _getJson(uri);
      final list = json['recipes'] as List<dynamic>;
      return list
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET https://dummyjson.com/recipes/{id}
  Future<Recipe> fetchRecipeById(int id) {
    final uri = Uri.https(_host, '/recipes/$id');
    return _guard(() async => Recipe.fromJson(await _getJson(uri)));
  }

  /// Mengirim request, memeriksa status code, lalu decode JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) {
      throw ApiException('Data tidak ditemukan (404).');
    }
    throw ApiException('Server bermasalah (kode ${response.statusCode}).');
  }

  /// Menerjemahkan berbagai jenis error menjadi pesan yang ramah pengguna.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server terlalu lama merespons.');
    } on http.ClientException {
      throw ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on FormatException {
      throw ApiException('Format data dari server tidak valid.');
    } catch (e) {
      throw ApiException('Terjadi kesalahan: $e');
    }
  }
}
