# Dapur Pintar 🍳

Aplikasi pencari resep masakan berbasis Flutter yang mengambil data dari **DummyJSON Recipes API**.
Dibuat untuk UTS Pemrograman Mobile.

## Deskripsi
Dapur Pintar membantu pengguna menemukan ide masakan lengkap dengan bahan, langkah memasak,
waktu, tingkat kesulitan, kalori, dan rating. Seluruh data bersifat dinamis dari API.

## Fitur Utama
- Daftar resep dalam tampilan grid responsif (gambar, rating, waktu, tingkat kesulitan)
- Pencarian resep berdasarkan kata kunci (endpoint `/recipes/search`)
- Filter jenis hidangan (Breakfast, Lunch, Dinner, Snack, Dessert)
- Pengurutan berdasarkan rating tertinggi / waktu tercepat
- Halaman detail resep (bahan, langkah, kalori, porsi, tag)
- Penanganan kondisi **loading, success, error** dengan `FutureBuilder` + tombol coba lagi
- Pull-to-refresh

## Teknologi
- Flutter (Material 3) & Dart
- Package `http` untuk permintaan HTTP
- API: `https://dummyjson.com/recipes`

## Struktur Folder
```
lib/
├── main.dart
├── models/recipe.dart
├── services/recipe_service.dart
├── screens/home_screen.dart
├── screens/detail_screen.dart
└── widgets/ (recipe_card.dart, state_views.dart)
test/recipe_test.dart
```

## Cara Menjalankan
1. Pasang Flutter SDK (>= 3.27) dan pastikan `flutter doctor` tidak ada error.
2. `git clone https://github.com/USERNAME/dapur_pintar.git`
3. `cd dapur_pintar`
4. `flutter pub get`
5. `flutter run` (pilih perangkat: emulator Android / Chrome)
6. Pengujian unit: `flutter test`
7. Build APK: `flutter build apk --release`

## Demo Web
https://USERNAME.github.io/dapur_pintar/
