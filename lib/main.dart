import 'package:flutter/material.dart';
// Mengimpor library flutter_bloc untuk mengimplementasikan pola arsitektur BLoC/Cubit
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  // Titik awal aplikasi berjalan
  runApp(const MyApp());
}

// ==========================================
// 1. DATA MODEL
// ==========================================
// Kelas ini merepresentasikan struktur data untuk sebuah produk.
class Product {
  final String id;
  final String name;
  final double price;

  // Constructor membutuhkan id, nama, dan harga saat objek dibuat.
  Product({required this.id, required this.name, required this.price});
}

// Daftar statis (dummy data) yang berisi 5 produk awal untuk ditampilkan di layar.
final List<Product> productList = [
  Product(id: '1', name: 'Laptop Pro', price: 15000000),
  Product(id: '2', name: 'Smartphone X', price: 8000000),
  Product(id: '3', name: 'Headphone Nirkabel', price: 1200000),
  Product(id: '4', name: 'Smartwatch V2', price: 2500000),
  Product(id: '5', name: 'Keyboard Mekanik', price: 950000),
];

// ==========================================
// 2. STATE & CUBIT (STATE MANAGEMENT)
// ==========================================
// CartState bertugas untuk menyimpan kondisi (state) dari keranjang belanja pada waktu tertentu.
class CartState {
  // Menyimpan daftar produk yang saat ini ada di dalam keranjang.
  final List<Product> items;
  
  CartState({required this.items});

  // Getter bantu (computed property) untuk mendapatkan jumlah total barang di keranjang.
  int get totalItems => items.length;
}

// CartCubit adalah pengelola state (logic layer).
// Kelas ini mengatur kapan state keranjang harus berubah (ditambah/dikurangi).
class CartCubit extends Cubit<CartState> {
  // Nilai awal (initial state) adalah keranjang kosong (List kosong []).
  CartCubit() : super(CartState(items: []));

  // Fungsi untuk menambahkan produk ke dalam keranjang
  void addProduct(Product product) {
    // Membuat salinan (copy) dari daftar item yang sudah ada, kemudian menambahkan produk baru.
    // Kita tidak boleh memodifikasi state secara langsung (mutability), harus membuat objek list baru.
    final updatedList = List<Product>.from(state.items)..add(product);
    
    // emit() akan mengirimkan state baru ini ke UI (Widget) agar UI me-render ulang (re-build).
    emit(CartState(items: updatedList));
  }

  // Fungsi untuk menghapus satu produk dari keranjang
  void removeProduct(Product product) {
    final updatedList = List<Product>.from(state.items);
    
    // Mengecek apakah produk tersebut benar-benar ada di dalam list sebelum mencoba menghapusnya.
    if (updatedList.contains(product)) {
      // Menghapus 1 instance pertama dari produk tersebut yang ditemukan di list.
      updatedList.remove(product);
      
      // Mengirim state terbaru ke UI.
      emit(CartState(items: updatedList));
    }
  }
}

// ==========================================
// 3. TEMA & WARNA
// ==========================================
// Kelas ini bertindak sebagai palet warna terpusat agar desain UI tetap konsisten dan mudah diubah.
class AppColors {
  static const Color primary = Color(0xFF1C6B42); 
  static const Color primaryContainer = Color(0xFF86D3A0);

  static const Color secondary = Color(0xFF674BB5);
  static const Color secondaryContainer = Color(0xFFE8DDFF); 

  static const Color background = Color(0xFFFBF8FF);
  static const Color surfaceLowest = Colors.white;
  static const Color surfaceLow = Color(0xFFF4F2FD);
  static const Color onSurface = Color(0xFF1A1B22);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
}

