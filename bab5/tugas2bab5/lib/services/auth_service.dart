import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthResult {
  final String token;
  AuthResult(this.token);
}

class AuthService {
  static const String _baseUrl = 'https://hppms-sabala.my.id/api';
  static const String _registerPath = '/register';
  static const String _loginPath    = '/login';

  static String? _cachedToken;

  // Panggil saat app start
  static Future<void> bootstrap() async {
    _cachedToken = await TokenStorage.read();
  }

  static Future<bool> isLoggedIn() async {
    _cachedToken ??= await TokenStorage.read();
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  static Future<String?> getToken() async {
    _cachedToken ??= await TokenStorage.read();
    return _normalizeToken(_cachedToken);
  }

  static Future<void> logout() async {
    _cachedToken = null;
    await TokenStorage.clear();
  }

  // =========================
  // REGISTER
  // =========================
  static Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$_baseUrl$_registerPath');

    // 1) coba JSON
    var res = await http.post(
      url,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    // 2) fallback x-www-form-urlencoded jika 422
    if (res.statusCode == 422) {
      res = await http.post(
        url,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    }

    final decoded = _decodeOrThrow(res);
    _ensureSuccess(decoded, res.statusCode);

    final token = _extractToken(decoded);
    if (token == null || token.isEmpty) {
      throw Exception(_bestMessage(decoded) ?? 'Token tidak ditemukan pada respons.');
    }

    final normalized = _normalizeToken(token)!;
    _cachedToken = normalized;
    await TokenStorage.save(normalized);
    return AuthResult(normalized);
  }

  // =========================
  // LOGIN
  // =========================
  static Future<AuthResult> login({
    required String identifier, // email atau username
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl$_loginPath');
    final trimmed = identifier.trim();
    final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trimmed);

    final List<Map<String, String>> candidates = [
      if (isEmail) {'email': trimmed, 'password': password},
      if (!isEmail) {'username': trimmed, 'password': password},
      {'identifier': trimmed, 'password': password}, // fallback
    ];

    Map<String, dynamic>? lastDecoded;
    int? lastStatus;

    for (final payload in candidates) {
      // 1) JSON
      http.Response res = await http.post(
        url,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // 2) fallback form-urlencoded kalau 422
      if (res.statusCode == 422) {
        res = await http.post(
          url,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: payload,
        );
      }

      lastStatus = res.statusCode;

      try {
        final any = jsonDecode(res.body);
        lastDecoded = any is Map
            ? Map<String, dynamic>.from(any as Map)
            : <String, dynamic>{'_raw': any};

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final token = _extractToken(lastDecoded);
          if (token == null || token.isEmpty) {
            throw Exception(_bestMessage(lastDecoded) ?? 'Token tidak ditemukan pada respons.');
          }
          final normalized = _normalizeToken(token)!;
          _cachedToken = normalized;
          await TokenStorage.save(normalized);
          return AuthResult(normalized);
        }
      } catch (_) {
        // lanjut kandidat berikutnya
      }
    }

    throw Exception(_bestMessage(lastDecoded) ?? 'Login gagal (status $lastStatus)');
  }

  // =========================
  // Helpers
  // =========================
  static Map<String, dynamic> _decodeOrThrow(http.Response res) {
    Map<String, dynamic>? decoded;
    try {
      final any = jsonDecode(res.body);
      if (any is Map) {
        decoded = Map<String, dynamic>.from(any as Map);
      } else {
        decoded = <String, dynamic>{'_raw': any};
      }
    } catch (_) {
      decoded = null;
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _bestMessage(decoded) ?? 'Request gagal (status ${res.statusCode})';
      throw Exception(msg);
    }
    return decoded ?? <String, dynamic>{};
  }

  static void _ensureSuccess(Map<String, dynamic> decoded, int status) {
    if (decoded.containsKey('success') && decoded['success'] != true) {
      final msg = _bestMessage(decoded) ?? 'Operasi gagal (status $status)';
      throw Exception(msg);
    }
  }

  /// Ambil token dari beragam bentuk umum respons
  static String? _extractToken(Map<String, dynamic>? m) {
    if (m == null) return null;

    // root level
    final rootToken = (m['token'] ?? m['access_token'])?.toString();
    if (rootToken != null && rootToken.isNotEmpty) return rootToken;

    // data.token / data.access_token
    if (m['data'] is Map) {
      final data = Map<String, dynamic>.from(m['data'] as Map);
      final t1 = (data['token'] ?? data['access_token'])?.toString();
      if (t1 != null && t1.isNotEmpty) return t1;

      // data.meta.token
      if (data['meta'] is Map) {
        final meta = Map<String, dynamic>.from(data['meta'] as Map);
        final t2 = (meta['token'] ?? meta['access_token'])?.toString();
        if (t2 != null && t2.isNotEmpty) return t2;
      }
    }

    // kadang bentuknya: { token_type: "Bearer", access_token: "xxx" }
    if (m['token_type'] != null && m['access_token'] != null) {
      return m['access_token'].toString();
    }

    return null;
  }

  /// Pastikan yang tersimpan hanya token murni (tanpa "Bearer ")
  static String? _normalizeToken(String? t) {
    if (t == null) return null;
    final s = t.trim();
    if (s.toLowerCase().startsWith('bearer ')) {
      return s.substring(7).trim();
    }
    return s;
  }

  static String? _bestMessage(Map<String, dynamic>? m) {
    if (m == null) return null;

    String? pick(String? v) => (v != null && v.trim().isNotEmpty) ? v : null;

    final msg = pick(m['message']?.toString());
    if (msg != null) return msg;

    final err = pick(m['error']?.toString());
    if (err != null) return err;

    if (m['data'] is Map) {
      final dm = pick(Map<String, dynamic>.from(m['data'] as Map)['message']?.toString());
      if (dm != null) return dm;
    }

    final errors = m['errors'];
    if (errors is Map) {
      for (final entry in errors.entries) {
        final val = entry.value;
        if (val is List && val.isNotEmpty) {
          final first = val.first?.toString();
          final picked = pick(first);
          if (picked != null) return picked;
        } else if (val is String) {
          final picked = pick(val);
          if (picked != null) return picked;
        }
      }
    }
    return null;
  }
}
