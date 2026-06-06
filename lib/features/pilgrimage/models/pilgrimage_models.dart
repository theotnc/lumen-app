import 'dart:convert';
import 'package:latlong2/latlong.dart';

// ── Tracé GPS (cache OSM) ──────────────────────────────────────
class RouteGpxTrace {
  final String routeId;
  final List<LatLng> points;
  final DateTime fetchedAt;

  const RouteGpxTrace({
    required this.routeId,
    required this.points,
    required this.fetchedAt,
  });
}

// ── POI sur la carte ──────────────────────────────────────────
class PilgrimPoi {
  final int osmId;
  final String type; // 'albergue' | 'water' | 'church'
  final String name;
  final double lat;
  final double lng;

  const PilgrimPoi({
    required this.osmId,
    required this.type,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

// ── Progression du pèlerin ─────────────────────────────────────
class PilgrimProgress {
  final String routeId;
  final List<bool> stagesCompleted; // one bool per keyStage
  final DateTime? startedAt;
  final DateTime? completedAt;

  const PilgrimProgress({
    required this.routeId,
    required this.stagesCompleted,
    this.startedAt,
    this.completedAt,
  });

  // ── Computed ───────────────────────────────────────────────
  bool get hasStarted => stagesCompleted.any((c) => c);
  bool get isCompleted =>
      stagesCompleted.isNotEmpty && stagesCompleted.every((c) => c);
  int get completedCount => stagesCompleted.where((c) => c).length;
  int get totalCount => stagesCompleted.length;
  double get fraction =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  // ── Mutations ──────────────────────────────────────────────
  PilgrimProgress copyWithStage(int index, bool completed) {
    final updated = List<bool>.from(stagesCompleted);
    updated[index] = completed;
    final allDone = updated.every((c) => c);
    return PilgrimProgress(
      routeId: routeId,
      stagesCompleted: updated,
      startedAt: startedAt ?? (completed ? DateTime.now() : null),
      completedAt: allDone ? (completedAt ?? DateTime.now()) : null,
    );
  }

  // ── Serialisation ──────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'completed': stagesCompleted,
        'started_at': startedAt?.millisecondsSinceEpoch,
        'completed_at': completedAt?.millisecondsSinceEpoch,
      };

  String toJsonString() => jsonEncode(toJson());

  factory PilgrimProgress.empty(String routeId, int stageCount) =>
      PilgrimProgress(
        routeId: routeId,
        stagesCompleted: List.filled(stageCount, false),
      );

  factory PilgrimProgress.fromJson(
      String routeId, Map<String, dynamic> json) {
    final completed = (json['completed'] as List).cast<bool>();
    final startedMs = json['started_at'] as int?;
    final completedMs = json['completed_at'] as int?;
    return PilgrimProgress(
      routeId: routeId,
      stagesCompleted: completed,
      startedAt: startedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(startedMs)
          : null,
      completedAt: completedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(completedMs)
          : null,
    );
  }
}
