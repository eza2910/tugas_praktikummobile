import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = 'https://hppms-sabala.my.id/api';

  /// Header dasar. Jika [withAuth] true dan token tersedia, sertakan Authorization Bearer.
  static Future<Map<String, String>> buildHeaders({bool withAuth = true, Map<String, String>? extra}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Jika backend perlu: 'X-Requested-With': 'XMLHttpRequest',
    };

    if (withAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        // Antisipasi kalau token tersimpan sudah mengandung "Bearer "
        final hasPrefix = token.toLowerCase().startsWith('bearer ');
        headers['Authorization'] = hasPrefix ? token : 'Bearer $token';
      }
    }

    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// Request mentah: mengembalikan http.Response tanpa decode.
  static Future<http.Response> request({
    required String method, // 'GET','POST','PUT','DELETE', dst.
    required String path,   // contoh: '/news' atau '/news/11'
    Map<String, dynamic>? jsonBody,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await buildHeaders(withAuth: auth);

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(jsonBody ?? {}));
      case 'PUT':
        return http.put(uri, headers: headers, body: jsonEncode(jsonBody ?? {}));
      case 'PATCH':
        return http.patch(uri, headers: headers, body: jsonEncode(jsonBody ?? {}));
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }
  }

  /// Request + decode JSON ke Map atau List. Lempar Exception jika non-2xx.
  static Future<dynamic> requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? jsonBody,
    bool auth = true,
  }) async {
    final res = await request(method: method, path: path, jsonBody: jsonBody, auth: auth);
    final status = res.statusCode;
    dynamic decoded;

    try {
      decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      decoded = null;
    }

    if (status < 200 || status >= 300) {
      final msg = _bestMessage(decoded) ?? 'Request gagal (${res.statusCode})';
      throw Exception(msg);
    }
    return decoded;
  }

  static String? _bestMessage(dynamic m) {
    if (m == null) return null;
    if (m is Map) {
      String? pick(String? v) => (v != null && v.trim().isNotEmpty) ? v : null;
      final msg = pick(m['message']?.toString());
      if (msg != null) return msg;
      final err = pick(m['error']?.toString());
      if (err != null) return err;
      if (m['data'] is Map) {
        final dm = pick((m['data'] as Map)['message']?.toString());
        if (dm != null) return dm;
      }
      final errors = m['errors'];
      if (errors is Map) {
        for (final e in errors.entries) {
          final v = e.value;
          if (v is List && v.isNotEmpty) {
            final s = v.first?.toString();
            if (s != null && s.trim().isNotEmpty) return s;
          } else if (v is String && v.trim().isNotEmpty) {
            return v;
          }
        }
      }
    }
    return null;
  }
}
