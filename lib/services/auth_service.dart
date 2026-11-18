import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola autentikasi akun dan status sesi pengguna.
/// Mengacu pada Modul VI (Local Storage - SharedPreferences):
/// - Digunakan untuk menyimpan data sederhana berbasis Key-Value di memori internal perangkat.
/// - Memenuhi ketentuan soal:
///   1. "Login menggunakan akun yang telah diregister terlebih dahulu"
///   2. "Login tersimpan di sharedPreferences sehingga jika dikeluarkan tanpa logout user masih dapat masuk ke aplikasi kembali"
class AuthService {
  // Kunci-kunci (keys) yang digunakan untuk menyimpan data di SharedPreferences
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyCurrentUser = 'currentUser';
  static const String _userPrefix = 'user_pwd_';

  /// Mendaftarkan user baru ke SharedPreferences.
  /// Password disimpan dengan key unik berdasarkan username: `'user_pwd_<username>'`.
  /// Mengembalikan:
  /// - `true` jika registrasi berhasil
  /// - `false` jika username sudah pernah terdaftar sebelumnya
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userPrefix$username';

    // Cek apakah username sudah ada di database lokal
    if (prefs.containsKey(key)) {
      return false; // Registrasi gagal karena username duplikat
    }

    // Simpan password untuk username tersebut
    await prefs.setString(key, password);
    return true; // Berhasil didaftarkan
  }

  /// Memvalidasi username dan password pengguna saat login.
  /// Jika cocok:
  /// - Status `isLoggedIn` diubah menjadi `true`
  /// - Nama user yang aktif disimpan di `currentUser`
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userPrefix$username';
    final savedPassword = prefs.getString(key);

    // Cek apakah user ada dan password yang diinputkan sesuai
    if (savedPassword != null && savedPassword == password) {
      // Simpan session agar saat aplikasi dibuka kembali tidak perlu login lagi
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyCurrentUser, username);
      return true; // Login sukses
    }
    return false; // Login gagal
  }

  /// Mengecek apakah user saat ini sedang login.
  /// Digunakan pada file `main.dart` untuk menentukan halaman awal aplikasi.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika null (belum pernah login), default ke false
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Mengambil nama username yang sedang login saat ini.
  /// Digunakan untuk menampilkan sapaan "Halo, username!" di AppBar halaman utama.
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUser);
  }

  /// Menghapus sesi login saat user menekan tombol logout.
  /// Status login diset `false` dan username aktif dihapus.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
  }
}
