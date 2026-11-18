import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article_model.dart';

/// Service untuk mengelola data artikel/blog/report yang difavoritkan pengguna.
/// Mengacu pada Modul VI (Local Storage - Hive Database):
/// - Hive adalah database NoSQL lokal yang sangat cepat, ringan, dan reaktif.
/// - Data disimpan di dalam "Box" (serupa tabel/koleksi).
/// - Menggunakan `box.listenable()` sehingga UI yang memakai `ValueListenableBuilder`
///   akan OTOMATIS ter-update begitu ada item yang ditambah atau dihapus.
/// - Memenuhi ketentuan soal:
///   "List data favourite terupdate terlepas dilakukannya perubahan di halaman favourite
///   maupun dari halaman detil (tidak harus dari salah satunya)"
class FavoriteService {
  // Nama box Hive untuk menyimpan data favorit
  static const String boxName = 'favorites_box';

  /// Mendapatkan instance box Hive yang sudah dibuka sebelumnya di `main.dart`.
  static Box get box => Hive.box(boxName);

  /// Mengembalikan `ValueListenable` dari box Hive.
  /// Digunakan oleh widget `ValueListenableBuilder` di `DetailScreen` dan `FavoriteScreen`
  /// agar tampilan dapat langsung merespons perubahan data secara real-time.
  static ValueListenable<Box> listenable() => box.listenable();

  /// Mengecek apakah item dengan ID tertentu sudah ada di daftar favorit.
  /// Kompleksitas O(1) karena menggunakan pencarian Key di Hive.
  static bool isFavorite(int id) {
    return box.containsKey(id.toString());
  }

  /// Menambahkan artikel ke favorit jika belum ada, atau menghapusnya jika sudah ada (Toggle).
  /// Mengembalikan:
  /// - `true` jika item berhasil ditambahkan ke favorit.
  /// - `false` jika item dihapus dari favorit.
  static Future<bool> toggleFavorite(ArticleModel article) async {
    final key = article.id.toString();
    if (box.containsKey(key)) {
      // Jika sudah ada di favorit, hapus dari box
      await box.delete(key);
      return false; // Status sekarang: Tidak favorit
    } else {
      // Jika belum ada, simpan data artikel dalam bentuk Map (JSON)
      await box.put(key, article.toMap());
      return true; // Status sekarang: Favorit
    }
  }

  /// Menghapus item tertentu dari box favorit berdasarkan ID.
  static Future<void> removeFavorite(int id) async {
    await box.delete(id.toString());
  }

  /// Mengambil semua data favorit yang tersimpan di dalam box Hive.
  /// Data dikonversi kembali dari Map menjadi List of ArticleModel.
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
