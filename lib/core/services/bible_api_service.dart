import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';

// Documentation: https://scripture.api.bible
// Clé API à obtenir sur https://scripture.api.bible/signup
// ID Bible Louis Segond 1910: "06125adad2d5898a-01"

class BibleApiService {
  static final BibleApiService _instance = BibleApiService._internal();
  factory BibleApiService() => _instance;
  BibleApiService._internal();

  // ⚠️ Ne jamais mettre la clé API en clair dans le code en production.
  // Utiliser une variable d'environnement ou une Cloud Function Firebase.
  static const String _apiKey = 'VOTRE_CLE_API_BIBLE';
  static const String _bibleId = '06125adad2d5898a-01'; // Louis Segond 1910
  static const String _baseUrl = 'https://api.scripture.api.bible/v1';

  Map<String, String> get _headers => {
        'api-key': _apiKey,
        'Accept': 'application/json',
      };

  // MARK: - Livres

  Future<List<BibleBook>> fetchBooks() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/bibles/$_bibleId/books'),
      headers: _headers,
    );
    _checkStatus(res);
    final data = jsonDecode(res.body)['data'] as List;
    return data.map((e) => BibleBook.fromJson(e)).toList();
  }

  // MARK: - Chapitres

  Future<List<BibleChapter>> fetchChapters(String bookId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/bibles/$_bibleId/books/$bookId/chapters'),
      headers: _headers,
    );
    _checkStatus(res);
    final data = jsonDecode(res.body)['data'] as List;
    return data.map((e) => BibleChapter.fromJson(e)).toList();
  }

  // MARK: - Contenu d'un chapitre

  Future<BiblePassage> fetchChapter(String chapterId) async {
    final uri = Uri.parse(
      '$_baseUrl/bibles/$_bibleId/chapters/$chapterId',
    ).replace(queryParameters: {
      'content-type': 'text',
      'include-notes': 'false',
      'include-titles': 'true',
      'include-chapter-numbers': 'false',
      'include-verse-numbers': 'true',
    });
    final res = await http.get(uri, headers: _headers);
    _checkStatus(res);
    return BiblePassage.fromJson(jsonDecode(res.body)['data']);
  }

  // MARK: - Recherche

  Future<List<BibleSearchVerse>> search(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/bibles/$_bibleId/search',
    ).replace(queryParameters: {'query': query, 'limit': '20'});
    final res = await http.get(uri, headers: _headers);
    _checkStatus(res);
    final data = jsonDecode(res.body)['data'];
    final verses = data['verses'] as List? ?? [];
    return verses.map((e) => BibleSearchVerse.fromJson(e)).toList();
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Erreur API Bible: ${res.statusCode}');
    }
  }
}
