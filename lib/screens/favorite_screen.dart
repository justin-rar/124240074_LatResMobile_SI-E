import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/article_model.dart';
import '../services/favorite_service.dart';
import 'detail_screen.dart';

/// Halaman Daftar Favorit (Favourite Screen).
/// Memenuhi ketentuan soal nomor 4 (Fitur Favourite):
/// 1. "Halaman yang berisi data-data yang difavoritkan oleh user, terlepas itu news, blog, ataupun report."
/// 2. "Semua data yang dinyatakan sebagai favourite tercantum di halaman ini."
/// 3. "List data favourite terupdate terlepas dilakukannya perubahan di halaman favourite maupun dari halaman detil."
///
/// Kunci utama reaktivitas di sini adalah penggunaan `ValueListenableBuilder` (Modul VI),
/// yang memantau perubahan data pada Box Hive secara real-time tanpa perlu me-reload manual.
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  /// Widget helper untuk thumbnail gambar dengan exception handling
  Widget _buildThumbnail(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Tampilan jika gambar gagal dimuat
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Daftar Favorit'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      // ValueListenableBuilder: Listener reaktif ke box Hive 'favorites_box'
      // Setiap kali ada penambahan atau penghapusan data di Hive (baik dari sini atau DetailScreen),
      // builder ini akan otomatis dipanggil ulang (rebuild).
      body: ValueListenableBuilder<Box>(
        valueListenable: FavoriteService.listenable(),
        builder: (context, Box box, child) {
          // Ambil semua daftar item yang sedang ada di dalam box
          final List<ArticleModel> favorites = FavoriteService.getAllFavorites();

          // 1. Tampilan jika belum ada data favorit sama sekali (Empty State)
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.pink.shade200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Data Favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua news, blog, atau report yang Anda favoritkan dari halaman detail akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 2. Tampilan daftar item favorit yang tersimpan
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final article = favorites[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  // Klik kartu untuk membuka detail artikel
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(article: article),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail gambar
                        _buildThumbnail(article.imageUrl),
                        const SizedBox(width: 12),

                        // Informasi data favorit: Kategori, Judul, Author
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge Kategori (ARTICLES / BLOGS / REPORTS)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  article.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Judul data favorit
                              Text(
                                article.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Author / Sumber
                              Text(
                                'Oleh: ${article.authorFormatted}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Hapus dari Favorit langsung dari halaman ini
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: 'Hapus dari Favorit',
                          onPressed: () async {
                            // Hapus item dari Hive berdasarkan ID
                            await FavoriteService.removeFavorite(article.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dihapus dari daftar Favorit'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
