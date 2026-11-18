import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

/// Halaman List Data (Menampilkan daftar News, Blogs, atau Reports).
/// Memenuhi ketentuan soal:
/// 1. "Wajib menampilkan judul dari data"
/// 2. "Wajib menampilkan gambar sebagai leading (thumbnail) & memberikan exception handling apabila gambarnya tidak muncul"
/// 3. "Wajib memunculkan author dari data"
/// 4. "Fitur Filter berupa chip untuk memfilter list data berdasarkan author dari tiap data"
class ListScreen extends StatefulWidget {
  final String endpoint; // Endpoint API: 'articles', 'blogs', atau 'reports'
  final String title;    // Judul AppBar: 'News', 'Blogs', atau 'Reports'

  const ListScreen({
    super.key,
    required this.endpoint,
    required this.title,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // Menyimpan semua data asli dari API
  List<ArticleModel> _allArticles = [];
  // Menyimpan data hasil filter yang ditampilkan ke UI
  List<ArticleModel> _filteredArticles = [];
  // Daftar semua author unik untuk dijadikan pilihan FilterChip
  List<String> _authorList = [];
  // Author yang sedang aktif dipilih (default: 'All' / Semua)
  String _selectedAuthor = 'All';

  // State untuk mengontrol UI loading dan penanganan error
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Memanggil API saat pertama kali halaman dibuka
    _fetchData();
  }

  /// Fungsi untuk mengambil data dari REST API via ApiService
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Ambil data mentah (JSON List) dari API
      final rawList = await ApiService.getDataList(widget.endpoint);

      // 2. Mapping JSON ke List of ArticleModel
      final List<ArticleModel> loaded = rawList
          .map((item) => ArticleModel.fromMap(item, category: widget.endpoint))
          .toList();

      // 3. Kumpulkan semua nama author secara unik menggunakan Set
      final Set<String> uniqueAuthors = {};
      for (var a in loaded) {
        final author = a.authorFormatted.trim();
        if (author.isNotEmpty) {
          uniqueAuthors.add(author);
        }
      }

      final sortedAuthors = uniqueAuthors.toList()..sort();

      // 4. Update state tampilan
      setState(() {
        _allArticles = loaded;
        _authorList = ['All', ...sortedAuthors]; // 'All' di posisi pertama
        _selectedAuthor = 'All';
        _filteredArticles = loaded;
        _isLoading = false;
      });
    } catch (e) {
      // Jika request API gagal (misal tidak ada koneksi internet)
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Fungsi saat salah satu FilterChip diklik oleh pengguna
  void _onFilterSelected(String author) {
    setState(() {
      _selectedAuthor = author;
      if (author == 'All') {
        // Tampilkan semua data jika memilih 'All'
        _filteredArticles = _allArticles;
      } else {
        // Filter data yang nama author-nya cocok dengan pilihan
        _filteredArticles = _allArticles
            .where((item) => item.authorFormatted == author)
            .toList();
      }
    });
  }

  /// Widget untuk menampilkan deretan FilterChip author secara horizontal
  Widget _buildFilterChips() {
    if (_authorList.length <= 1) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  'Filter berdasarkan Author / Sumber (${_filteredArticles.length} data):',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Deretan FilterChip yang dapat digeser menyamping (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _authorList.map((author) {
                final isSelected = _selectedAuthor == author;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(author),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade700,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue.shade800 : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => _onFilterSelected(author),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget thumbnail gambar lengkap dengan EXCEPTION HANDLING
  /// Wajib sesuai soal: "memberikan exception handling apabila gambarnya tidak muncul"
  Widget _buildThumbnail(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          // errorBuilder dipanggil ketika URL gambar error/rusak/404
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey.shade600, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    'No Image',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 9),
                  ),
                ],
              ),
            );
          },
          // loadingBuilder menampilkan animasi loading saat gambar sedang didownload
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child; // Gambar sudah selesai dimuat
            return Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          // Tampilkan progress indicator saat data sedang diambil
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              // Tampilkan pesan error jika request API gagal
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Bagian FilterChip
                    _buildFilterChips(),

                    // Bagian Daftar List Data
                    Expanded(
                      child: _filteredArticles.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada data untuk author "$_selectedAuthor"',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchData, // Fitur tarik ke bawah untuk refresh
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: _filteredArticles.length,
                                itemBuilder: (context, index) {
                                  final article = _filteredArticles[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      // Navigasi ke Halaman Detail saat kartu diklik
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(
                                              article: article,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1. Gambar leading dengan exception handling
                                            _buildThumbnail(article.imageUrl),
                                            const SizedBox(width: 12),

                                            // 2. Kolom informasi: Judul, Author, dan Tanggal
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Wajib: Menampilkan Judul
                                                  Text(
                                                    article.title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),

                                                  // Wajib: Menampilkan Author / Sumber
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 14,
                                                        color: Colors
                                                            .blue.shade700,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          article
                                                              .authorFormatted,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey.shade700,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // Tanggal publikasi terformat rapi
                                                  Text(
                                                    article
                                                        .publishedAtFormatted,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Ikon navigasi ke kanan
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.black26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
