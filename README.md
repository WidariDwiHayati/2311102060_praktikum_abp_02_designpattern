# Flutter Cart App 🛒🌿

Aplikasi e-commerce sederhana (keranjang belanja) yang dibangun menggunakan **Flutter** dengan mengimplementasikan **Cubit** (dari ekosistem BLoC) sebagai *state management*.

## ✨ Fitur Utama

* **Daftar Produk:** Menampilkan daftar produk beserta nama dan harganya secara statis.
* **Manajemen Keranjang (Real-time):** Pengguna dapat menambah (`+`) dan mengurangi (`-`) produk langsung dari halaman utama.
* **Indikator Jumlah (Badge):** Menampilkan jumlah total item yang ada di dalam keranjang secara *real-time* di bagian `AppBar`.
* **Detail Keranjang:** Halaman khusus untuk melihat seluruh item yang sudah dimasukkan ke dalam keranjang belanja. Pengguna juga dapat menghapus item dari halaman ini.

## 🛠️ Teknologi yang Digunakan

* **Framework:** [Flutter](https://flutter.dev/)
* **Bahasa:** Dart
* **State Management:** `flutter_bloc` (Cubit)

## 📦 Arsitektur State Management

Aplikasi ini menggunakan pendekatan **Cubit** untuk menjaga state UI tetap tersinkronisasi tanpa memerlukan boilerplate yang terlalu panjang:

* **`CartState`**: Menyimpan daftar `Product` yang saat ini ada di dalam keranjang dan memiliki *getter* `totalItems` untuk menghitung jumlah barang.
* **`CartCubit`**: Mengandung logika bisnis. Menyediakan metode `addProduct()` dan `removeProduct()` yang akan memanipulasi *list* produk dan memanggil `emit()` untuk memperbarui UI.
* **`BlocProvider` & `BlocBuilder`**: Digunakan untuk menyuntikkan Cubit ke pohon widget dan membangun ulang bagian UI tertentu saja saat terjadi perubahan data.
