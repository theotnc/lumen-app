import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/church.dart';

// Fonction top-level requise par compute() (isolate background)
List<Map<String, dynamic>> _decodeJson(String raw) =>
    (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

class ChurchService {
  static final ChurchService _instance = ChurchService._internal();
  factory ChurchService() => _instance;
  ChurchService._internal();

  final _db = FirebaseFirestore.instance;
  final _distance = const Distance();

  // ── Bundle JSON (toutes les églises de France, offline) ───
  List<Church>? _bundledChurches;

  Future<void> warmUpBundle() => _loadBundledChurches();

  Future<List<Church>> _loadBundledChurches() async {
    if (_bundledChurches != null) return _bundledChurches!;
    try {
      final raw  = await rootBundle.loadString('assets/churches_france.json');
      // Parsing dans un isolate background pour ne pas bloquer l'UI
      final maps = await compute(_decodeJson, raw);
      _bundledChurches = maps
          .map((m) => Church.fromMap(m['id'] as String, m))
          .toList();
      return _bundledChurches!;
    } catch (_) {
      return [];
    }
  }

  // ── Données locales — Phase 1 (Bordeaux & environs) ──────
  // Ces iglises sont toujours disponibles, même sans connexion Firestore.
  static const List<Church> _localChurches = [
    Church(
      id: 'local_cathedrale_andre',
      nom: 'Cathédrale Saint-André',
      adresse: 'Place Pey-Berland',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8376,
      longitude: -0.5788,
      siteWeb: 'https://cathedrale-bordeaux.fr',
    ),
    Church(
      id: 'local_basilique_michel',
      nom: 'Basilique Saint-Michel',
      adresse: 'Place Canteloup',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8330,
      longitude: -0.5698,
    ),
    Church(
      id: 'local_basilique_seurin',
      nom: 'Basilique Saint-Seurin',
      adresse: 'Place des Martyrs de la Résistance',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8403,
      longitude: -0.5853,
    ),
    Church(
      id: 'local_notre_dame',
      nom: 'Église Notre-Dame',
      adresse: 'Rue du Docteur Nancel-Pénard',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8421,
      longitude: -0.5742,
    ),
    Church(
      id: 'local_saint_pierre',
      nom: 'Église Saint-Pierre',
      adresse: 'Place Saint-Pierre',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8396,
      longitude: -0.5700,
    ),
    Church(
      id: 'local_sainte_eulalie',
      nom: 'Église Sainte-Eulalie',
      adresse: 'Rue Sainte-Eulalie',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8366,
      longitude: -0.5770,
    ),
    Church(
      id: 'local_saint_augustin',
      nom: 'Église Saint-Augustin',
      adresse: '195 Rue Judaïque',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8464,
      longitude: -0.5870,
    ),
    Church(
      id: 'local_saint_ferdinand',
      nom: 'Église Saint-Ferdinand',
      adresse: 'Rue de Pessac',
      ville: 'Bordeaux',
      codePostal: '33000',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8282,
      longitude: -0.5796,
    ),
    Church(
      id: 'local_merignac_lorette',
      nom: 'Église Notre-Dame de Lorette',
      adresse: 'Allée de la Chênaie',
      ville: 'Mérignac',
      codePostal: '33700',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8380,
      longitude: -0.6430,
    ),
    Church(
      id: 'local_pessac_martin',
      nom: 'Église Saint-Martin',
      adresse: 'Place de la République',
      ville: 'Pessac',
      codePostal: '33600',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8072,
      longitude: -0.6298,
    ),
    Church(
      id: 'local_talence_jean',
      nom: 'Église Saint-Jean l\'Évangéliste',
      adresse: 'Rue du Bourg',
      ville: 'Talence',
      codePostal: '33400',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8046,
      longitude: -0.5841,
    ),
    Church(
      id: 'local_begles_caprais',
      nom: 'Église Saint-Caprais',
      adresse: 'Place du 8 Mai 1945',
      ville: 'Bègles',
      codePostal: '33130',
      departement: 'Gironde',
      region: 'Nouvelle-Aquitaine',
      diocese: 'Bordeaux',
      latitude: 44.8143,
      longitude: -0.5496,
    ),
  ];

  // ── Geocodage ville → coordonnées (Nominatim OSM) ─────────
  /// Retourne (LatLng, nomAffiché) ou null si introuvable.
  Future<(LatLng, String)?> geocodeCity(String query) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=3&countrycodes=fr,es,pt,be,ch'
        '&addressdetails=0',
      );
      final resp = await http.get(uri, headers: {
        'User-Agent': 'CathoApp/1.0 (contact@lumen-app.fr)',
        'Accept-Language': 'fr',
      }).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final list = jsonDecode(resp.body) as List<dynamic>;
      if (list.isEmpty) return null;
      final first = list.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '') ?? 0;
      final lon = double.tryParse(first['lon'] as String? ?? '') ?? 0;
      final name = (first['display_name'] as String? ?? query)
          .split(',')
          .first
          .trim();
      return (LatLng(lat, lon), name);
    } catch (_) {
      return null;
    }
  }

  // ── Cache OSM en mémoire (session) ───────────────────────
  final Map<String, List<Church>> _osmCache = {};

  String _osmCacheKey(LatLng c, double r) =>
      '${c.latitude.toStringAsFixed(2)}_${c.longitude.toStringAsFixed(2)}_${r.toInt()}';

  // ── Données locales synchrones (affichage immédiat) ───────
  // Utilise le bundle s'il est déjà chargé, sinon les 12 hardcodées
  List<Church> fetchLocalImmediate(LatLng position, double radiusKm) {
    final source = _bundledChurches ?? _localChurches;
    return source
        .where((c) => _distanceKm(position, c.latLng) <= radiusKm)
        .toList();
  }

  // ── Tous les lieux de culte OSM dans un rayon ─────────────
  Future<List<Church>> fetchFromOSM(LatLng center, double radiusKm) async {
    final cacheKey = _osmCacheKey(center, radiusKm);
    if (_osmCache.containsKey(cacheKey)) return _osmCache[cacheKey]!;

    final r = (radiusKm * 1000).round(); // mètres
    final lat = center.latitude;
    final lng = center.longitude;
    // Requête Overpass : TOUS les lieux de culte (sans filtre religion côté serveur)
    // Le filtre catholique est appliqué côté client via isOSMCatholic.
    // En France, beaucoup d'églises catholiques n'ont pas le tag religion=christian.
    final query =
        '[out:json][timeout:15];'
        '('
        'node["amenity"="place_of_worship"]'
        '(around:$r,$lat,$lng);'
        'way["amenity"="place_of_worship"]'
        '(around:$r,$lat,$lng);'
        ');'
        'out center;';
    try {
      final uri = Uri.parse('https://overpass-api.de/api/interpreter');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeComponent(query)}',
      ).timeout(const Duration(seconds: 18));
      if (resp.statusCode != 200) return [];
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List<dynamic>? ?? []);
      final result = elements
          .cast<Map<String, dynamic>>()
          .where((e) {
            final tags = (e['tags'] as Map<String, dynamic>?) ?? {};
            return Church.isOSMCatholic(tags);
          })
          .map((e) => Church.fromOSM(e))
          .where((c) => c.latitude != 0)
          .toList();
      _osmCache[cacheKey] = result;
      return result;
    } catch (_) {
      return [];
    }
  }

  // ── Églises proches ───────────────────────────────────────
  Future<List<Church>> fetchNearby({
    required LatLng position,
    required double radiusKm,
  }) async {
    // 1. Bundle local (33 000 églises France, offline, instantané après premier chargement)
    final bundled = await _loadBundledChurches();
    final local = bundled.isEmpty
        ? _localChurches.where((c) => _distanceKm(position, c.latLng) <= radiusKm).toList()
        : bundled.where((c) => _distanceKm(position, c.latLng) <= radiusKm).toList();

    // 2. Firestore (données enrichies : horaires, infos communautaires)
    List<Church> firestore = [];
    try {
      final snap = await _db
          .collection('eglises')
          .limit(300)
          .get()
          .timeout(const Duration(seconds: 8));
      firestore = snap.docs
          .map((d) => Church.fromMap(d.id, d.data()))
          .where((c) => _distanceKm(position, c.latLng) <= radiusKm)
          .toList();
    } catch (_) {}

    // 3. OSM Overpass seulement si le bundle et Firestore n'ont rien pour cette zone
    List<Church> osm = [];
    if (local.length < 3 && firestore.isEmpty) {
      try {
        osm = await fetchFromOSM(position, radiusKm);
        if (osm.isNotEmpty) _cacheOsmToFirestore(osm);
      } catch (_) {}
    }

    // 4. Fusion : Firestore > bundle/local > OSM
    final seen = <String>{};
    final merged = <Church>[];
    for (final c in [...firestore, ...local, ...osm]) {
      if (seen.contains(c.id)) continue;
      seen.add(c.id);
      merged.add(c);
    }

    merged.sort((a, b) =>
        _distanceKm(position, a.latLng)
            .compareTo(_distanceKm(position, b.latLng)));

    return merged;
  }

  // ── Cache write-through : sauvegarde les résultats OSM dans Firestore ────
  void _cacheOsmToFirestore(List<Church> churches) {
    // Batch Firestore (max 500 par batch)
    final batches = <WriteBatch>[];
    var batch = _db.batch();
    var count = 0;
    for (final church in churches) {
      if (!church.id.startsWith('osm_')) continue;
      final ref = _db.collection('eglises').doc(church.id);
      batch.set(ref, church.toMap(), SetOptions(merge: true));
      count++;
      if (count % 400 == 0) {
        batches.add(batch);
        batch = _db.batch();
      }
    }
    if (count % 400 != 0) batches.add(batch);
    for (final b in batches) {
      b.commit().catchError((_) {});
    }
  }

  // ── Horaires ─────────────────────────────────────────────
  Future<List<MassSchedule>> fetchSchedules(String churchId) async {
    if (churchId.startsWith('local_')) return [];
    try {
      final snap = await _db
          .collection('horaires')
          .where('egliseId', isEqualTo: churchId)
          .where('verifiee', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 8));

      final schedules = snap.docs
          .map((d) => MassSchedule.fromMap(d.id, d.data()))
          .toList();

      schedules.sort((a, b) {
        final dayOrder = MassSchedule.jours
            .indexOf(a.jour)
            .compareTo(MassSchedule.jours.indexOf(b.jour));
        if (dayOrder != 0) return dayOrder;
        return a.heure.compareTo(b.heure);
      });

      return schedules;
    } catch (_) {
      return [];
    }
  }

  // ── Enregistrer un horaire (soumis par utilisateur) ──────
  Future<void> saveSchedule(MassSchedule s) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await _db.collection('horaires').add({
      'egliseId':   s.egliseId,
      'jour':       s.jour,
      'heure':      s.heure,
      'type':       s.type,
      'langue':     s.langue,
      'notes':      s.notes,
      'verifiee':   true,
      'soumis_par': uid,
      'soumis_at':  FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _db.collection('horaires').doc(scheduleId).delete();
  }

  // ── Distance ─────────────────────────────────────────────
  double _distanceKm(LatLng from, LatLng to) =>
      _distance.as(LengthUnit.Kilometer, from, to);

  double distanceKm(LatLng from, Church church) =>
      _distanceKm(from, church.latLng);

  String formatDistance(LatLng from, Church church) {
    final km = _distanceKm(from, church.latLng);
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
