# Dapur Pintar 2.0

Aplikasi asisten dapur berbasis **Flutter & Dart** yang menggabungkan data dinamis dari **DummyJSON Recipes API** dengan fitur penyimpanan lokal, manajemen belanja, pencocok bahan kulkas, CRUD resep pribadi, dan sistem survei menu komunitas.

- **Live Demo (Hosting GitHub Pages / PWA):** https://fahmizaki45.github.io/dapur_pintar/
- **Repository:** https://github.com/fahmizaki45/dapur_pintar

## Fitur Utama

1. **Eksplor Resep (API + Komunitas)**
   - Menampilkan katalog resep responsif (Mobile & Web) dari DummyJSON Recipes API, digabung dengan resep hasil survei dan resep publik dari pengguna.
   - **Debounce Search (500ms):** Pencarian otomatis tanpa harus menekan Enter.
   - Filter kategori (*Semua, Favorit, Komunitas, Breakfast, Lunch, Dinner, Snack, Dessert*) serta pengurutan berdasarkan rating tertinggi atau waktu masak tercepat.
   - **Gacha Menu ("Bingung Masak?"):** Mengacak rekomendasi menu harian secara instan.
2. **Isi Kulkas (Pencocok Bahan Dwibahasa)**
   - Memilih atau mengetik bahan yang tersedia di dapur (mendukung input Bahasa Indonesia maupun Inggris).
   - Otomatis menghitung persentase kecocokan resep dan jumlah bahan yang masih kurang.
3. **Daftar Belanja Pintar (Smart Shopping List)**
   - Terintegrasi dengan checklist bahan di halaman detail: bahan yang belum dimiliki dapat langsung dikirim ke daftar belanja dalam satu ketukan.
   - Mendukung tambah item manual, centang selesai, hapus item dengan fitur **Batalkan (Undo)**, serta lencana (*badge*) jumlah belanjaan aktif di bilah navigasi.
4. **Resep Saya (CRUD Lokal + Persetujuan Publikasi)**
   - Membuat, mengedit, dan menghapus resep masakan pribadi secara permanen di penyimpanan lokal.
   - Dilengkapi saklar persetujuan **Publikasikan ke Eksplor** agar pembuat resep dapat memilih apakah resepnya bersifat privat atau tampil di halaman Eksplor.
5. **Survei & Usul Menu User**
   - Pengguna dapat memberikan suara (*vote*) atau mengusulkan menu baru. Menu yang mencapai target **5 suara** otomatis tayang di halaman Eksplor.
6. **Detail Resep, Timer Memasak, & Mode Fokus**
   - Checklist bahan interaktif (*strikethrough*), timer memasak dengan kontrol Mulai/Jeda/Reset/+1 Menit, serta **Mode Memasak Fokus** layar penuh per langkah (*Step-by-Step*).
7. **Personalisasi UI/UX & Aksesibilitas**
   - **Dark Mode & Light Mode** tersimpan otomatis.
   - **Multi-Bahasa (ID / EN):** Mengubah bahasa antarmuka sekaligus menerjemahkan nama bahan secara otomatis.
   - **Penanganan Kondisi Data:** Tampilan *Loading*, *Empty*, *Error* beserta tombol *Coba Lagi*, serta *fallback* gambar (mendukung URL langsung, Google Drive, dan Base64).

## Teknologi & Package

- **Framework:** Flutter (Material 3)
- **Bahasa:** Dart
- **API:** [DummyJSON Recipes API](https://dummyjson.com/docs/recipes)
- **Package:**
  - `http` — Permintaan HTTP GET ke API dan penanganan status/timeout.
  - `shared_preferences` — Penyimpanan lokal untuk tema, bahasa, favorit, daftar belanja, resep pribadi, dan data survei.
- **Hosting:** GitHub Pages (Flutter Web / Progressive Web App)

## Struktur Folder

```text
lib/
├── main.dart
├── models/
│   └── recipe.dart
├── services/
│   ├── recipe_service.dart
│   ├── favorite_service.dart
│   ├── theme_service.dart
│   ├── language_service.dart
│   ├── ingredient_translator.dart
│   ├── shopping_service.dart
│   ├── my_recipe_service.dart
│   └── survey_service.dart
├── screens/
│   ├── main_shell.dart
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   ├── cooking_mode_screen.dart
│   ├── fridge_screen.dart
│   ├── shopping_screen.dart
│   ├── my_recipes_screen.dart
│   ├── survey_screen.dart
│   └── cooking_mode_screen.dart
└── widgets/
    ├── recipe_card.dart
    ├── cooking_timer_card.dart
    └── state_views.dart
test/
└── recipe_test.dart
```

## Cara Menjalankan Aplikasi

1. Clone repositori ini:
   ```bash
   git clone [https://github.com/fahmizaki45/dapur_pintar.git](https://github.com/fahmizaki45/dapur_pintar.git)
   cd dapur_pintar
   ```
2. Pasang seluruh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan pengujian otomatis:
   ```bash
   flutter analyze
   flutter test
   ```
4. Jalankan di Emulator Android atau Browser Chrome:
   ```bash
   flutter run
   # atau untuk versi web:
   flutter run -d chrome
   ```

## Identitas Pengembang

- **Nama:** Fahmi Zaki Darmawan
- **NIM:** 240605110239
- **Jurusan:** Teknik Informatika — Fakultas Sains dan Teknologi, UIN Maulana Malik Ibrahim Malang
