import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// 1. DATA MODEL
// ==========================================
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

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
class CartState {
  final List<Product> items;
  CartState({required this.items});

  int get totalItems => items.length;
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  void addProduct(Product product) {
    final updatedList = List<Product>.from(state.items)..add(product);
    emit(CartState(items: updatedList));
  }

  void removeProduct(Product product) {
    final updatedList = List<Product>.from(state.items);
    if (updatedList.contains(product)) {
      updatedList.remove(product);
      emit(CartState(items: updatedList));
    }
  }
}

// ==========================================
// 3. TEMA & WARNA
// ==========================================
class AppColors {
  static const Color primary = Color(0xFF1C6B42); // Hijau (Lush)
  static const Color primaryContainer = Color(0xFF86D3A0);

  // Elemen Ungu (Lavender)
  static const Color secondary = Color(0xFF674BB5); // Ungu gelap
  static const Color secondaryContainer = Color(0xFFE8DDFF); // Ungu terang

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
    return BlocProvider(
      create: (context) => CartCubit(),
      child: MaterialApp(
        title: 'Lush & Lavender',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Plus Jakarta Sans',
        ),
        home: const ProductListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ==========================================
// 5. TAMPILAN UTAMA (PRODUCT LIST SCREEN)
// ==========================================
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                return IconButton(
                  icon: Badge(
                    label: Text('${state.totalItems}'),
                    isLabelVisible: state.totalItems > 0,
                    // Menggunakan warna ungu untuk badge keranjang
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.white,
                    child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 28),
                  ),
                  onPressed: () {
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
              // Product List (Kategori Chip sudah dihilangkan)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
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

  // Widget Bantuan: Product Card (Foto sudah dihilangkan)
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
            color: AppColors.secondary.withValues(alpha: 0.05), // Sedikit bayangan ungu
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info Produk mengambil ruang penuh di sebelah kiri
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

          // Tombol Kuantitas
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

                // Angka / Kuantitas
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
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

                // Tombol Tambah (+) dengan Warna Ungu (Lavender)
                GestureDetector(
                  onTap: () => context.read<CartCubit>().addProduct(product),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer, // Background Ungu Terang
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.secondary, size: 20), // Ikon Ungu Gelap
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
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Keranjang kosong.'));
          }
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final product = state.items[index];
              return ListTile(
                // Ikon produk di keranjang disesuaikan dengan warna ungu
                leading: const Icon(Icons.shopping_bag, color: AppColors.secondary),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
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