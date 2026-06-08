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
      'assets/bible-master/json/fr_crampon.json',
    );
    final data = jsonDecode(str) as Map<String, dynamic>;
    final books = data['books'] as List;
    _raw = books
        .map((e) => _RawBook.fromCrampon(e as Map<String, dynamic>))
        .where((b) => b.abbrev.isNotEmpty)
        .toList();
  }

  // MARK: - Livres

  Future<List<BibleBook>> getBooks() async {
    await _ensureLoaded();
    return _raw!.map((b) {
      final info = _bookInfo(b.abbrev);
      return BibleBook(
        id: b.abbrev,
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
      copyright: 'Crampon 1923 — Domaine public',
    );
  }

  // MARK: - Tous les chapitres d'un livre (lecture continue)

  Future<List<BiblePassage>> getAllChapters(String bookId) async {
    await _ensureLoaded();
    final book = _raw!.firstWhere((b) => b.abbrev == bookId);
    final info = _bookInfo(bookId);
    return book.chapters.asMap().entries.map((e) {
      final chNum = e.key + 1;
      final content = e.value.asMap().entries
          .map((v) => '${v.key + 1}. ${v.value}')
          .join('\n\n');
      return BiblePassage(
        id: '$bookId.$chNum',
        reference: '${info.name} $chNum',
        content: content,
      );
    }).toList();
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

  // MARK: - Mapping nom anglais FreCrampon → abréviation interne

  static const _cramponToAbbrev = <String, String>{
    'Genesis':          'gn',
    'Exodus':           'ex',
    'Leviticus':        'lv',
    'Numbers':          'nm',
    'Deuteronomy':      'dt',
    'Joshua':           'js',
    'Judges':           'jg',
    'Ruth':             'rt',
    'I Samuel':         '1sm',
    'II Samuel':        '2sm',
    'I Kings':          '1kgs',
    'II Kings':         '2kgs',
    'I Chronicles':     '1ch',
    'II Chronicles':    '2ch',
    'Ezra':             'ezr',
    'Nehemiah':         'ne',
    'Tobit':            'tb',
    'Judith':           'jdt',
    'Esther':           'et',
    'I Maccabees':      '1mac',
    'II Maccabees':     '2mac',
    'Job':              'jb',
    'Psalms':           'ps',
    'Proverbs':         'prv',
    'Ecclesiastes':     'ec',
    'Song of Solomon':  'sg',
    'Wisdom':           'wis',
    'Sirach':           'sir',
    'Isaiah':           'is',
    'Jeremiah':         'jr',
    'Lamentations':     'lm',
    'Baruch':           'bar',
    'Ezekiel':          'ez',
    'Daniel':           'dn',
    'Hosea':            'os',
    'Joel':             'jl',
    'Amos':             'am',
    'Obadiah':          'ob',
    'Jonah':            'jn',
    'Micah':            'mi',
    'Nahum':            'na',
    'Habakkuk':         'hb',
    'Zephaniah':        'zp',
    'Haggai':           'ag',
    'Zechariah':        'zc',
    'Malachi':          'ml',
    'Matthew':          'mt',
    'Mark':             'mk',
    'Luke':             'lk',
    'John':             'jo',
    'Acts':             'act',
    'Romans':           'rm',
    'I Corinthians':    '1co',
    'II Corinthians':   '2co',
    'Galatians':        'gl',
    'Ephesians':        'ep',
    'Philippians':      'ph',
    'Colossians':       'cl',
    'I Thessalonians':  '1ts',
    'II Thessalonians': '2ts',
    'I Timothy':        '1tm',
    'II Timothy':       '2tm',
    'Titus':            'tt',
    'Philemon':         'phm',
    'Hebrews':          'heb',
    'James':            'jm',
    'I Peter':          '1pe',
    'II Peter':         '2pe',
    'I John':           '1jo',
    'II John':          '2jo',
    'III John':         '3jo',
    'Jude':             'jd',
    'Revelation of John': 'rv',
  };

  // MARK: - Mapping abréviation → nom français + testament

  _BookInfo _bookInfo(String abbrev) =>
      _bookMap[abbrev] ?? _BookInfo(abbrev, 'OT');

  static const _bookMap = <String, _BookInfo>{
    // Pentateuque
    'gn':   _BookInfo('Genèse', 'OT'),
    'ex':   _BookInfo('Exode', 'OT'),
    'lv':   _BookInfo('Lévitique', 'OT'),
    'nm':   _BookInfo('Nombres', 'OT'),
    'dt':   _BookInfo('Deutéronome', 'OT'),
    // Livres historiques
    'js':   _BookInfo('Josué', 'OT'),
    'jg':   _BookInfo('Juges', 'OT'),
    'rt':   _BookInfo('Ruth', 'OT'),
    '1sm':  _BookInfo('1 Samuel', 'OT'),
    '2sm':  _BookInfo('2 Samuel', 'OT'),
    '1kgs': _BookInfo('1 Rois', 'OT'),
    '2kgs': _BookInfo('2 Rois', 'OT'),
    '1ch':  _BookInfo('1 Chroniques', 'OT'),
    '2ch':  _BookInfo('2 Chroniques', 'OT'),
    'ezr':  _BookInfo('Esdras', 'OT'),
    'ne':   _BookInfo('Néhémie', 'OT'),
    'tb':   _BookInfo('Tobie', 'OT'),       // deutérocanonique
    'jdt':  _BookInfo('Judith', 'OT'),      // deutérocanonique
    'et':   _BookInfo('Esther', 'OT'),      // après Judith dans le canon catholique
    '1mac': _BookInfo('1 Maccabées', 'OT'), // deutérocanonique
    '2mac': _BookInfo('2 Maccabées', 'OT'), // deutérocanonique
    // Poésie et sagesse
    'jb':   _BookInfo('Job', 'OT'),
    'ps':   _BookInfo('Psaumes', 'OT'),
    'prv':  _BookInfo('Proverbes', 'OT'),
    'ec':   _BookInfo('Qohéleth', 'OT'),
    'sg':   _BookInfo('Cantique des Cantiques', 'OT'),
    'wis':  _BookInfo('Sagesse', 'OT'),     // deutérocanonique
    'sir':  _BookInfo('Siracide', 'OT'),    // deutérocanonique
    // Grands Prophètes
    'is':   _BookInfo('Isaïe', 'OT'),
    'jr':   _BookInfo('Jérémie', 'OT'),
    'lm':   _BookInfo('Lamentations', 'OT'),
    'bar':  _BookInfo('Baruch', 'OT'),      // deutérocanonique
    'ez':   _BookInfo('Ézéchiel', 'OT'),
    'dn':   _BookInfo('Daniel', 'OT'),
    // Petits Prophètes
    'os':   _BookInfo('Osée', 'OT'),
    'jl':   _BookInfo('Joël', 'OT'),
    'am':   _BookInfo('Amos', 'OT'),
    'ob':   _BookInfo('Abdias', 'OT'),
    'jn':   _BookInfo('Jonas', 'OT'),
    'mi':   _BookInfo('Michée', 'OT'),
    'na':   _BookInfo('Nahoum', 'OT'),
    'hb':   _BookInfo('Habacuc', 'OT'),
    'zp':   _BookInfo('Sophonie', 'OT'),
    'ag':   _BookInfo('Aggée', 'OT'),
    'zc':   _BookInfo('Zacharie', 'OT'),
    'ml':   _BookInfo('Malachie', 'OT'),
    // Nouveau Testament
    'mt':   _BookInfo('Matthieu', 'NT'),
    'mk':   _BookInfo('Marc', 'NT'),
    'lk':   _BookInfo('Luc', 'NT'),
    'jo':   _BookInfo('Jean', 'NT'),
    'act':  _BookInfo('Actes', 'NT'),
    'rm':   _BookInfo('Romains', 'NT'),
    '1co':  _BookInfo('1 Corinthiens', 'NT'),
    '2co':  _BookInfo('2 Corinthiens', 'NT'),
    'gl':   _BookInfo('Galates', 'NT'),
    'ep':   _BookInfo('Éphésiens', 'NT'),
    'ph':   _BookInfo('Philippiens', 'NT'),
    'cl':   _BookInfo('Colossiens', 'NT'),
    '1ts':  _BookInfo('1 Thessaloniciens', 'NT'),
    '2ts':  _BookInfo('2 Thessaloniciens', 'NT'),
    '1tm':  _BookInfo('1 Timothée', 'NT'),
    '2tm':  _BookInfo('2 Timothée', 'NT'),
    'tt':   _BookInfo('Tite', 'NT'),
    'phm':  _BookInfo('Philémon', 'NT'),
    'heb':  _BookInfo('Hébreux', 'NT'),
    'jm':   _BookInfo('Jacques', 'NT'),
    '1pe':  _BookInfo('1 Pierre', 'NT'),
    '2pe':  _BookInfo('2 Pierre', 'NT'),
    '1jo':  _BookInfo('1 Jean', 'NT'),
    '2jo':  _BookInfo('2 Jean', 'NT'),
    '3jo':  _BookInfo('3 Jean', 'NT'),
    'jd':   _BookInfo('Jude', 'NT'),
    'rv':   _BookInfo('Apocalypse', 'NT'),
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

  factory _RawBook.fromCrampon(Map<String, dynamic> json) {
    final englishName = json['name'] as String;
    final abbrev = LocalBibleService._cramponToAbbrev[englishName] ?? '';

    final rawChapters = json['chapters'] as List;
    final chapters = rawChapters.map((c) {
      final verses = (c as Map<String, dynamic>)['verses'] as List;
      return verses
          .map((v) => ((v as Map<String, dynamic>)['text'] as String).trim())
          .toList();
    }).toList();

    return _RawBook(abbrev: abbrev, chapters: chapters);
  }
}
