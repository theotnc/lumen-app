import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/liturgical_day.dart';

class LiturgicalService {
  static final LiturgicalService _instance = LiturgicalService._internal();
  factory LiturgicalService() => _instance;
  LiturgicalService._internal();

  final Map<String, LiturgicalDay> _cache = {};

  // ── Point d'entrée principal ──────────────────────────────
  // Un seul appel suffit : /messes/ contient déjà les informations liturgiques.
  Future<LiturgicalDay> getDay(DateTime date) async {
    final key = _fmt(date);
    if (_cache.containsKey(key)) return _cache[key]!;

    LiturgicalDay day = LiturgicalDay.local(date);

    try {
      final data = await _get(
        'https://api.aelf.org/v1/messes/$key/france',
      );
      if (data != null) {
        day = _merge(day, data);
      }
    } catch (_) {
      // API indisponible → on garde les données locales
    }

    _cache[key] = day;
    return day;
  }

  // ── Fusion données locales + réponse API ──────────────────
  LiturgicalDay _merge(LiturgicalDay base, Map<String, dynamic> data) {
    // ── informations liturgiques ──
    // Champs réels confirmés : couleur, annee, temps_liturgique,
    // jour_liturgique_nom, fete (= fête/saint du jour)
    final info = data['informations'] as Map<String, dynamic>? ?? {};

    final color      = _mapColor(info['couleur'] as String? ?? '');
    final seasonKey  = info['temps_liturgique'] as String?;
    final dayName    = info['jour_liturgique_nom'] as String?;
    final anneeRaw   = info['annee'] as String?; // null en semaine
    final fete       = info['fete'] as String?;  // saint ou fête du jour
    final seasonName = _seasonDisplayName(seasonKey ?? '');
    final annee      = anneeRaw != null ? _parseYear(anneeRaw) : null;

    // ── lectures de la messe ──
    // Structure : { "messes": [ { "nom": "...", "lectures": [...] } ] }
    // Champs de chaque lecture : type, ref, titre, contenu (HTML), intro_lue
    String? gospelRef, gospelTitle, gospelText;
    String? reading1Ref, reading1Title, reading1Text;
    String? psalmRef, psalmText;

    final messeList = data['messes'] as List<dynamic>? ?? [];
    if (messeList.isNotEmpty) {
      final lectures =
          (messeList.first as Map<String, dynamic>)['lectures'] as List<dynamic>? ?? [];

      for (final raw in lectures) {
        final l       = raw as Map<String, dynamic>;
        final type    = l['type']    as String? ?? '';
        final ref     = l['ref']     as String? ?? '';
        final titre   = l['titre']   as String? ?? '';
        final contenu = _stripHtml(l['contenu'] as String? ?? '');

        if (type == 'evangile') {
          gospelRef   = ref;
          gospelTitle = titre;
          gospelText  = contenu;
        } else if (type == 'lecture_1') {
          reading1Ref   = ref;
          reading1Title = titre;
          reading1Text  = contenu;
        } else if (type == 'psaume') {
          psalmRef  = ref;
          psalmText = contenu;
        }
      }
    }

    // Le saint n'a son propre endpoint (/saints/) → 404.
    // On utilise le champ "fete" de informations (contient le nom de la fête/saint).
    final saintName =
        (fete != null && fete.isNotEmpty) ? fete : null;

    return base.copyWith(
      seasonKey:      seasonKey,
      seasonName:     seasonName,
      color:          color,
      dayName:        dayName,
      liturgicalYear: annee,      // null = garde la valeur locale
      gospelRef:      gospelRef,
      gospelTitle:    gospelTitle,
      gospelText:     gospelText,
      reading1Ref:    reading1Ref,
      reading1Title:  reading1Title,
      reading1Text:   reading1Text,
      psalmRef:       psalmRef,
      psalmText:      psalmText,
      saintName:      saintName,
    );
  }

  // ── Requête HTTP ──────────────────────────────────────────
  Future<Map<String, dynamic>?> _get(String url) async {
    try {
      final resp = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) return null;
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Formatage de la date ──────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Mapping couleur AELF → clé interne ───────────────────
  String _mapColor(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'vert':   return 'vert';
      case 'violet': return 'violet';
      case 'rouge':  return 'rouge';
      case 'rose':   return 'rose';
      case 'blanc':
      case 'or':     return 'blanc';
      default:       return raw.isNotEmpty ? raw : 'vert';
    }
  }

  String _parseYear(String raw) {
    final y = raw.toUpperCase().trim();
    return (y == 'A' || y == 'B' || y == 'C') ? y : '';
  }

  String _seasonDisplayName(String key) {
    switch (key) {
      case 'avent':           return 'Avent';
      case 'noel':            return 'Temps de Noël';
      case 'careme':          return 'Carême';
      // AELF utilise "pascal" (et non "paques")
      case 'pascal':
      case 'temps_paques':
      case 'paques':          return 'Temps de Pâques';
      case 'temps_ordinaire':
      case 'ordinaire':       return 'Temps Ordinaire';
      default:
        return key.isNotEmpty ? key : 'Temps Ordinaire';
    }
  }

  /// Supprime les balises HTML et normalise les espaces.
  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    var text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', '\u2019')
        .replaceAll('&laquo;', '«')
        .replaceAll('&raquo;', '»')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&egrave;', 'è')
        .replaceAll('&agrave;', 'à')
        .replaceAll('&ccedil;', 'ç');
    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}
