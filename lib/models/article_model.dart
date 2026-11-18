import 'package:intl/intl.dart';

class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final List<String> authors;
  final String category; // 'articles', 'blogs', or 'reports'

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

  /// Mengambil nama author atau fallback ke newsSite
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

  /// Format tanggal publikasi yang mudah dibaca
  String get publishedAtFormatted {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return publishedAt;
    }
  }

  factory ArticleModel.fromMap(Map<dynamic, dynamic> map, {String category = 'articles'}) {
    List<String> parsedAuthors = [];
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
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
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

