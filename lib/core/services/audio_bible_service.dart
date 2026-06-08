import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioBibleService {
  static final AudioBibleService _instance = AudioBibleService._internal();
  factory AudioBibleService() => _instance;
  AudioBibleService._internal();

  final AudioPlayer player = AudioPlayer();

  String? _bookId;
  int?    _chapter;
  String? _reference;

  String? get currentBookId  => _bookId;
  int?    get currentChapter => _chapter;
  String? get currentReference => _reference;

  bool get isPlaying => player.playing;

  // ── Lecture d'un livre (audio par livre entier) ───────────

  Future<bool> playChapter(String bookId, int chapter, String reference) async {
    final url = _getAudioUrl(bookId);
    if (url == null) return false;

    try {
      _bookId    = bookId;
      _chapter   = chapter;
      _reference = reference;

      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await player.play();
      return true;
    } catch (e) {
      debugPrint('AudioBibleService error: $e');
      return false;
    }
  }

  Future<void> pause()  => player.pause();
  Future<void> resume() => player.play();
  Future<void> stop() async {
    await player.stop();
    _bookId    = null;
    _chapter   = null;
    _reference = null;
  }

  Future<void> seek(Duration position) => player.seek(position);

  // ── Construction de l'URL archive.org (LaBibleAudio — traduction catholique) ──

  String? _getAudioUrl(String bookId) {
    final filename = _archiveNames[bookId];
    if (filename == null) return null;
    // URL-encode les espaces dans le nom de fichier
    final encoded = Uri.encodeComponent('La Bible - $filename.mp3');
    return 'https://archive.org/download/LaBibleAudio/$encoded';
  }

  // ── Mapping IDs internes → noms LaBibleAudio ─────────────
  // Source : archive.org/details/LaBibleAudio — Traduction catholique (domaine public)

  static const _archiveNames = <String, String>{
    // Ancien Testament
    'gn'  : 'AT01_GENESE',
    'ex'  : 'AT02_EXODE',
    'lv'  : 'AT03_LEVITIQUE',
    'nm'  : 'AT04_NOMBRES',
    'dt'  : 'AT05_DEUTERONOME',
    'js'  : 'AT06_JOSUE',
    'jg'  : 'AT07_JUGES',
    '1sm' : 'AT08_SAMUEL1',
    '2sm' : 'AT09_SAMUEL2',
    '1kgs': 'AT10_ROIS1',
    '2kgs': 'AT11_ROIS2',
    'is'  : 'AT12_ISAIE',
    'jr'  : 'AT13_JEREMIE',
    'ez'  : 'AT14_EZECHIEL',
    'os'  : 'AT15_OSEE',
    'jl'  : 'AT16_JOEL',
    'am'  : 'AT17_AMOS',
    'ob'  : 'AT18_ABDIAS',
    'jn'  : 'AT19_JONAS',
    'mi'  : 'AT20_MICHEE',
    'na'  : 'AT21_NAHUM',
    'hb'  : 'AT22_HABACUC',
    'zp'  : 'AT23_SOPHONIE',
    'ag'  : 'AT24_AGGEE',
    'zc'  : 'AT25_ZACHARIE',
    'ml'  : 'AT26_MALACHIE',
    'ps'  : 'AT27_PSAUMES',
    'jb'  : 'AT28_JOB',
    'prv' : 'AT29_PROVERBES',
    'rt'  : 'AT30_RUTH',
    'sg'  : 'AT31_CANTIQUE',
    'ec'  : 'AT32_QOHELET',
    'lm'  : 'AT33_LAMENTATIONS',
    'dn'  : 'AT35_DANIEL',
    'ezr' : 'AT36_ESDRAS',
    'ne'  : 'AT37_NEHEMIE',
    '1ch' : 'AT38_CHRONIQUES1',
    '2ch' : 'AT39_CHRONIQUES2',
    'et'  : 'AT40_ESTHER',
    // Livres deutérocanoniques (catholiques)
    'jdt' : 'AT41_JUDITH',
    'tb'  : 'AT42_TOBIE',
    '1mac': 'AT43_MACCHABEES1',
    '2mac': 'AT44_MACCHABEES2',
    'wis' : 'AT45_SAGESSE',
    'sir' : 'AT46_SIRACIDE',
    'bar' : 'AT47_BARUCH',
    // Nouveau Testament
    'mt'  : 'NT01_MATTHIEU',
    'mk'  : 'NT02_MARC',
    'lk'  : 'NT03_LUC',
    'jo'  : 'NT04_JEAN',
    'act' : 'NT05_ACTES',
    'rm'  : 'NT06_ROMAINS',
    '1co' : 'NT07_CORINTHIENS1',
    '2co' : 'NT08_CORINTHIENS2',
    'gl'  : 'NT09_GALATES',
    'ep'  : 'NT10_EPHESIENS',
    'ph'  : 'NT11_PHILIPPIENS',
    'cl'  : 'NT12_COLOSSIENS',
    '1ts' : 'NT13_THESSALONICIENS1',
    '2ts' : 'NT14_THESSALONICIENS2',
    '1tm' : 'NT15_TIMOTHEE1',
    '2tm' : 'NT16_TIMOTHEE2',
    'tt'  : 'NT17_TITE',
    'phm' : 'NT18_PHILEMON',
    'heb' : 'NT19_HEBREUX',
    'jm'  : 'NT20_JACQUES',
    '1pe' : 'NT21_PIERRE1',
    '2pe' : 'NT22_PIERRE2',
    '1jo' : 'NT23_JEAN1',
    '2jo' : 'NT24_JEAN2',
    '3jo' : 'NT25_JEAN3',
    'jd'  : 'NT26_JUDE',
    'rv'  : 'NT27_APOCALYPSE',
  };
}
