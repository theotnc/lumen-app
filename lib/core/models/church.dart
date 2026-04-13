import 'package:latlong2/latlong.dart';

class Church {
  final String id;
  final String nom;
  final String adresse;
  final String ville;
  final String codePostal;
  final String departement;
  final String region; // Pour l'expansion nationale
  final double latitude;
  final double longitude;
  final String? telephone;
  final String? siteWeb;
  final String diocese;

  const Church({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    required this.departement,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.telephone,
    this.siteWeb,
    required this.diocese,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  String get fullAddress => '$adresse, $codePostal $ville';

  // ── Dénominations explicitement non-catholiques ───────────
  static const _nonCatholicDenominations = {
    'protestant', 'reformed', 'lutheran', 'calvinist',
    'baptist', 'methodist', 'pentecostal', 'charismatic',
    'evangelical', 'adventist', 'evangelical_free',
    'jehovah_witness', 'jehovahs_witness',
    'mormon', 'latter_day_saints',
    'anglican', 'church_of_england',
    'orthodox', 'greek_orthodox', 'russian_orthodox',
    'coptic', 'armenian', 'assyrian',
    'new_apostolic', 'seventh_day_adventist',
    'salvation_army', 'quaker',
  };

  /// Retourne true si l'élément OSM est catholique (ou non tagué → catholique par défaut en France).
  static bool isOSMCatholic(Map<String, dynamic> tags) {
    final religion = (tags['religion'] as String? ?? '').toLowerCase().trim();
    final denom = (tags['denomination'] as String? ?? '').toLowerCase().trim();

    // Lieu de culte explicitement non-chrétien (mosquée, synagogue, temple…) → exclure
    if (religion.isNotEmpty && religion != 'christian') return false;

    // Dénomination explicitement catholique → inclure
    if (denom.contains('catholic')) return true;

    // Dénomination dans la liste noire → exclure
    if (_nonCatholicDenominations.contains(denom)) return false;

    // Non tagué ou dénomination inconnue → inclure (catholique par défaut en France)
    return true;
  }

  // ── Depuis un élément Overpass (OSM) ─────────────────────
  factory Church.fromOSM(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final lat = (el['lat'] ?? el['center']?['lat'] ?? 0.0).toDouble();
    final lng = (el['lon'] ?? el['center']?['lon'] ?? 0.0).toDouble();
    final id = 'osm_${el['type']}_${el['id']}';
    return Church(
      id: id,
      nom: tags['name'] ?? tags['name:fr'] ?? 'Église',
      adresse: tags['addr:street'] ?? tags['addr:housenumber'] ?? '',
      ville: tags['addr:city'] ?? tags['addr:town'] ?? tags['addr:village'] ?? '',
      codePostal: tags['addr:postcode'] ?? '',
      departement: '',
      region: '',
      latitude: lat,
      longitude: lng,
      telephone: tags['phone'] ?? tags['contact:phone'],
      siteWeb: tags['website'] ?? tags['contact:website'],
      diocese: '',
    );
  }

  factory Church.fromMap(String id, Map<String, dynamic> map) => Church(
        id: id,
        nom: map['nom'] ?? '',
        adresse: map['adresse'] ?? '',
        ville: map['ville'] ?? '',
        codePostal: map['codePostal'] ?? '',
        departement: map['departement'] ?? '',
        region: map['region'] ?? '',
        latitude: (map['latitude'] ?? 0.0).toDouble(),
        longitude: (map['longitude'] ?? 0.0).toDouble(),
        telephone: map['telephone'],
        siteWeb: map['siteWeb'],
        diocese: map['diocese'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'adresse': adresse,
        'ville': ville,
        'codePostal': codePostal,
        'departement': departement,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'telephone': telephone,
        'siteWeb': siteWeb,
        'diocese': diocese,
        'dateModification': DateTime.now().toIso8601String(),
      };
}

class MassSchedule {
  final String id;
  final String egliseId;
  final String jour; // lundi, mardi, ...
  final String heure; // HH:mm
  final String type; // Messe, Rosaire, ...
  final String langue;
  final String? notes;
  final bool verifiee;

  const MassSchedule({
    required this.id,
    required this.egliseId,
    required this.jour,
    required this.heure,
    required this.type,
    required this.langue,
    this.notes,
    this.verifiee = true,
  });

  factory MassSchedule.fromMap(String id, Map<String, dynamic> map) =>
      MassSchedule(
        id: id,
        egliseId: map['egliseId'] ?? '',
        jour: map['jour'] ?? '',
        heure: map['heure'] ?? '',
        type: map['type'] ?? 'Messe',
        langue: map['langue'] ?? 'Français',
        notes: map['notes'],
        verifiee: map['verifiee'] ?? true,
      );

  static const List<String> jours = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
  ];

  static const List<String> types = [
    'Messe', 'Rosaire', 'Confessions', 'Adoration', 'Vêpres', 'Laudes'
  ];
}
