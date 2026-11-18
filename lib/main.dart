import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';

/// Entry point utama aplikasi Flutter.
/// Diberi keyword `async` karena kita perlu membaca SharedPreferences dan
/// menginisialisasi database Hive sebelum tampilan UI pertama kali digambar.
void main() async {
  // Wajib dipanggil jika ada operasi asynchronous (seperti SharedPreferences/Hive)
  // di dalam fungsi main() sebelum `runApp()`. Mencegah error binding Flutter.
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive (Local Database)
  // Hive.initFlutter() menyiapkan direktori internal perangkat untuk menyimpan database.
  await Hive.initFlutter();
  // Membuka box penyimpanan untuk data favorit agar siap dibaca/ditulis kapan saja.
  await Hive.openBox(FavoriteService.boxName);

  // 2. Cek status sesi login (Sesuai ketentuan soal: auto-login jika belum logout)
  // Membaca nilai dari SharedPreferences melalui AuthService.
  final isLoggedIn = await AuthService.isLoggedIn();
  final currentUser = await AuthService.getCurrentUser();

  // 3. Menjalankan aplikasi
  // Jika sudah login dan username ada, langsung ke MainMenuScreen.
  // Jika belum login, arahkan ke LoginScreen.
  runApp(MyApp(
    initialScreen: (isLoggedIn && currentUser != null)
        ? MainMenuScreen(username: currentUser)
        : const LoginScreen(),
  ));
}

/// Root widget aplikasi.
/// Mengatur konfigurasi global seperti Tema (ThemeData), judul, dan halaman awal (home).
class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceflight News Portal',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di pojok kanan atas
      theme: ThemeData(
        // Pengaturan warna tema utama aplikasi (Biru solid)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        // Gaya default untuk semua AppBar di aplikasi agar seragam
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      home: initialScreen, // Menampilkan halaman yang ditentukan dari pengecekan sesi di main()
    );
  }
}
