import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_news_screen.dart';
import 'detail_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<List<Map<String, dynamic>>> _newsFuture;

  // ❌ final String _api = "https://hppms-sabala.my.id/api/news";
  // ✅ Menggunakan API endpoint yang benar
  final String _api = "https://hmti-news.hppms-sabala.my.id/api/posts";

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchNews();
  }

  // ✅ Merombak total fetchNews sesuai contoh Anda
  Future<List<Map<String, dynamic>>> fetchNews() async {
    final response = await http.get(Uri.parse(_api));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'imageUrl':
              'https://hmti-news.hppms-sabala.my.id/public_storage/' +
              (item['image'] ?? ''),
          'title': item['title'] ?? '',
          'author': item['author'] ?? '',
          'description': item['content'] ?? '',
          'time': item['updated_at'] ?? '',
        };
      }).toList();
    } else {
      throw Exception("Gagal memuat data, status: ${response.statusCode}");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _newsFuture = fetchNews();
    });
    await _newsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No news found"));
          }

          final news = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index) {
                final item = news[index];
                final String imageUrl = item['imageUrl'] ?? "";

                return Card(
                  margin: const EdgeInsets.all(8),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    // ✅ Jadikan onTap async untuk menunggu hasil
                    onTap: () async {
                      // ✅ Tunggu hasil dari DetailScreen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            newsId: item['id'],
                            title: item['title'],
                            description: item['description'],
                            author: item['author'],
                            imageUrl: imageUrl,
                            token: widget.token,
                          ),
                        ),
                      );

                      // ✅ Jika ada hasil 'true' (dari delete/update), refresh list
                      if (result == true) {
                        _refresh();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          // ✅ Menghapus header otentikasi karena URL gambar bersifat publik
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $imageUrl');
                              print('Image load error: $error');
                              return const Icon(
                                Icons.image_not_supported,
                                size: 180,
                              );
                            },
                          )
                        else
                          const SizedBox(
                            height: 180,
                            child: Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            item['author'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      const Center(child: Text("Explore")),
      const Center(child: Text("Bookmark")),
      EditProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("HMTI News")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Pengaturan", style: TextStyle(color: Colors.white)),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              // ✅ Jadikan onPressed async untuk menunggu hasil
              onPressed: () async {
                // ✅ Tunggu hasil dari AddNewsScreen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddNewsScreen(token: widget.token),
                  ),
                );

                // ✅ Jika ada hasil 'true' (dari create), refresh list
                if (result == true) {
                  _refresh();
                }
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Bookmark",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
