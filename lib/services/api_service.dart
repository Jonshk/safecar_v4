import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../models/models.dart';

class ApiService {
  static final _base = AppTheme.apiBase;
  static final _client = http.Client();

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Health ───────────────────────────────────────────────────
  static Future<bool> health() async {
    try {
      final r = await _client.get(Uri.parse('$_base/health')).timeout(const Duration(seconds: 8));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Parts ────────────────────────────────────────────────────
  static Future<List<Part>> getParts({String? category, String? search, int skip = 0, int limit = 20}) async {
    final uri = Uri.parse('$_base/parts/').replace(queryParameters: {
      if (category != null) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      'skip': '$skip',
      'limit': '$limit',
    });
    try {
      final r = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final List data = jsonDecode(r.body);
        return data.map((e) => Part.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Part?> getPart(int id) async {
    try {
      final r = await _client.get(Uri.parse('$_base/parts/$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) return Part.fromJson(jsonDecode(r.body));
    } catch (_) {}
    return null;
  }

  // ── Courses ──────────────────────────────────────────────────
  static Future<List<Course>> getCourses() async {
    try {
      final r = await _client.get(Uri.parse('$_base/training/modules'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final List data = jsonDecode(r.body);
        return data.map((e) => Course.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Quote Requests ───────────────────────────────────────────
  static Future<bool> sendQuote(QuoteRequest q) async {
    try {
      final r = await _client.post(
        Uri.parse('$_base/quotes/'),
        headers: _headers,
        body: jsonEncode(q.toJson()),
      ).timeout(const Duration(seconds: 15));
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
