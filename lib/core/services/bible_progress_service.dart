import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Sauvegarde et restitue la progression de lecture de la Bible.
/// – Dernière position lue  : clé "bible_last"  → "{bookId}/{chapter}"
/// – Chapitres complétés    : clé "bible_done"  → Set de "{bookId}/{chapter}"
class BibleProgressService {
  static const _keyLast = 'bible_last';
  static const _keyDone = 'bible_done';

  // ── Dernière position ──────────────────────────────────────

  Future<void> saveLastRead(String bookId, String bookName, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLast, jsonEncode({
      'bookId': bookId,
      'bookName': bookName,
      'chapter': chapter,
    }));
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLast);
    if (raw == null) return null;
    try { return jsonDecode(raw) as Map<String, dynamic>; }
    catch (_) { return null; }
  }

  // ── Chapitres complétés ────────────────────────────────────

  Future<Set<String>> _getDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyDone)?.toSet() ?? {};
  }

  Future<void> markChapterRead(String bookId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final done = await _getDone();
    done.add('$bookId/$chapter');
    await prefs.setStringList(_keyDone, done.toList());
  }

  /// Chapitres lus pour un livre donné (numéros 1-indexés).
  Future<Set<int>> getReadChapters(String bookId) async {
    final done = await _getDone();
    return done
        .where((k) => k.startsWith('$bookId/'))
        .map((k) => int.tryParse(k.split('/')[1]) ?? 0)
        .where((n) => n > 0)
        .toSet();
  }

  /// Nombre de chapitres lus dans un sous-ensemble de livres (AT ou NT).
  Future<int> countRead(List<String> bookIds) async {
    final done = await _getDone();
    return done.where((k) => bookIds.any((id) => k.startsWith('$id/'))).length;
  }

  /// Nombre total de chapitres lus (tous testaments).
  Future<int> totalRead() async => (await _getDone()).length;

  // ── Position de défilement exacte ─────────────────────────

  static const _keyScroll = 'bible_scroll';

  Future<void> saveScrollOffset(String bookId, double offset) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyScroll);
    final map = raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : <String, dynamic>{};
    map[bookId] = offset;
    await prefs.setString(_keyScroll, jsonEncode(map));
  }

  Future<double?> getScrollOffset(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyScroll);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final v = map[bookId];
      if (v == null) return null;
      return (v as num).toDouble();
    } catch (_) { return null; }
  }

}
