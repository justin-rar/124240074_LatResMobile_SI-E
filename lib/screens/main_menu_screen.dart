import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'list_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

/// Halaman Menu Utama (Dashboard) Aplikasi.
/// Memenuhi ketentuan soal:
/// 1. "Halaman Utama terdiri dari 3 menu/tombol yang apabila diklik maka akan diarahkan ke halaman kedua
///    yang menampilkan list data report, news atau blog, sesuai dengan menu yang dipilih"
/// 2. "AppBar menampilkan username yang digunakan untuk Login"
/// 3. "Terdapat tombol logout di bawah pilihan yang tersedia"
class MainMenuScreen extends StatelessWidget {
  // Menerima username user yang berhasil login
  final String username;
  const MainMenuScreen({super.key, required this.username});

  /// Fungsi untuk menangani proses Logout.
  /// Menampilkan dialog konfirmasi sebelum mengeluarkan pengguna.
  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Tutup dialog tanpa logout
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true), // Konfirmasi logout
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // Jika user menekan tombol 'Logout' di dialog
    if (shouldLogout == true) {
      // 1. Hapus session di SharedPreferences
      await AuthService.logout();

      // 2. Arahkan kembali ke LoginScreen dan hapus semua riwayat halaman sebelumnya (stack)
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // false berarti semua route di bawahnya dihancurkan
        );
      }
    }
  }

  /// Helper widget untuk membuat kartu menu agar kode rapi dan tidak berulang (reusable).
  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap, // Aksi ketika kartu menu diklik
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              // Kotak ikon menu
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 16),

              // Teks Judul & Deskripsi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Indikator panah ke kanan
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        // Wajib menampilkan username yang login sesuai soal
        title: Text('Halo, $username!'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Tombol jalan pintas ke Halaman Favorit di AppBar
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Halaman Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
          // Tombol jalan pintas Logout di AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Sambutan (Warna solid biru, tanpa gradasi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spaceflight News Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih kategori informasi luar angkasa yang ingin Anda jelajahi:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Menu News (Endpoint: articles)
            _buildMenuCard(
              context: context,
              title: 'News (Articles)',
              subtitle: 'Berita terbaru seputar eksplorasi dan misi luar angkasa',
              icon: Icons.newspaper,
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      endpoint: 'articles',
                      title: 'News',
                    ),
                  ),
                );
              },
            ),

            // 2. Menu Blogs (Endpoint: blogs)
            _buildMenuCard(
              context: context,
              title: 'Blogs',
              subtitle: 'Artikel blog dan opini dari komunitas antariksa',
              icon: Icons.article_outlined,
              color: Colors.teal.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      endpoint: 'blogs',
                      title: 'Blogs',
                    ),
                  ),
                );
              },
            ),

            // 3. Menu Reports (Endpoint: reports)
            _buildMenuCard(
              context: context,
              title: 'Reports',
              subtitle: 'Laporan resmi stasiun luar angkasa dan badan antariksa',
              icon: Icons.assessment_outlined,
              color: Colors.deepOrange.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      endpoint: 'reports',
                      title: 'Reports',
                    ),
                  ),
                );
              },
            ),

            // 4. Menu Favourite (Koleksi gabungan yang difavoritkan)
            _buildMenuCard(
              context: context,
              title: 'Favourite',
              subtitle: 'Kumpulan artikel, blog, dan report yang telah difavoritkan',
              icon: Icons.favorite,
              color: Colors.pink.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Tombol Logout di bawah pilihan menu (Wajib sesuai ketentuan soal nomor 2)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'LOGOUT',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _logout(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
