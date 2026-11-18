import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  /// Mengambil daftar artikel/blog/report berdasarkan endpoint (articles, blogs, reports).
  static Future<List<dynamic>> getDataList(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint/?limit=50');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['results'] ?? [];
      } else {
        throw Exception(
          'Gagal memuat data ($endpoint): Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// Mengambil data detail berdasarkan endpoint dan id.
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

