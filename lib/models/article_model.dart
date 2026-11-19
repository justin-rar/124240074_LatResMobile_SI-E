import 'package:intl/intl.dart';

/// Model data untuk menampung informasi News (Articles), Blogs, maupun Reports
/// dari Spaceflight News API v4.
///
/// Menggunakan model class memudahkan kita dalam memanipulasi data
/// karena tipe data sudah pasti (type-safe) dan mencegah typo key JSON.
class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final List<String> authors;
  final String category; // 'articles', 'blogs', atau 'reports'

  ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.authors,
    this.category = 'articles',
  });

  /// Getter untuk memformat nama Author/Sumber berita.
  /// Pada API Spaceflight News:
  /// - Kadang field 'authors' berupa List of Object [{'name': '...'}]
  /// - Kadang field 'authors' kosong [], tetapi ada field 'news_site' (misal NASA, SpaceNews).
  /// Getter ini memastikan aplikasi selalu memiliki nama author/sumber yang valid.
  String get authorFormatted {
    if (authors.isNotEmpty) {
      final names = authors.where((a) => a.trim().isNotEmpty).join(', ');
      if (names.isNotEmpty) return names;
    }
    if (newsSite.trim().isNotEmpty) {
      return newsSite;
    }
    return 'Unknown Author';
  }

  /// Getter untuk memformat tanggal ISO 8601 (misal "2026-11-16T05:05:00Z")
  /// menjadi format tanggal yang rapi dan mudah dibaca (misal "16 November 2026, 12:05").
  String get publishedAtFormatted {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm').format(dt);
    } catch (_) {
      // Jika parsing gagal, kembalikan string aslinya
      return publishedAt;
    }
  }

  /// Factory constructor untuk membuat objek ArticleModel dari Map / JSON (Deserialization).
  /// Digunakan saat menerima data dari API (HTTP Response) maupun saat membaca dari database Hive.
  factory ArticleModel.fromMap(
    Map<dynamic, dynamic> map, {
    String category = 'articles',
  }) {
    List<String> parsedAuthors = [];
    // Parsing daftar author jika ada
    if (map['authors'] != null && map['authors'] is List) {
      for (var a in map['authors']) {
        if (a is Map && a['name'] != null) {
          parsedAuthors.add(a['name'].toString());
        } else if (a is String) {
          parsedAuthors.add(a);
        }
      }
    }

    return ArticleModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title']?.toString() ?? 'No Title',
      url: map['url']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      newsSite: map['news_site']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      publishedAt: map['published_at']?.toString() ?? '',
      authors: parsedAuthors,
      category: map['category']?.toString() ?? category,
    );
  }

  /// Mengubah objek ArticleModel menjadi `Map<String, dynamic>` (Serialization).
  /// Berguna saat kita ingin menyimpan data ke dalam database lokal Hive.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'authors': authors,
      'category': category,
    };
  }
}

// Model User untuk autentikasi.
class User {
  String username;
  String password;

  User({required this.username, required this.password});
}

// Data contoh user (tidak dipakai di alur utama, hanya referensi login).
User user1 = User(username: 'justin', password: '074');

// Nama pelanggan yang tampil di halaman Profil.
const String customerName = 'Justin Muhammad Rasyid';
