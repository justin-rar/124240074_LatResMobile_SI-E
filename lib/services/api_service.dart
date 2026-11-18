import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service yang menangani seluruh komunikasi jaringan (HTTP Request) ke REST API.
/// Mengacu pada Modul V (HTTP Request):
/// - Menggunakan package `http`
/// - Menggunakan fungsi `jsonDecode` dari `dart:convert`
/// - Mengembalikan data bertipe `Future` dengan penanganan `async/await` dan `try-catch`.
class ApiService {
  // Base URL sesuai dokumentasi API Spaceflight News v4
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  /// Mengambil daftar data (List) berdasarkan endpoint yang dipilih.
  /// Parameter `endpoint` bisa bernilai:
  /// - 'articles' untuk News
  /// - 'blogs' untuk Blogs
  /// - 'reports' untuk Reports
  /// Ditambahkan query `?limit=50` agar mendapatkan jumlah data yang cukup untuk ditampilkan dan difilter.
  static Future<List<dynamic>> getDataList(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint/?limit=50');
    try {
      // Melakukan HTTP GET request ke server
      final response = await http.get(uri);

      // Mengecek apakah respons berhasil (Status code 200 OK)
      if (response.statusCode == 200) {
        // Mengubah string JSON dari server menjadi Map Dart
        final decoded = jsonDecode(response.body);
        // Pada API v4, daftar item berada di dalam key 'results'
        return decoded['results'] ?? [];
      } else {
        // Jika server merespons selain 200 (misal 404 atau 500)
        throw Exception(
          'Gagal memuat data ($endpoint): Status ${response.statusCode}',
        );
      }
    } catch (e) {
      // Menangkap error koneksi (misal offline atau timeout)
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// Mengambil detail satu data berdasarkan endpoint dan id item.
  /// Contoh URL: https://api.spaceflightnewsapi.net/v4/articles/123/
  static Future<Map<String, dynamic>> getDataDetail(
    String endpoint,
    int id,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        throw Exception(
          'Gagal memuat detail data ($id): Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi detail: $e');
    }
  }
}
