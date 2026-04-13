import 'package:flutter/material.dart';

// ── Modèle ────────────────────────────────────────────────
class LiturgicalDay {
  final DateTime date;
  final String seasonKey;      // temps_ordinaire | avent | noel | careme | paques
  final String seasonName;     // "Temps de Pâques", "Avent", …
  final String color;          // vert | violet | blanc | rouge | rose
  final String dayName;        // "Jeudi de l'octave de Pâques"
  final String liturgicalYear; // A | B | C

  final String? gospelRef;
  final String? gospelTitle;
  final String? gospelText;
  final String? reading1Ref;
  final String? reading1Title;
  final String? reading1Text;
  final String? psalmRef;
  final String? psalmText;
  final String? saintName;

  const LiturgicalDay({
    required this.date,
    required this.seasonKey,
    required this.seasonName,
    required this.color,
    required this.dayName,
    required this.liturgicalYear,
    this.gospelRef,
    this.gospelTitle,
    this.gospelText,
    this.reading1Ref,
    this.reading1Title,
    this.reading1Text,
    this.psalmRef,
    this.psalmText,
    this.saintName,
  });

  LiturgicalDay copyWith({
    String? seasonKey,
    String? seasonName,
    String? color,
    String? dayName,
    String? liturgicalYear,
    String? gospelRef,
    String? gospelTitle,
    String? gospelText,
    String? reading1Ref,
    String? reading1Title,
    String? reading1Text,
    String? psalmRef,
    String? psalmText,
    String? saintName,
  }) => LiturgicalDay(
    date: date,
    seasonKey: seasonKey ?? this.seasonKey,
    seasonName: seasonName ?? this.seasonName,
    color: color ?? this.color,
    dayName: dayName ?? this.dayName,
    liturgicalYear: liturgicalYear ?? this.liturgicalYear,
    gospelRef: gospelRef ?? this.gospelRef,
    gospelTitle: gospelTitle ?? this.gospelTitle,
    gospelText: gospelText ?? this.gospelText,
    reading1Ref: reading1Ref ?? this.reading1Ref,
    reading1Title: reading1Title ?? this.reading1Title,
    reading1Text: reading1Text ?? this.reading1Text,
    psalmRef: psalmRef ?? this.psalmRef,
    psalmText: psalmText ?? this.psalmText,
    saintName: saintName ?? this.saintName,
  );

  // ── Couleur d'accent UI ───────────────────────────────────
  Color get accentColor {
    switch (color) {
      case 'violet': return const Color(0xFF9B59B6);
      case 'rouge':  return const Color(0xFFE74C3C);
      case 'rose':   return const Color(0xFFE91E8C);
      case 'vert':   return const Color(0xFF27AE60);
      default:       return const Color(0xFFC9A844); // blanc → or
    }
  }

  Color get bgTintColor {
    switch (color) {
      case 'violet': return const Color(0xFF150025);
      case 'rouge':  return const Color(0xFF250000);
      case 'rose':   return const Color(0xFF1F0018);
      case 'vert':   return const Color(0xFF001A08);
      default:       return const Color(0xFF1A1000); // or/blanc
    }
  }

  // ── Calcul local (offline) ───────────────────────────────

  factory LiturgicalDay.local(DateTime date) {
    final (key, name, col) = _computeSeason(date);
    return LiturgicalDay(
      date: date,
      seasonKey: key,
      seasonName: name,
      color: col,
      dayName: name,
      liturgicalYear: _liturgicalYear(date),
    );
  }

  // ── Algorithme de Meeus/Jones/Butcher pour la date de Pâques ─
  static DateTime _easter(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  // ── Premier dimanche de l'Avent (dimanche le plus proche du 30 nov) ─
  static DateTime _adventStart(int year) {
    final nov30 = DateTime(year, 11, 30);
    final wd = nov30.weekday; // 1=lun … 7=dim
    return wd <= 3
        ? nov30.subtract(Duration(days: wd == 7 ? 0 : wd))
        : nov30.add(Duration(days: 7 - wd));
  }

  // ── Dimanche du Baptême du Seigneur (1er dimanche ≥ 7 jan) ─
  static DateTime _baptismOfLord(int year) {
    var d = DateTime(year, 1, 7);
    while (d.weekday != DateTime.sunday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  // ── Saison liturgique ─────────────────────────────────────
  static (String, String, String) _computeSeason(DateTime date) {
    final y = date.year;
    final d = DateTime(y, date.month, date.day);

    final easterY      = _easter(y);
    final ashWedY      = easterY.subtract(const Duration(days: 46));
    final pentecostY   = easterY.add(const Duration(days: 49));
    final adventY      = _adventStart(y);
    final christmasY   = DateTime(y, 12, 25);

    final easterPrev    = _easter(y - 1);
    final pentecostPrev = easterPrev.add(const Duration(days: 49));
    final baptismPrev   = _baptismOfLord(y - 1);
    final christmasPrev = DateTime(y - 1, 12, 25);

    // Noël de l'année précédente (jusqu'au Baptême du Seigneur)
    if (!d.isBefore(christmasPrev) && d.isBefore(baptismPrev)) {
      return ('noel', 'Temps de Noël', 'blanc');
    }
    // Temps Ordinaire I (après Baptême – avant Carême)
    if (!d.isBefore(baptismPrev) && d.isBefore(ashWedY)) {
      // Edge: si l'année précédente n'a pas encore eu sa Pentecôte (impossible mais sécurité)
      if (d.isBefore(pentecostPrev)) {
        return ('paques', 'Temps de Pâques', 'blanc');
      }
      return ('temps_ordinaire', 'Temps Ordinaire', 'vert');
    }
    // Carême
    if (!d.isBefore(ashWedY) && d.isBefore(easterY)) {
      return ('careme', 'Carême', 'violet');
    }
    // Temps de Pâques
    if (!d.isBefore(easterY) && d.isBefore(pentecostY)) {
      return ('paques', 'Temps de Pâques', 'blanc');
    }
    // Pentecôte (le jour même)
    if (d.year == pentecostY.year &&
        d.month == pentecostY.month &&
        d.day == pentecostY.day) {
      return ('paques', 'Pentecôte', 'rouge');
    }
    // Temps Ordinaire II (après Pentecôte – avant Avent)
    if (!d.isBefore(pentecostY) && d.isBefore(adventY)) {
      return ('temps_ordinaire', 'Temps Ordinaire', 'vert');
    }
    // Avent
    if (!d.isBefore(adventY) && d.isBefore(christmasY)) {
      return ('avent', 'Avent', 'violet');
    }
    // Noël de cette année (à partir du 25 déc)
    if (!d.isBefore(christmasY)) {
      return ('noel', 'Temps de Noël', 'blanc');
    }
    return ('temps_ordinaire', 'Temps Ordinaire', 'vert');
  }

  // ── Année liturgique A/B/C ────────────────────────────────
  static String _liturgicalYear(DateTime date) {
    final advent = _adventStart(date.year);
    final startYear = date.isBefore(advent) ? date.year - 1 : date.year;
    switch (startYear % 3) {
      case 1:  return 'A';
      case 2:  return 'B';
      default: return 'C';
    }
  }
}
