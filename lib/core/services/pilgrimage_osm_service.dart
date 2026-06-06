import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../features/pilgrimage/models/pilgrimage_models.dart';
import 'pilgrimage_cache_service.dart';

// ── Top-level function — runs in an isolate via compute() ─────────────────
List<List<double>> _parseOsmTrace(String jsonStr) {
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  final elements = data['elements'] as List;

  // 1. Node map: id → [lat, lon]
  final nodeMap = <int, List<double>>{};
  for (final e in elements) {
    if (e['type'] == 'node') {
      nodeMap[e['id'] as int] = [
        (e['lat'] as num).toDouble(),
        (e['lon'] as num).toDouble(),
      ];
    }
  }

  // 2. Way map: id → [nodeId, ...]
  final wayMap = <int, List<int>>{};
  for (final e in elements) {
    if (e['type'] == 'way') {
      wayMap[e['id'] as int] = (e['nodes'] as List).cast<int>();
    }
  }

  // 3. Ordered way IDs from the relation's members
  final orderedWayIds = <int>[];
  for (final e in elements) {
    if (e['type'] == 'relation') {
      for (final m in (e['members'] as List)) {
        if (m['type'] == 'way') {
          orderedWayIds.add(m['ref'] as int);
        }
      }
      break;
    }
  }

  // 4. Chain ways into a continuous path, reversing when needed
  final result = <List<double>>[];
  int? lastNodeId;

  for (final wayId in orderedWayIds) {
    var nodes = wayMap[wayId];
    if (nodes == null || nodes.isEmpty) continue;

    // Reverse this way if its end matches the previous end
    if (lastNodeId != null && nodes.last == lastNodeId) {
      nodes = nodes.reversed.toList();
    }

    // Skip duplicate junction node
    final skipFirst = lastNodeId != null && nodes.first == lastNodeId;
    for (int i = skipFirst ? 1 : 0; i < nodes.length; i++) {
      final coord = nodeMap[nodes[i]];
      if (coord != null) result.add(coord);
    }
    if (nodes.isNotEmpty) lastNodeId = nodes.last;
  }

  // 5. Downsample to ≤2000 points for smooth rendering
  if (result.length > 2000) {
    final step = result.length ~/ 2000;
    final sampled = <List<double>>[];
    for (int i = 0; i < result.length; i += step) {
      sampled.add(result[i]);
    }
    if (result.isNotEmpty && sampled.last != result.last) {
      sampled.add(result.last);
    }
    return sampled;
  }

  return result;
}

// ── Service ───────────────────────────────────────────────────────────────
class PilgrimageOsmService {
  static const Map<String, int> _relationIds = {
    'puy':        2356953,
    'tours':      2357064,
    'vezelay':    2357062,
    'arles':      2357066,
    'frances':    1366361,
    'portugues':  5974274,
    'norte':      1078262,
    'primitivo':  1359221,
    'plata':      1351511,
    'francigena': 5818665,
  };

  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  final _cache = PilgrimageCacheService();

  bool hasOsmData(String routeId) => _relationIds.containsKey(routeId);

  Future<List<LatLng>?> fetchTrace(String routeId) async {
    if (!_relationIds.containsKey(routeId)) return null;

    // Cache first (TTL 30 days)
    final cached = await _cache.getTrace(routeId);
    if (cached != null) return cached.points;

    // Fetch from Overpass API
    final relationId = _relationIds[routeId]!;
    try {
      final query =
          '[out:json][timeout:60];relation($relationId);(._;>;);out body;';
      final response = await http.post(
        Uri.parse(_overpassUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Refuge-CathoApp/1.0',
        },
        body: 'data=${Uri.encodeComponent(query)}',
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) return null;

      // Parse in isolate (can be several MB of JSON)
      final rawPoints = await compute(_parseOsmTrace, response.body);
      if (rawPoints.isEmpty) return null;

      final points = rawPoints.map((p) => LatLng(p[0], p[1])).toList();

      // Persist to SQLite
      await _cache.saveTrace(RouteGpxTrace(
        routeId: routeId,
        points: points,
        fetchedAt: DateTime.now(),
      ));

      return points;
    } catch (e) {
      debugPrint('[OSM] fetchTrace $routeId failed: $e');
      return null;
    }
  }
}
