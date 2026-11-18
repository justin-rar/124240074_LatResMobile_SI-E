import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyCurrentUser = 'currentUser';
  static const String _userPrefix = 'user_pwd_';

  /// Mendaftarkan user baru ke SharedPreferences.
  /// Return true jika berhasil, false jika username sudah digunakan.
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userPrefix$username';
    if (prefs.containsKey(key)) {
      return false; // User sudah ada
    }
    await prefs.setString(key, password);
    return true;
  }

  /// Memvalidasi username & password, lalu menyimpan status login.
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userPrefix$username';
    final savedPassword = prefs.getString(key);

    if (savedPassword != null && savedPassword == password) {
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyCurrentUser, username);
      return true;
    }
    return false;
  }

  /// Mengecek apakah user sedang dalam kondisi login.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Mengambil username user yang sedang login.
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUser);
  }

  /// Menghapus sesi login.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyCurrentUser);
  }
}

