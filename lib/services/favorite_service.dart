import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article_model.dart';

class FavoriteService {
  static const String boxName = 'favorites_box';

  /// Mendapatkan box Hive untuk favorites
  static Box get box => Hive.box(boxName);

  /// ValueListenable agar UI reaktif terhadap perubahan data
  static ValueListenable<Box> listenable() => box.listenable();

  /// Cek apakah item dengan id tertentu sudah difavoritkan
  static bool isFavorite(int id) {
    return box.containsKey(id.toString());
  }

  /// Toggle status favorit (tambah jika belum, hapus jika sudah)
  static Future<bool> toggleFavorite(ArticleModel article) async {
    final key = article.id.toString();
    if (box.containsKey(key)) {
      await box.delete(key);
      return false; // Sekarang tidak favorit
    } else {
      await box.put(key, article.toMap());
      return true; // Sekarang favorit
    }
  }

  /// Menghapus item dari favorit berdasarkan id
  static Future<void> removeFavorite(int id) async {
    await box.delete(id.toString());
  }

  /// Mengambil semua data favorit
  static List<ArticleModel> getAllFavorites() {
    final list = <ArticleModel>[];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        list.add(ArticleModel.fromMap(Map<dynamic, dynamic>.from(val)));
      }
    }
    return list;
  }
}
