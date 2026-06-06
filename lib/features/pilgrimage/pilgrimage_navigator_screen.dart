import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/pilgrimage_cache_service.dart';
import '../../core/services/pilgrimage_progress_service.dart';
import '../../core/theme.dart';
import 'models/pilgrimage_models.dart';
import 'pilgrimage_data.dart';

class PilgrimageNavigatorScreen extends StatefulWidget {
  final PilgrimRoute route;
  const PilgrimageNavigatorScreen({super.key, required this.route});

  @override
  State<PilgrimageNavigatorScreen> createState() =>
      _PilgrimageNavigatorScreenState();
}

class _PilgrimageNavigatorScreenState
    extends State<PilgrimageNavigatorScreen> {
  PilgrimRoute get route => widget.route;

  final _cache = PilgrimageCacheService();
  final _progressSvc = PilgrimageProgressService();
  final _mapCtrl = MapController();
  final _dist = const Distance();

  // ── Route ──────────────────────────────────────────────────
  List<LatLng> _routePoints = [];
  List<double> _distPrefix = []; // cumulative km from start to each index
  bool _routeLoading = true;

  // ── Progress ───────────────────────────────────────────────
  PilgrimProgress? _progress;

  // ── GPS ────────────────────────────────────────────────────
  StreamSubscription<Position>? _posSub;
  LatLng? _position;
  LatLng? _lastPos;
  double _heading = 0;
  double _speed = 0; // m/s, smoothed
  final List<double> _speedBuffer = [];

  // ── Navigation ─────────────────────────────────────────────
  double _remainingKm = 0;
  bool _onRoute = false;
  double _sessionKm = 0;
  bool _followUser = true;

  static const _kDefaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _loadTrace();
    _loadProgress();
    _startGps();
  }

  // ── Chargement ─────────────────────────────────────────────
  Future<void> _loadTrace() async {
    List<LatLng>? pts;
    final cached = await _cache.getTrace(route.id);
    if (cached != null && cached.points.isNotEmpty) {
      pts = cached.points;
    } else if (route.polyline.isNotEmpty) {
      pts = route.polyline;
    }
    if (!mounted) return;
    setState(() {
      _routePoints = pts ?? [];
      _routeLoading = false;
    });
    _buildDistPrefix();
  }

  void _buildDistPrefix() {
    if (_routePoints.isEmpty) {
      _distPrefix = [];
      return;
    }
    _distPrefix = List.filled(_routePoints.length, 0.0);
    for (int i = 1; i < _routePoints.length; i++) {
      _distPrefix[i] = _distPrefix[i - 1] +
          _dist(_routePoints[i - 1], _routePoints[i]) / 1000.0;
    }
  }

  Future<void> _loadProgress() async {
    final p =
        await _progressSvc.getProgress(route.id, route.keyStages.length);
    if (mounted) setState(() => _progress = p);
  }

  Future<void> _startGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(_onPosition);
    } catch (_) {}
  }

  void _onPosition(Position pos) {
    final ll = LatLng(pos.latitude, pos.longitude);

    // Session km — ignore GPS jumps > 500 m
    if (_lastPos != null) {
      final delta = _dist(_lastPos!, ll) / 1000.0;
      if (delta < 0.5) _sessionKm += delta;
    }
    _lastPos = ll;

    // Speed smoothing (pos.speed is -1 when unavailable)
    _speedBuffer.add(pos.speed.clamp(0.0, double.maxFinite));
    if (_speedBuffer.length > 5) _speedBuffer.removeAt(0);
    final smoothSpeed =
        _speedBuffer.reduce((a, b) => a + b) / _speedBuffer.length;

    // Route analysis
    int nearestIdx = 0;
    double remainingKm = 0;
    bool onRoute = false;
    if (_routePoints.isNotEmpty) {
      nearestIdx = _findNearestIdx(ll);
      remainingKm = _distPrefix.isNotEmpty
          ? _distPrefix.last - _distPrefix[nearestIdx]
          : 0;
      onRoute = _checkOnRoute(ll);
    }

    setState(() {
      _position = ll;
      _heading = pos.heading;
      _speed = smoothSpeed;
      _remainingKm = remainingKm.clamp(0.0, double.maxFinite);
      _onRoute = onRoute;
    });

    if (_followUser) {
      try {
        _mapCtrl.move(ll, _mapCtrl.camera.zoom);
      } catch (_) {}
    }
  }

  int _findNearestIdx(LatLng pos) {
    final n = _routePoints.length;
    if (n == 0) return 0;
    final step = max(1, n ~/ 300);
    int bestIdx = 0;
    double bestDist = double.maxFinite;

    // Coarse scan
    for (int i = 0; i < n; i += step) {
      final d = _dist(pos, _routePoints[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    // Fine scan around best
    final lo = max(0, bestIdx - step);
    final hi = min(n - 1, bestIdx + step);
    for (int i = lo; i <= hi; i++) {
      final d = _dist(pos, _routePoints[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  bool _checkOnRoute(LatLng pos) {
    for (int i = 0; i < _routePoints.length; i += 5) {
      if (_dist(pos, _routePoints[i]) <= 150) return true;
    }
    return false;
  }

  void _recenter() {
    setState(() => _followUser = true);
    if (_position != null) {
      try {
        _mapCtrl.move(_position!, _kDefaultZoom);
      } catch (_) {}
    }
  }

  // ── Prochaine étape non accomplie ──────────────────────────
  PilgrimStage? get _nextStage {
    if (_progress == null) return route.keyStages.isNotEmpty ? route.keyStages.last : null;
    for (int i = 0; i < route.keyStages.length; i++) {
      if (!_progress!.stagesCompleted[i]) return route.keyStages[i];
    }
    return route.keyStages.isNotEmpty ? route.keyStages.last : null;
  }

  String _formatEta() {
    if (_speed < 0.3 || _remainingKm <= 0) return '--';
    final hours = _remainingKm / (_speed * 3.6);
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }

  String _formatSpeed() =>
      _speed < 0.1 ? '0.0' : (_speed * 3.6).toStringAsFixed(1);

  @override
  void dispose() {
    _posSub?.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const hudBase = 164.0;
    final hudHeight = hudBase + safeBottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Carte plein écran ──────────────────────────────
          _buildMap(),

          // ── Gradient + barre du haut ───────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // ── HUD bas ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildHud(safeBottom),
          ),

          // ── Bouton re-centrage ─────────────────────────────
          Positioned(
            bottom: hudHeight + 12,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _followUser ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _followUser,
                child: _buildRecenterBtn(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Carte
  // ────────────────────────────────────────────────────────────
  Widget _buildMap() {
    final hasRoute = _routePoints.isNotEmpty;
    final initialCenter = _position ??
        (hasRoute
            ? _routePoints[_routePoints.length ~/ 2]
            : const LatLng(43.0, 1.0));

    return FlutterMap(
      mapController: _mapCtrl,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: _kDefaultZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onMapEvent: (event) {
          if (_followUser &&
              event.source != MapEventSource.mapController &&
              event.source != MapEventSource.nonRotatedSizeChange &&
              event.source != MapEventSource.interactiveFlagsChanged &&
              event.source != MapEventSource.fitCamera) {
            setState(() => _followUser = false);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.cathoapp.lumen',
        ),

        // Tracé
        if (hasRoute)
          PolylineLayer(polylines: [
            Polyline(
              points: _routePoints,
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
          ]),

        // Départ / arrivée
        if (hasRoute)
          MarkerLayer(markers: [
            Marker(
              point: _routePoints.first,
              width: 26,
              height: 26,
              child: _pin(const Color(0xFF34C759), Icons.hiking),
            ),
            Marker(
              point: _routePoints.last,
              width: 26,
              height: 26,
              child: _pin(AppTheme.primary, Icons.place_rounded),
            ),
          ]),

        // Flèche utilisateur
        if (_position != null)
          MarkerLayer(markers: [
            Marker(
              point: _position!,
              width: 46,
              height: 46,
              child: _UserArrow(
                heading: _heading,
                moving: _speed > 0.5,
              ),
            ),
          ]),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Barre du haut
  // ────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.72),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 16, 18),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_routeLoading)
                      Text('Chargement du tracé…',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.50)))
                    else
                      Text(
                        _routePoints.isNotEmpty
                            ? '${_routePoints.length} points GPS'
                            : 'Tracé approximatif',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.40)),
                      ),
                  ],
                ),
              ),
              _GpsIndicator(
                hasGps: _position != null,
                followUser: _followUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  HUD bas (glassmorphism)
  // ────────────────────────────────────────────────────────────
  Widget _buildHud(double safeBottom) {
    final next = _nextStage;
    final progress = _progress;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + safeBottom),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.10),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Label + distance restante ────────────────
              Row(
                children: [
                  Icon(Icons.flag_rounded,
                      size: 12,
                      color: AppTheme.primary.withValues(alpha: 0.75)),
                  const SizedBox(width: 6),
                  Text(
                    'PROCHAINE ÉTAPE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary.withValues(alpha: 0.75),
                      letterSpacing: 1.3,
                    ),
                  ),
                  const Spacer(),
                  if (_position != null)
                    Text(
                      '${_remainingKm.toStringAsFixed(1)} km restants',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                next?.city ?? route.end,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // ── Barre de progression ─────────────────────
              if (progress != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 11),
              ],

              // ── Chips statut ─────────────────────────────
              Row(
                children: [
                  _StatusPill(
                    onRoute: _onRoute,
                    hasGps: _position != null,
                  ),
                  const SizedBox(width: 8),
                  _HudChip(
                    icon: Icons.speed_rounded,
                    label: '${_formatSpeed()} km/h',
                  ),
                  const SizedBox(width: 8),
                  _HudChip(
                    icon: Icons.schedule_rounded,
                    label: _formatEta(),
                  ),
                  const Spacer(),
                  if (_sessionKm >= 0.05)
                    Text(
                      '${_sessionKm.toStringAsFixed(2)} km',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.38),
                        letterSpacing: -0.2,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Bouton re-centrage
  // ────────────────────────────────────────────────────────────
  Widget _buildRecenterBtn() {
    return GestureDetector(
      onTap: _recenter,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.50),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.my_location_rounded,
            size: 22, color: Colors.white),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _pin(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 13, color: Colors.white),
    );
  }
}

// ── Flèche GPS de l'utilisateur ────────────────────────────────
class _UserArrow extends StatelessWidget {
  final double heading;
  final bool moving;
  const _UserArrow({required this.heading, required this.moving});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading * pi / 180,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.45),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          moving ? Icons.navigation_rounded : Icons.circle,
          size: moving ? 22 : 10,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Indicateur GPS (barre du haut) ─────────────────────────────
class _GpsIndicator extends StatelessWidget {
  final bool hasGps;
  final bool followUser;
  const _GpsIndicator({required this.hasGps, required this.followUser});

  @override
  Widget build(BuildContext context) {
    if (!hasGps) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 11,
          height: 11,
          child: CircularProgressIndicator(
              color: Colors.white.withValues(alpha: 0.50),
              strokeWidth: 1.8),
        ),
        const SizedBox(width: 6),
        Text('GPS…',
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.50))),
      ]);
    }
    return Icon(
      followUser
          ? Icons.gps_fixed_rounded
          : Icons.gps_not_fixed_rounded,
      size: 20,
      color: followUser
          ? const Color(0xFF007AFF)
          : Colors.white.withValues(alpha: 0.40),
    );
  }
}

// ── Pill statut sur le chemin ──────────────────────────────────
class _StatusPill extends StatelessWidget {
  final bool onRoute;
  final bool hasGps;
  const _StatusPill({required this.onRoute, required this.hasGps});

  @override
  Widget build(BuildContext context) {
    if (!hasGps) {
      return _pill(
        Colors.white.withValues(alpha: 0.14),
        Icons.gps_off_rounded,
        'Pas de GPS',
        Colors.white.withValues(alpha: 0.50),
      );
    }
    return _pill(
      onRoute
          ? const Color(0xFF34C759).withValues(alpha: 0.20)
          : const Color(0xFFFF9500).withValues(alpha: 0.20),
      onRoute ? Icons.route_rounded : Icons.warning_amber_rounded,
      onRoute ? 'Sur le chemin' : 'Hors chemin',
      onRoute ? const Color(0xFF34C759) : const Color(0xFFFF9500),
    );
  }

  Widget _pill(Color bg, IconData icon, String text, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.28), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: fg),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

// ── Chip métrique HUD ──────────────────────────────────────────
class _HudChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HudChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.50)),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
    ]);
  }
}
