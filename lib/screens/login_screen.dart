import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/auth_service.dart';
import 'main_menu_screen.dart';

//import 'register_screen.dart';

/// Halaman Login Pengguna.
/// Menggunakan `StatefulWidget` karena terdapat state lokal:
/// - Nilai controller input text
/// - Status loading saat tombol login ditekan
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk membaca input teks dari form TextField
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variabel untuk menampilkan indikator loading saat proses validasi
  bool _isLoading = false;

  /// Helper untuk menampilkan pesan error menggunakan SnackBar berwarna MERAH.
  /// Memenuhi ketentuan soal: "Jika error memunculkan snackbar error berwarna merah".
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor:
            Colors.red, // Wajib merah sesuai instruksi modul & soal
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fungsi logika saat tombol Login ditekan
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi input: Cek apakah field kosong
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Username dan password tidak boleh kosong');
      return;
    }

    // Aktifkan status loading
    setState(() => _isLoading = true);

    // 2. Memeriksa kecocokan data ke SharedPreferences melalui AuthService
    final success = await AuthService.login(username, password);

    // Nonaktifkan status loading setelah proses async selesai
    setState(() => _isLoading = false);

    // 3. Tangani hasil login
    if (success && mounted) {
      // Tampilkan notifikasi berhasil (opsional hijau)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, $username!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Pindah ke Halaman Utama.
      // Menggunakan `pushReplacement` agar halaman Login digantikan dan
      // user tidak bisa kembali (Back) ke halaman Login tanpa menekan tombol Logout.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen(username: username),
        ),
      );
    } else if (mounted) {
      // Jika username/password salah, munculkan SnackBar error berwarna merah
      _showErrorSnackBar('Login gagal: Username atau password salah');
    }
  }

  @override
  void dispose() {
    // Selalu dispose TextEditingController untuk mencegah kebocoran memori (memory leak)
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Field Input Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Border kotak standar modul
                ),
              ),
              const SizedBox(height: 16),

              // Field Input Password (obscureText: true untuk menyembunyikan karakter)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Navigasi menuju halaman Register jika belum memiliki akun
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text('Belum punya akun? '),
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => const RegisterScreen(),
              //           ),
              //         );
              //       },
              //       child: Text(
              //         'Daftar di sini',
              //         style: TextStyle(
              //           color: Theme.of(context).colorScheme.primary,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
