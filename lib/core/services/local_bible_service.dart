import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_models.dart';

class LocalBibleService {
  static final LocalBibleService _instance = LocalBibleService._internal();
  factory LocalBibleService() => _instance;
  LocalBibleService._internal();

  // Données chargées une seule fois en mémoire
  List<_RawBook>? _raw;

  Future<void> _ensureLoaded() async {
    if (_raw != null) return;
    final str = await rootBundle.loadString(
      'assets/bible-master/json/fr_apee.json',
    );
    final list = jsonDecode(str) as List;
    _raw = list.map((e) => _RawBook.fromJson(e as Map<String, dynamic>)).toList();
  }

  // MARK: - Livres

  Future<List<BibleBook>> getBooks() async {
    await _ensureLoaded();
    return _raw!.asMap().entries.map((e) {
      final info = _bookInfo(e.value.abbrev);
      return BibleBook(
        id: e.value.abbrev,
        name: info.name,
        testament: info.testament,
      );
    }).toList();
  }

  // MARK: - Chapitres

  Future<List<BibleChapter>> getChapters(String bookId) async {
    await _ensureLoaded();
    final book = _raw!.firstWhere((b) => b.abbrev == bookId);
    return book.chapters.asMap().entries.map((e) {
      final num = e.key + 1;
      final info = _bookInfo(bookId);
      return BibleChapter(
        id: '$bookId.$num',
        bookId: bookId,
        number: '$num',
        reference: '${info.name} $num',
      );
    }).toList();
  }

  // MARK: - Contenu d'un chapitre

  Future<BiblePassage> getChapter(String chapterId) async {
    await _ensureLoaded();
    // chapterId = "gn.1"
    final parts = chapterId.split('.');
    final bookId = parts[0];
    final chapterNum = int.parse(parts[1]);

    final book = _raw!.firstWhere((b) => b.abbrev == bookId);
    final verses = book.chapters[chapterNum - 1];
    final info = _bookInfo(bookId);
    final reference = '${info.name} $chapterNum';

    final content = verses
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n\n');

    return BiblePassage(
      id: chapterId,
      reference: reference,
      content: content,
      copyright: 'Traduction APEE — Domaine public',
    );
  }

  // MARK: - Recherche

  Future<List<BibleSearchVerse>> search(String query) async {
    await _ensureLoaded();
    final q = query.toLowerCase();
    final results = <BibleSearchVerse>[];

    for (final book in _raw!) {
      final info = _bookInfo(book.abbrev);
      for (int ci = 0; ci < book.chapters.length; ci++) {
        final chapter = book.chapters[ci];
        for (int vi = 0; vi < chapter.length; vi++) {
          if (chapter[vi].toLowerCase().contains(q)) {
            results.add(BibleSearchVerse(
              id: '${book.abbrev}.${ci + 1}.${vi + 1}',
              reference: '${info.name} ${ci + 1}:${vi + 1}',
              text: chapter[vi],
            ));
            if (results.length >= 30) return results;
          }
        }
      }
    }
    return results;
  }

  // MARK: - Mapping abbrev → nom français + testament

  _BookInfo _bookInfo(String abbrev) =>
      _bookMap[abbrev] ?? _BookInfo(abbrev, 'OT');

