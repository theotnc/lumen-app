import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/pilgrimage/models/pilgrimage_models.dart';

class PilgrimageProgressService {
  static final PilgrimageProgressService _instance =
      PilgrimageProgressService._();
  factory PilgrimageProgressService() => _instance;
  PilgrimageProgressService._();

  static const _prefsPrefix = 'pilgrimage_progress_';

  // ── Lecture ────────────────────────────────────────────────
  Future<PilgrimProgress> getProgress(
      String routeId, int stageCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefsPrefix$routeId');
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final p = PilgrimProgress.fromJson(routeId, json);
        // Reconcile if stage count changed (hot update of route data)
        if (p.stagesCompleted.length == stageCount) return p;
        final padded = List<bool>.from(p.stagesCompleted);
        while (padded.length < stageCount) {
          padded.add(false);
        }
        return PilgrimProgress(
          routeId: routeId,
          stagesCompleted: padded.take(stageCount).toList(),
          startedAt: p.startedAt,
          completedAt: p.completedAt,
        );
      }
    } catch (e) {
      debugPrint('[Progress] getProgress $routeId failed: $e');
    }
    return PilgrimProgress.empty(routeId, stageCount);
  }

  // ── Toggle étape ───────────────────────────────────────────
  Future<PilgrimProgress> toggleStage(
      PilgrimProgress current, int index) async {
    final updated =
        current.copyWithStage(index, !current.stagesCompleted[index]);
    await _persist(updated);
    return updated;
  }

  // ── Réinitialisation ───────────────────────────────────────
  Future<PilgrimProgress> resetProgress(String routeId, int stageCount) async {
    final empty = PilgrimProgress.empty(routeId, stageCount);
    await _persist(empty);
    return empty;
  }

  // ── Persistance locale + Firestore ─────────────────────────
  Future<void> _persist(PilgrimProgress progress) async {
    // SharedPreferences (synchrone pour l'UI)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_prefsPrefix${progress.routeId}',
        progress.toJsonString(),
      );
    } catch (e) {
      debugPrint('[Progress] local save failed: $e');
    }

    // Firestore (non-bloquant, best-effort)
    _syncCloud(progress);
  }

  void _syncCloud(PilgrimProgress progress) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pilgrimage_progress')
        .doc(progress.routeId)
        .set(
          {
            'completed_stages': progress.stagesCompleted,
            'started_at': progress.startedAt != null
                ? Timestamp.fromDate(progress.startedAt!)
                : null,
            'completed_at': progress.completedAt != null
                ? Timestamp.fromDate(progress.completedAt!)
                : null,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        )
        .catchError(
            (e) => debugPrint('[Progress] Firestore sync failed: $e'));
  }
}
