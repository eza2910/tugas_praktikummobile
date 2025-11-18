import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../utils/constants.dart';

class BookService {
  // 📥 GET /books — Ambil semua buku (PUBLIC, tanpa token!)
  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat buku (status: ${response.statusCode})');
    }
  }

  // 📖 GET /books/{id} — Ambil detail buku
  static Future<Book?> fetchBookById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$id'));
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Gagal memuat detail buku (status: ${response.statusCode})',
      );
    }
  }

  // ➕ POST /books — Tambah buku baru
  static Future<Book> addBook(
    String title,
    String author,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title.trim(),
        'author': author.trim(),
        'description': description.trim(),
      }),
    );
    if (response.statusCode == 201) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response);
      throw Exception('Gagal menambah buku: $errorMsg');
    }
  }

  // ✏ PUT /books/{id} — Edit buku
  static Future<Book> updateBook(
    int id,
    String title,
    String author,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title.trim(),
        'author': author.trim(),
        'description': description.trim(),
      }),
    );
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      final errorMsg = _extractErrorMessage(response);
      throw Exception('Gagal memperbarui buku: $errorMsg');
    }
  }

  // 🗑 DELETE /books/{id} — Hapus buku
  static Future<bool> deleteBook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // 🔍 Helper: Ekstrak pesan error dari response (jika ada)
  static String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map) {
        if (json.containsKey('message')) return json['message'] as String;
        if (json.containsKey('error')) return json['error'] as String;
      }
    } catch (_) {}
    return 'Status ${response.statusCode}';
  }
}
