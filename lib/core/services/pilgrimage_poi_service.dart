import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../features/pilgrimage/models/pilgrimage_models.dart';
import 'pilgrimage_cache_service.dart';

// ── Top-level isolate function ────────────────────────────────
List<Map<String, dynamic>> _parsePois(String jsonStr) {
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  final elements = data['elements'] as List;
  final result = <Map<String, dynamic>>[];
  final seen = <int>{};

  for (final e in elements) {
    if (e['type'] != 'node') continue;
    final id = e['id'] as int;
    if (seen.contains(id)) continue;
    seen.add(id);

    final raw = e['tags'] as Map<String, dynamic>?;
    if (raw == null) continue;
    final tags = raw.map((k, v) => MapEntry(k, v.toString()));

    final String type;
    if (tags['tourism'] == 'hostel' ||
        (tags['amenity'] == 'shelter' &&
            (tags['hiking'] == 'yes' || tags['pilgrim'] == 'yes'))) {
      type = 'albergue';
    } else if (tags['amenity'] == 'drinking_water') {
      type = 'water';
    } else if (tags['amenity'] == 'place_of_worship' &&
        tags['religion'] == 'christian') {
      type = 'church';
    } else {
      continue;
    }

    result.add({
      'osm_id': id,
      'type': type,
      'name': tags['name'] ?? tags['brand'] ?? '',
      'lat': (e['lat'] as num).toDouble(),
      'lng': (e['lon'] as num).toDouble(),
    });
  }

  return result;
}

// ── Service ───────────────────────────────────────────────────
class PilgrimagePoiService {
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  final _cache = PilgrimageCacheService();

  /// Fetches POIs along [routePoints] using 2 km around each point.
  /// Uses [routePoints] as anchor nodes (typically the static ~15-pt polyline).
  Future<List<PilgrimPoi>> fetchPois(
    String routeId,
    List<LatLng> routePoints,
  ) async {
    if (routePoints.isEmpty) return [];

    // Cache first (TTL 7 days)
    final cached = await _cache.getPois(routeId);
    if (cached != null) return cached;

    // Build Overpass around-query for each route point
    final sb = StringBuffer('[out:json][timeout:45];(');
    for (final p in routePoints) {
      final coords =
          '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}';
      sb.write('node["tourism"="hostel"](around:2000,$coords);');
      sb.write(
          'node["amenity"="shelter"]["hiking"="yes"](around:2000,$coords);');
      sb.write(
          'node["amenity"="shelter"]["pilgrim"="yes"](around:2000,$coords);');
      sb.write('node["amenity"="drinking_water"](around:2000,$coords);');
      sb.write(
          'node["amenity"="place_of_worship"]["religion"="christian"](around:2000,$coords);');
    }
    sb.write(');out body;');

    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Refuge-CathoApp/1.0',
        },
        body: 'data=${Uri.encodeComponent(sb.toString())}',
      ).timeout(const Duration(seconds: 55));

      if (response.statusCode != 200) return [];

      final rawList = await compute(_parsePois, response.body);
      final pois = rawList
          .map((m) => PilgrimPoi(
                osmId: m['osm_id'] as int,
                type: m['type'] as String,
                name: m['name'] as String,
                lat: m['lat'] as double,
                lng: m['lng'] as double,
              ))
          .toList();

      await _cache.savePois(routeId, pois);
      return pois;
    } catch (e) {
      debugPrint('[POI] fetchPois $routeId failed: $e');
      return [];
    }
  }
}
