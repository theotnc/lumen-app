import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String summary;
  final String url;
  final String source;
  final DateTime? publishedAt;

  const NewsArticle({
    required this.title,
    required this.summary,
    required this.url,
    required this.source,
    this.publishedAt,
  });

  String get timeAgo {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }
}

class RssResult {
  final List<NewsArticle> articles;
  final String? error;
  const RssResult({required this.articles, this.error});
}

class RssService {
  static final RssService _instance = RssService._internal();
  factory RssService() => _instance;
  RssService._internal();

  // rss2json.com : convertit RSS → JSON avec headers CORS
  // Fonctionne sur web ET mobile, gratuit jusqu'à 10 000 req/jour
  static const _apiBase = 'https://api.rss2json.com/v1/api.json?rss_url=';

  static const _sources = [
    _RssSource('https://fr.aleteia.org/feed/', 'Aleteia'),
    _RssSource('https://www.vaticannews.va/fr.rss.xml', 'Vatican News'),
  ];

  List<NewsArticle>? _cache;
  DateTime? _cachedAt;

  Future<RssResult> fetchNews() async {
    if (_cache != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(minutes: 30)) {
      return RssResult(articles: _cache!);
    }

    final errors = <String>[];

    for (final source in _sources) {
      try {
        final uri = Uri.parse(
          '$_apiBase${Uri.encodeComponent(source.url)}',
        );

        final response = await http.get(uri, headers: {
          'User-Agent': 'CathoApp/1.0 Flutter',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          if (data['status'] == 'ok') {
            final items = (data['items'] as List? ?? []);
            final articles = items
                .map((raw) {
                  final m = raw as Map<String, dynamic>;
                  final title = (m['title'] as String? ?? '').trim();
                  final desc =
                      _strip(m['description'] as String? ?? '');
                  final link = m['link'] as String? ?? '';
                  final date = _parseDate(m['pubDate'] as String? ?? '');
                  if (title.isEmpty) return null;
                  return NewsArticle(
                    title: title,
                    summary: desc,
                    url: link,
                    source: source.name,
                    publishedAt: date,
                  );
                })
                .whereType<NewsArticle>()
                .take(12)
                .toList();

            if (articles.isNotEmpty) {
              _cache = articles;
              _cachedAt = DateTime.now();
              return RssResult(articles: articles);
            }
            errors.add('${source.name}: 0 articles reçus');
          } else {
            errors.add('${source.name}: API status=${data['status']} — ${data['message'] ?? ''}');
          }
        } else {
          errors.add('${source.name}: HTTP ${response.statusCode}');
        }
      } catch (e) {
        errors.add('${source.name}: $e');
      }
    }

    return RssResult(
      articles: _cache ?? [],
      error: errors.join('\n'),
    );
  }

  String _strip(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll("&#039;", "'")
        .replaceAll('\u2019', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // rss2json renvoie "2026-04-05 15:11:59" — parsé directement par DateTime
  DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    try {
      // Format rss2json : "2026-04-05 15:11:59"
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}

class _RssSource {
  final String url;
  final String name;
  const _RssSource(this.url, this.name);
}
