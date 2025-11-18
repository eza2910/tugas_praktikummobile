import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final String api = 'https://hppms-sabala.my.id/api/news';

  debugPrint('Memulai pengujian URL gambar...');

  try {
    final response = await http.get(Uri.parse(api));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data']['data'];

      if (data.isEmpty) {
        debugPrint('Tidak ada berita yang ditemukan.');
        return;
      }

      debugPrint('\n--- Hasil Tes URL Gambar ---');
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        final title = item['title'] ?? 'Tanpa Judul';
        final imageUrl = item['image_url'];

        debugPrint('\nItem ${i + 1}:');
        debugPrint('  Judul: $title');
        debugPrint('  URL Gambar: ${imageUrl ?? 'Tidak tersedia'}');
      }
      debugPrint('\n--- Akhir Tes ---');
      debugPrint('\nTes selesai. Silakan periksa URL di atas.');
    } else {
      debugPrint('Gagal memuat berita. Kode status: ${response.statusCode}');
      debugPrint('Isi respons: ${response.body}');
    }
  } catch (e) {
    debugPrint('Terjadi error saat pengujian: $e');
  }
}