// ==========================================
// 4. MAIN APP
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider diletakkan di akar (root) aplikasi agar instance CartCubit
    // dapat diakses oleh seluruh widget (halaman) di bawahnya.
    return BlocProvider(
      create: (context) => CartCubit(),
      child: MaterialApp(
        title: 'Lush & Lavender',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Plus Jakarta Sans', // Menggunakan kustom font jika sudah didaftarkan
        ),
        home: const ProductListScreen(),
        // Menyembunyikan pita "DEBUG" di pojok kanan atas
        debugShowCheckedModeBanner: false, 
      ),
    );
  }
}

// ==========================================
// 5. TAMPILAN UTAMA (PRODUCT LIST SCREEN)
// ==========================================
// Halaman ini menampilkan katalog produk yang bisa ditambahkan ke keranjang.
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Penggunaan withValues(alpha: ...) adalah cara terbaru (Material 3) untuk mengatur opacity warna.
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Daftar Produk',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // BlocBuilder di sini akan mendengarkan perubahan CartState.
            // Saat item di keranjang berubah, HANYA bagian ikon keranjang ini yang akan dire-render, bukan seluruh layar.
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                return IconButton(
                  // Badge digunakan untuk menampilkan angka di atas ikon.
                  icon: Badge(
                    label: Text('${state.totalItems}'),
                    // Badge hanya akan terlihat jika ada minimal 1 barang di keranjang.
                    isLabelVisible: state.totalItems > 0,
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 28),
                  ),
                  onPressed: () {
                    // Berpindah ke halaman Detail Keranjang saat ikon diklik.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartDetailScreen()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ListView.builder efisien karena hanya me-render widget yang terlihat di layar.
              ListView.builder(
                shrinkWrap: true, // Membiarkan ListView mengambil tinggi sesuai kontennya.
                physics: const NeverScrollableScrollPhysics(), // Scroll dinonaktifkan karena sudah di-wrap SingleChildScrollView.
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  // Memanggil fungsi terpisah untuk merender kartu (card) produk agar kode lebih rapi.
                  return _buildProductCard(context, product);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi bantuan (helper widget) untuk menyusun tampilan UI untuk setiap produk tunggal.
  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Expanded memastikan teks mengambil seluruh ruang yang tersisa, mendorong tombol ke kanan.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // Menampilkan harga dengan format 0 angka desimal di belakang koma.
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Kontainer untuk tombol tambah/kurang kuantitas
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Kurang (-)
                GestureDetector(
                  // context.read() digunakan di dalam fungsi event (onTap) untuk memanggil 
                  // fungsi tanpa perlu membuat widget mendengarkan (listen) perubahan state terus-menerus.
                  onTap: () => context.read<CartCubit>().removeProduct(product),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove, color: AppColors.error, size: 20),
                  ),
                ),

                // Bagian yang menampilkan berapa banyak produk INI yang ada di keranjang.
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    // Melakukan perulangan/filter untuk menghitung seberapa banyak ID produk ini muncul di dalam list keranjang.
                    int count = state.items.where((p) => p.id == product.id).length;
                    return SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                ),

                // Tombol Tambah (+)
                GestureDetector(
                  // Memanggil fungsi addProduct di dalam CartCubit
                  onTap: () => context.read<CartCubit>().addProduct(product),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.secondary, size: 20),
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

// ==========================================
// 6. HALAMAN DETAIL KERANJANG
// ==========================================
// Halaman ini secara khusus merender list produk apa saja yang sudah berhasil dimasukkan ke keranjang.
class CartDetailScreen extends StatelessWidget {
  const CartDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keranjang', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      // BlocBuilder menyelimuti seluruh isi body, karena halaman ini akan berubah drastis 
      // tergantung isi state keranjang (kosong atau berisi).
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          // Menampilkan pesan jika keranjang belum memiliki item
          if (state.items.isEmpty) {
            return const Center(child: Text('Keranjang kosong.'));
          }
          
          // Jika ada item, render list produk tersebut menggunakan ListView.
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final product = state.items[index];
              return ListTile(
                leading: const Icon(Icons.shopping_bag, color: AppColors.secondary),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                // Tombol hapus dari dalam halaman keranjang.
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => context.read<CartCubit>().removeProduct(product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