  static const _bookMap = <String, _BookInfo>{
    // Ancien Testament
    'gn':  _BookInfo('Genèse', 'OT'),
    'ex':  _BookInfo('Exode', 'OT'),
    'lv':  _BookInfo('Lévitique', 'OT'),
    'nm':  _BookInfo('Nombres', 'OT'),
    'dt':  _BookInfo('Deutéronome', 'OT'),
    'js':  _BookInfo('Josué', 'OT'),
    'jg':  _BookInfo('Juges', 'OT'),
    'rt':  _BookInfo('Ruth', 'OT'),
    '1sm': _BookInfo('1 Samuel', 'OT'),
    '2sm': _BookInfo('2 Samuel', 'OT'),
    '1kgs':_BookInfo('1 Rois', 'OT'),
    '2kgs':_BookInfo('2 Rois', 'OT'),
    '1ch': _BookInfo('1 Chroniques', 'OT'),
    '2ch': _BookInfo('2 Chroniques', 'OT'),
    'ezr': _BookInfo('Esdras', 'OT'),
    'ne':  _BookInfo('Néhémie', 'OT'),
    'et':  _BookInfo('Esther', 'OT'),
    'jb':  _BookInfo('Job', 'OT'),
    'ps':  _BookInfo('Psaumes', 'OT'),
    'prv': _BookInfo('Proverbes', 'OT'),
    'ec':  _BookInfo('Ecclésiaste', 'OT'),
    'sg':  _BookInfo('Cantique des Cantiques', 'OT'),
    'is':  _BookInfo('Ésaïe', 'OT'),
    'jr':  _BookInfo('Jérémie', 'OT'),
    'lm':  _BookInfo('Lamentations', 'OT'),
    'ez':  _BookInfo('Ézéchiel', 'OT'),
    'dn':  _BookInfo('Daniel', 'OT'),
    'os':  _BookInfo('Osée', 'OT'),
    'jl':  _BookInfo('Joël', 'OT'),
    'am':  _BookInfo('Amos', 'OT'),
    'ob':  _BookInfo('Abdias', 'OT'),
    'jn':  _BookInfo('Jonas', 'OT'),
    'mi':  _BookInfo('Michée', 'OT'),
    'na':  _BookInfo('Nahoum', 'OT'),
    'hb':  _BookInfo('Habacuc', 'OT'),
    'zp':  _BookInfo('Sophonie', 'OT'),
    'ag':  _BookInfo('Aggée', 'OT'),
    'zc':  _BookInfo('Zacharie', 'OT'),
    'ml':  _BookInfo('Malachie', 'OT'),
    // Nouveau Testament
    'mt':  _BookInfo('Matthieu', 'NT'),
    'mk':  _BookInfo('Marc', 'NT'),
    'lk':  _BookInfo('Luc', 'NT'),
    'jo':  _BookInfo('Jean', 'NT'),
    'act': _BookInfo('Actes', 'NT'),
    'rm':  _BookInfo('Romains', 'NT'),
    '1co': _BookInfo('1 Corinthiens', 'NT'),
    '2co': _BookInfo('2 Corinthiens', 'NT'),
    'gl':  _BookInfo('Galates', 'NT'),
    'ep':  _BookInfo('Éphésiens', 'NT'),
    'ph':  _BookInfo('Philippiens', 'NT'),
    'cl':  _BookInfo('Colossiens', 'NT'),
    '1ts': _BookInfo('1 Thessaloniciens', 'NT'),
    '2ts': _BookInfo('2 Thessaloniciens', 'NT'),
    '1tm': _BookInfo('1 Timothée', 'NT'),
    '2tm': _BookInfo('2 Timothée', 'NT'),
    'tt':  _BookInfo('Tite', 'NT'),
    'phm': _BookInfo('Philémon', 'NT'),
    'heb': _BookInfo('Hébreux', 'NT'),
    'jm':  _BookInfo('Jacques', 'NT'),
    '1pe': _BookInfo('1 Pierre', 'NT'),
    '2pe': _BookInfo('2 Pierre', 'NT'),
    '1jo': _BookInfo('1 Jean', 'NT'),
    '2jo': _BookInfo('2 Jean', 'NT'),
    '3jo': _BookInfo('3 Jean', 'NT'),
    'jd':  _BookInfo('Jude', 'NT'),
    'rv':  _BookInfo('Apocalypse', 'NT'),
  };
}

class _BookInfo {
  final String name;
  final String testament;
  const _BookInfo(this.name, this.testament);
}

class _RawBook {
  final String abbrev;
  final List<List<String>> chapters;

  _RawBook({required this.abbrev, required this.chapters});

  factory _RawBook.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'] as List;
    return _RawBook(
      abbrev: json['abbrev'] as String,
      chapters: rawChapters
          .map((c) => (c as List).map((v) => v.toString()).toList())
          .toList(),
    );
  }
}
