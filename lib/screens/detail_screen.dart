import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../services/favorite_service.dart';

/// Halaman Detail Informasi (News/Blog/Report).
/// Memenuhi ketentuan soal:
/// 1. "Wajib menampilkan gambar (lengkap dengan exception handling)"
/// 2. "Wajib menampilkan judul data"
/// 3. "Wajib menampilkan author data"
/// 4. "Wajib menampilkan tanggal publish"
/// 5. "Wajib menampilkan summary data"
/// 6. "Terdapat tombol yang akan mengarahkan (launch url) ke situs resmi dari berita"
/// 7. "Terdapat tombol untuk menambahkan data sebagai favourite yang nantinya akan muncul di list favourite"
class DetailScreen extends StatelessWidget {
  final ArticleModel article;

  const DetailScreen({super.key, required this.article});

  /// Fungsi untuk membuka tautan situs web resmi menggunakan package `url_launcher`.
  /// Menggunakan mode `LaunchMode.externalApplication` agar dibuka di browser bawaan perangkat (Chrome/Safari).
  Future<void> _openOfficialWebsite(BuildContext context) async {
    final urlStr = article.url.trim();

    // Validasi URL tidak kosong
    if (urlStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL situs resmi tidak tersedia.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.parse(urlStr);
    try {
      // Membuka URL di browser eksternal
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // Jika gagal meluncurkan URL
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan situs resmi.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Menangani error exception jika URL tidak valid
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka URL: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Informasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Tombol toggle favorit di AppBar yang REAKTIF menggunakan ValueListenableBuilder (Modul VI)
          ValueListenableBuilder(
            valueListenable: FavoriteService.listenable(),
            builder: (context, box, child) {
              // Cek apakah item ini sudah difavoritkan
              final isFav = FavoriteService.isFavorite(article.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () async {
                  // Toggle status favorit di Hive
                  final added = await FavoriteService.toggleFavorite(article);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? 'Ditambahkan ke daftar Favorit'
                              : 'Dihapus dari daftar Favorit',
                        ),
                        backgroundColor:
                            added ? Colors.green : Colors.grey.shade800,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar utama dengan Exception Handling (errorBuilder)
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                // Exception handling jika gambar gagal dimuat
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gambar tidak dapat dimuat',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                // Animasi loading saat proses download gambar
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori (ARTICLES / BLOGS / REPORTS)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Wajib: Menampilkan Judul Data
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kartu Info: Author dan Tanggal Publikasi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // 3. Wajib: Menampilkan Author Data
                        Row(
                          children: [
                            Icon(
                              Icons.person_pin,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Author / Sumber: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                article.authorFormatted,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),

                        // 4. Wajib: Menampilkan Tanggal Publish Data
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tanggal Rilis: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                article.publishedAtFormatted,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Wajib: Menampilkan Summary / Ringkasan Data
                  const Text(
                    'Ringkasan Berita',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary.isNotEmpty
                        ? article.summary
                        : 'Tidak ada ringkasan yang tersedia untuk informasi ini.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 6. Wajib: Tombol untuk Menambahkan/Menghapus Data sebagai Favourite
                  // Dibuat reaktif dengan ValueListenableBuilder (Hive)
                  ValueListenableBuilder(
                    valueListenable: FavoriteService.listenable(),
                    builder: (context, box, child) {
                      final isFav = FavoriteService.isFavorite(article.id);
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey.shade700,
                          ),
                          label: Text(
                            isFav
                                ? 'HAPUS DARI FAVORIT'
                                : 'TAMBAHKAN KE FAVORIT',
                            style: TextStyle(
                              color:
                                  isFav ? Colors.red : Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isFav
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final added =
                                await FavoriteService.toggleFavorite(article);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    added
                                        ? 'Ditambahkan ke daftar Favorit'
                                        : 'Dihapus dari daftar Favorit',
                                  ),
                                  backgroundColor: added
                                      ? Colors.green
                                      : Colors.grey.shade800,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 7. Wajib: Tombol Launch URL untuk Mengarahkan ke Situs Resmi Berita
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text(
                        'BACA SITUS RESMI LENGKAP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _openOfficialWebsite(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
