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

  // ── Lecture d'un chapitre ─────────────────────────────────

  Future<bool> playChapter(String bookId, int chapter, String reference) async {
    final url = _getAudioUrl(bookId, chapter);
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

  // ── Construction de l'URL archive.org ────────────────────

  String? _getAudioUrl(String bookId, int chapter) {
    final name = _archiveNames[bookId];
    if (name == null) return null;
    final ch = chapter.toString().padLeft(3, '0');
    return 'https://archive.org/download/french_audiobible/${name}_$ch.mp3';
  }

  // ── Mapping IDs internes → noms archive.org ──────────────

  static const _archiveNames = <String, String>{
    // Ancien Testament
    'gn'  : '01_Genese',
    'ex'  : '02_Exode',
    'lv'  : '03_Levitique',
    'nm'  : '04_Nombres',
    'dt'  : '05_Deuteronome',
    'js'  : '06_Josue',
    'jg'  : '07_Juges',
    'rt'  : '08_Ruth',
    '1sm' : '09_1Samuel',
    '2sm' : '10_2Samuel',
    '1kgs': '11_1Rois',
    '2kgs': '12_2Rois',
    '1ch' : '13_1Chroniques',
    '2ch' : '14_2Chroniques',
    'ezr' : '15_Esdras',
    'ne'  : '16_Nehemie',
    'et'  : '17_Esther',
    'jb'  : '18_Job',
    'ps'  : '19_Psaumes',
    'prv' : '20_Proverbes',
    'ec'  : '21_Ecclesiaste',
    'sg'  : '22_Cantique',
    'is'  : '23_Esaie',
    'jr'  : '24_Jeremie',
    'lm'  : '25_Lamentations',
    'ez'  : '26_Ezechiel',
    'dn'  : '27_Daniel',
    'os'  : '28_Osee',
    'jl'  : '29_Joel',
    'am'  : '30_Amos',
    'ob'  : '31_Abdias',
    'jn'  : '32_Jonas',
    'mi'  : '33_Michee',
    'na'  : '34_Nahum',
    'hb'  : '35_Habacuc',
    'zp'  : '36_Sophonie',
    'ag'  : '37_Aggee',
    'zc'  : '38_Zacharie',
    'ml'  : '39_Malachie',
    // Nouveau Testament
    'mt'  : '40_Matthieu',
    'mk'  : '41_Marc',
    'lk'  : '42_Luc',
    'jo'  : '43_Jean',
    'act' : '44_Actes',
    'rm'  : '45_Romains',
    '1co' : '46_1Corinthiens',
    '2co' : '47_2Corinthiens',
    'gl'  : '48_Galates',
    'ep'  : '49_Ephesiens',
    'ph'  : '50_Philippiens',
    'cl'  : '51_Colossiens',
    '1ts' : '52_1Thessaloniciens',
    '2ts' : '53_2Thessaloniciens',
    '1tm' : '54_1Timothee',
    '2tm' : '55_2Timothee',
    'tt'  : '56_Tite',
    'phm' : '57_Philemon',
    'heb' : '58_Hebreux',
    'jm'  : '59_Jacques',
    '1pe' : '60_1Pierre',
    '2pe' : '61_2Pierre',
    '1jo' : '62_1Jean',
    '2jo' : '63_2Jean',
    '3jo' : '64_3Jean',
    'jd'  : '65_Jude',
    'rv'  : '66_Apocalypse',
  };
}
