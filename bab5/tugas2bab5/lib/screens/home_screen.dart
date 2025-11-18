import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:hmti_news/screens/detail_screen.dart'; // enum DetailResult & DetailScreen (id required)
import 'package:hmti_news/screens/edit_profile_screen.dart';
import 'package:hmti_news/screens/create_news_screen.dart';

// Tambahkan import AuthService
import 'package:hmti_news/services/auth_service.dart';

/// =====================
/// Konfigurasi dasar API
/// =====================
const String kApiBase = 'https://hppms-sabala.my.id/api/';

/// Normalisasi URL gambar dari API yang kadang salah (mis. "http:https://" atau double slash)
String normalizeImageUrl(String raw) {
  if (raw.isEmpty) return '';
  var s = raw.trim();

  if (s.startsWith('http:https://')) s = s.substring('http:'.length);
  if (s.startsWith('https:https://')) s = s.substring('https:'.length);
  if (s.startsWith('//')) s = 'https:$s';
  s = s.replaceAll(RegExp(r'\s+'), '');

  Uri? u = Uri.tryParse(s);
  if (u == null) return s;

  final scheme = (u.scheme.isEmpty) ? 'https' : u.scheme;

  var path = u.path;
  if (path.startsWith('/api/storage/')) {
    path = path.replaceFirst('/api/', '/');
  }
  path = path.replaceAll(RegExp(r'//+'), '/');

  u = u.replace(scheme: scheme, path: path);
  return u.toString();
}

