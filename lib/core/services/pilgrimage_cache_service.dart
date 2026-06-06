import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/pilgrimage/models/pilgrimage_models.dart';

class PilgrimageCacheService {
  static final PilgrimageCacheService _instance = PilgrimageCacheService._();
  factory PilgrimageCacheService() => _instance;
  PilgrimageCacheService._();

  static const int _traceMaxAgeDays = 30;
  static const int _poiMaxAgeDays = 7;
  Database? _db;

  Future<Database?> _getDb() async {
    if (_db != null) return _db;
    try {
      final dbPath = await getDatabasesPath();
      _db = await openDatabase(
        '$dbPath/pilgrimage_cache.db',
        version: 2,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE route_traces (
              id TEXT PRIMARY KEY,
              points TEXT NOT NULL,
              fetched_at INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE pois (
              osm_id INTEGER NOT NULL,
              route_id TEXT NOT NULL,
              type TEXT NOT NULL,
              name TEXT NOT NULL,
              lat REAL NOT NULL,
              lng REAL NOT NULL,
              fetched_at INTEGER NOT NULL,
              PRIMARY KEY (osm_id, route_id)
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS pois (
                osm_id INTEGER NOT NULL,
                route_id TEXT NOT NULL,
                type TEXT NOT NULL,
                name TEXT NOT NULL,
                lat REAL NOT NULL,
                lng REAL NOT NULL,
                fetched_at INTEGER NOT NULL,
                PRIMARY KEY (osm_id, route_id)
              )
            ''');
          }
        },
      );
    } catch (e) {
      debugPrint('[PilgrimageCache] DB init failed: $e');
    }
    return _db;
  }

  // ── Tracés GPS ─────────────────────────────────────────────
  Future<RouteGpxTrace?> getTrace(String routeId) async {
    try {
      final db = await _getDb();
      if (db == null) return null;

      final rows = await db.query(
        'route_traces',
        where: 'id = ?',
        whereArgs: [routeId],
      );
      if (rows.isEmpty) return null;

      final row = rows.first;
      final fetchedAt =
          DateTime.fromMillisecondsSinceEpoch(row['fetched_at'] as int);
      if (DateTime.now().difference(fetchedAt).inDays > _traceMaxAgeDays) {
        await db.delete('route_traces', where: 'id = ?', whereArgs: [routeId]);
        return null;
      }

      final rawList = jsonDecode(row['points'] as String) as List;
      final points = rawList
          .map((p) =>
              LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
          .toList();

      return RouteGpxTrace(
          routeId: routeId, points: points, fetchedAt: fetchedAt);
    } catch (e) {
      debugPrint('[PilgrimageCache] getTrace $routeId failed: $e');
      return null;
    }
  }

  Future<void> saveTrace(RouteGpxTrace trace) async {
    try {
      final db = await _getDb();
      if (db == null) return;

      final pointsJson = jsonEncode(
        trace.points.map((p) => [p.latitude, p.longitude]).toList(),
      );
      await db.insert(
        'route_traces',
        {
          'id': trace.routeId,
          'points': pointsJson,
          'fetched_at': trace.fetchedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('[PilgrimageCache] saveTrace ${trace.routeId} failed: $e');
    }
  }

  // ── POIs ────────────────────────────────────────────────────
  Future<List<PilgrimPoi>?> getPois(String routeId) async {
    try {
      final db = await _getDb();
      if (db == null) return null;

      // Check freshness via oldest fetched_at for this route
      final meta = await db.rawQuery(
        'SELECT MIN(fetched_at) AS min_fetched FROM pois WHERE route_id = ?',
        [routeId],
      );
      final minFetchedMs = meta.first['min_fetched'] as int?;
      if (minFetchedMs == null) return null;

      final minFetched = DateTime.fromMillisecondsSinceEpoch(minFetchedMs);
      if (DateTime.now().difference(minFetched).inDays > _poiMaxAgeDays) {
        await db.delete('pois', where: 'route_id = ?', whereArgs: [routeId]);
        return null;
      }

      final rows = await db.query(
        'pois',
        where: 'route_id = ?',
        whereArgs: [routeId],
      );
      return rows
          .map((r) => PilgrimPoi(
                osmId: r['osm_id'] as int,
                type: r['type'] as String,
                name: r['name'] as String,
                lat: r['lat'] as double,
                lng: r['lng'] as double,
              ))
          .toList();
    } catch (e) {
      debugPrint('[PilgrimageCache] getPois $routeId failed: $e');
      return null;
    }
  }

  Future<void> savePois(String routeId, List<PilgrimPoi> pois) async {
    try {
      final db = await _getDb();
      if (db == null) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final batch = db.batch();
      batch.delete('pois', where: 'route_id = ?', whereArgs: [routeId]);
      for (final poi in pois) {
        batch.insert(
          'pois',
          {
            'osm_id': poi.osmId,
            'route_id': routeId,
            'type': poi.type,
            'name': poi.name,
            'lat': poi.lat,
            'lng': poi.lng,
            'fetched_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('[PilgrimageCache] savePois $routeId failed: $e');
    }
  }
}
