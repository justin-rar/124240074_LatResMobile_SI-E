import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Halaman Registrasi Pengguna Baru.
/// Memfasilitasi pendaftaran akun (username dan password) yang nantinya
/// disimpan di database lokal SharedPreferences.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk membaca input teks dari TextField
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Status loading tombol saat proses simpan berlangsung
  bool _isLoading = false;

  /// Helper untuk menampilkan notifikasi error berwarna MERAH sesuai ketentuan soal
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Fungsi logika saat tombol 'Daftar' ditekan
  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Validasi: Semua field harus diisi
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Semua kolom wajib diisi');
      return;
    }

    // 2. Validasi: Password dan Konfirmasi Password harus sama persis
    if (password != confirmPassword) {
      _showErrorSnackBar('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    // 3. Simpan data user baru ke SharedPreferences melalui AuthService
    final success = await AuthService.register(username, password);

    setState(() => _isLoading = false);

    // 4. Tangani hasil registrasi
    if (success && mounted) {
      // Tampilkan notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Kembali ke halaman Login (pop stack navigasi)
      Navigator.pop(context);
    } else if (mounted) {
      // Jika username sudah pernah terdaftar sebelumnya
      _showErrorSnackBar('Username "$username" sudah terdaftar');
    }
  }

  @override
  void dispose() {
    // Bersihkan semua controller saat widget dihapus dari memori
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Akun'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Field Input Username Baru
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Field Input Password Baru
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Field Konfirmasi Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Submit Pendaftaran
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