/// Tambahkan query `v=...` untuk memaksa refresh cache saat updated_at berubah
String withCacheBuster(String url, [String? hint]) {
  if (url.isEmpty) return url;
  final u = Uri.parse(url);
  final buster = (hint == null || hint.isEmpty)
      ? DateTime.now().millisecondsSinceEpoch.toString()
      : hint;
  final q = Map<String, String>.from(u.queryParameters)..putIfAbsent('v', () => buster);
  return u.replace(queryParameters: q).toString();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _loggingOut = false;

  /// Ambil berita dari /api/news
  Future<List<Map<String, dynamic>>> fetchNews() async {
    final url = Uri.parse(kApiBase).resolve('news');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      // ignore: avoid_print
      print('Failed to load news with status: ${response.statusCode}');
      throw Exception('Failed to load news');
    }

    try {
      final dynamic decoded = json.decode(response.body);

      // ===== DEBUG (matikan setelah beres) =====
      // ignore: avoid_print
      print('decoded runtimeType: ${decoded.runtimeType}');
      if (decoded is Map) {
        // ignore: avoid_print
        print('top-level keys: ${decoded.keys.toList()}');
      }

      // Respons kamu kemungkinan Map dengan array di key seperti data/items/news/posts/results.
      final List<dynamic> rows = _extractFirstList(decoded);

      if (rows.isEmpty) {
        throw Exception(
          'Tidak menemukan array berita di respons. Pastikan ada List pada salah satu key: data/items/news/posts/results',
        );
      }

      return rows.map<Map<String, dynamic>>((dynamic item) {
        if (item is! Map) return <String, dynamic>{};
        final map = item as Map<String, dynamic>;

        // Ambil ID
        final rawId = map['id'];
        final int? id = switch (rawId) {
          int v => v,
          String v => int.tryParse(v),
          _ => null,
        };

        // Gambar & waktu
        final rawImage = (map['image_url'] ?? map['image'] ?? map['thumbnail'] ?? '').toString();
        final updated   = map['updated_at']?.toString() ?? map['updatedAt']?.toString();

        final imgUrl = withCacheBuster(
          normalizeImageUrl(rawImage),
          updated,
        );

        return {
          'id'         : id,
          'imageUrl'   : imgUrl,
          'title'      : map['title']?.toString()    ?? 'No Title',
          'author'     : map['author']?.toString()   ?? 'Unknown',
          'description': map['description']?.toString()  // sesuai contoh respons create
              ?? map['content']?.toString()
              ?? map['body']?.toString()
              ?? 'No Description',
          'time'       : updated ?? 'Unknown',
        };
      }).where((e) => e.isNotEmpty && e['id'] != null).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing data: $e');
      throw Exception('Failed to parse news data');
    }
  }

  /// Cari List pertama di dalam struktur JSON, rekursif.
  List<dynamic> _extractFirstList(dynamic node) {
    if (node is List) return node;
    if (node is Map) {
      const preferredKeys = ['data', 'items', 'news', 'posts', 'results'];
      for (final k in preferredKeys) {
        if (node.containsKey(k)) {
          final res = _extractFirstList(node[k]);
          if (res.isNotEmpty) return res;
        }
      }
      for (final v in node.values) {
        final res = _extractFirstList(v);
        if (res.isNotEmpty) return res;
      }
    }
    return const [];
  }

  Future<void> _openCreateNews() async {
    final created = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => const CreateNewsScreen()),
    );

    // Jika ada data baru kembali dari CreateNewsScreen → refresh list
    if (created != null && mounted) {
      setState(() {}); // trigger FutureBuilder to refetch
      // Opsional: tampilkan snackbar ringkas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita baru ditambahkan')),
      );
    }
  }

  // =========================
  // Logout helpers
  // =========================
  Future<void> _confirmLogout() async {
    if (_loggingOut) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _doLogout();
    }
  }

  Future<void> _doLogout() async {
    setState(() => _loggingOut = true);
    try {
      await AuthService.logout(); // hapus token dari storage & cache
      if (!mounted) return;
      // Arahkan ke login dan bersihkan history
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchNews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final news = snapshot.data ?? const <Map<String, dynamic>>[];
            if (news.isEmpty) return const Center(child: Text('No News Available'));
            return _HomeNewsList(
              news: news,
              onOpen: (item) async {
                final result = await Navigator.push<DetailResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      id: (item['id'] as int),
                      title: (item['title'] as String?) ?? '-',
                      description: (item['description'] as String?) ?? '-',
                      imageUrl: (item['imageUrl'] as String?) ?? '',
                    ),
                  ),
                );

                if (result == DetailResult.deleted || result == DetailResult.updated) {
                  if (context.mounted) setState(() {});
                }
              },
            );
          },
        ),
      ),
      const _ExplorePage(),
      const _BookmarkPage(),
      Builder(
        builder: (context) => Center(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.person),
            label: const Text('Edit Profile'),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('HMTI', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(' News', style: TextStyle(color: Color(0xFF1877F2), fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _loggingOut ? null : _confirmLogout,
            icon: _loggingOut
                ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1877F2)),
              child: Text('Pengaturan', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: pages),

      // FAB hanya untuk tab Home (index 0)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: _openCreateNews,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1877F2),
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// =======================
/// Halaman Home (List News)
/// =======================
class _HomeNewsList extends StatelessWidget {
  const _HomeNewsList({required this.news, required this.onOpen});

  final List<Map<String, dynamic>> news;
  final void Function(Map<String, dynamic> item) onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return _NewsCard(item: item, onTap: () => onOpen(item));
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: (item['imageUrl'] as String?)?.isNotEmpty == true
          ? Image.network(
              item['imageUrl'] as String,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 40),
              ),
            )
          : Image.asset(
              'assets/images/logo.png', // 👈 GAMBAR DEFAULT DARI ASSETS
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 40),
              ),
            ),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                (item['title'] as String?) ?? '-',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '${(item['author'] as String?) ?? '-'} • ${(item['time'] as String?) ?? '-'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplorePage extends StatelessWidget {
  const _ExplorePage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Explore Page (konten menyusul)'));
  }
}

class _BookmarkPage extends StatelessWidget {
  const _BookmarkPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bookmark Page (konten menyusul)'));
  }
}