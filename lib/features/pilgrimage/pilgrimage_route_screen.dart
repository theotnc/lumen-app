import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/pilgrimage_osm_service.dart';
import '../../core/services/pilgrimage_poi_service.dart';
import '../../core/services/pilgrimage_progress_service.dart';
import '../../core/theme.dart';
import 'models/pilgrimage_models.dart';
import 'pilgrimage_data.dart';
import 'pilgrimage_navigator_screen.dart';

class PilgrimageRouteScreen extends StatefulWidget {
  final PilgrimRoute route;
  const PilgrimageRouteScreen({super.key, required this.route});

  @override
  State<PilgrimageRouteScreen> createState() => _PilgrimageRouteScreenState();
}

class _PilgrimageRouteScreenState extends State<PilgrimageRouteScreen> {
  PilgrimRoute get route => widget.route;

  final _osm = PilgrimageOsmService();
  final _poiSvc = PilgrimagePoiService();
  final _progressSvc = PilgrimageProgressService();
  final _mapCtrl = MapController();

  // ── State ──────────────────────────────────────────────────
  List<LatLng>? _osmPoints;
  bool _osmLoading = false;

  List<PilgrimPoi>? _pois;
  bool _poisLoading = false;
  bool _showAlbergues = true;
  bool _showWater = true;
  bool _showChurches = true;

  LatLng? _userPos;
  StreamSubscription<Position>? _posSub;
  PilgrimProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadOsmTrace();
    _loadPois();
    _loadProgress();
    _startGps();
  }

  // ── Chargement ─────────────────────────────────────────────
  Future<void> _loadOsmTrace() async {
    if (!_osm.hasOsmData(route.id)) return;
    setState(() => _osmLoading = true);
    final pts = await _osm.fetchTrace(route.id);
    if (!mounted) return;
    setState(() {
      _osmPoints = pts ?? [];
      _osmLoading = false;
    });
  }

  Future<void> _loadPois() async {
    final pts = route.polyline;
    if (pts.isEmpty) return;
    setState(() => _poisLoading = true);
    final pois = await _poiSvc.fetchPois(route.id, pts);
    if (!mounted) return;
    setState(() {
      _pois = pois;
      _poisLoading = false;
    });
  }

  Future<void> _loadProgress() async {
    final p =
        await _progressSvc.getProgress(route.id, route.keyStages.length);
    if (mounted) setState(() => _progress = p);
  }

  Future<void> _toggleStage(int index) async {
    if (_progress == null) return;
    final updated = await _progressSvc.toggleStage(_progress!, index);
    if (mounted) setState(() => _progress = updated);
  }

  Future<void> _startGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) { return; }
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 20,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() => _userPos = LatLng(pos.latitude, pos.longitude));
        }
      });
    } catch (_) {}
  }

  void _centerOnUser() {
    if (_userPos == null) return;
    try {
      _mapCtrl.move(_userPos!, 13);
    } catch (_) {}
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1000),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Réinitialiser ?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text(
          'Votre progression sur "${route.name}" sera effacée.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.55))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réinitialiser',
                style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final empty = await _progressSvc.resetProgress(
          route.id, route.keyStages.length);
      setState(() => _progress = empty);
    }
  }

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.30],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
              title: Text(route.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppTheme.label),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  tooltip: 'Naviguer',
                  icon: const Icon(Icons.navigation_rounded,
                      size: 22, color: AppTheme.primary),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PilgrimageNavigatorScreen(route: route),
                    ),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStats(),
                  const SizedBox(height: 16),

                  // ── Progression ─────────────────────────────
                  if (_progress != null) ...[
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                  ],

                  // ── Carte ───────────────────────────────────
                  _sectionLabel('TRACÉ DU CHEMIN'),
                  const SizedBox(height: 10),
                  _buildMap(),
                  const SizedBox(height: 6),
                  _buildMapDisclaimer(),
                  _buildPoiFilters(),
                  const SizedBox(height: 28),

                  // ── Étapes ──────────────────────────────────
                  _sectionLabel('ÉTAPES CLÉS'),
                  const SizedBox(height: 4),
                  _buildStagesHint(),
                  const SizedBox(height: 12),
                  _buildTimeline(),
                  const SizedBox(height: 24),
                  _buildTip(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Carte + POIs
  // ────────────────────────────────────────────────────────────
  Widget _buildMap() {
    final displayPoints =
        (_osmPoints != null && _osmPoints!.isNotEmpty)
            ? _osmPoints!
            : route.polyline;
    if (displayPoints.isEmpty) return const SizedBox.shrink();

    double minLat = displayPoints.first.latitude;
    double maxLat = displayPoints.first.latitude;
    double minLng = displayPoints.first.longitude;
    double maxLng = displayPoints.first.longitude;
    for (final p in displayPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds =
        LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    final hasOsm = _osmPoints != null && _osmPoints!.isNotEmpty;

    // Build visible POI markers
    final albergues = (_showAlbergues && _pois != null)
        ? _pois!.where((p) => p.type == 'albergue').toList()
        : <PilgrimPoi>[];
    final waters = (_showWater && _pois != null)
        ? _pois!.where((p) => p.type == 'water').toList()
        : <PilgrimPoi>[];
    final churches = (_showChurches && _pois != null)
        ? _pois!.where((p) => p.type == 'church').toList()
        : <PilgrimPoi>[];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 380,
            child: FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(40),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Fond OSM
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cathoapp.lumen',
                ),

                // Tracé
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: displayPoints,
                      color: AppTheme.primary,
                      strokeWidth: hasOsm ? 2.5 : 3.5,
                    ),
                  ],
                ),

                // ── POI : Albergues ──────────────────────────
                if (albergues.isNotEmpty)
                  MarkerLayer(
                    markers: albergues
                        .map((p) => _poiMarker(p,
                            const Color(0xFF5E5CE6), Icons.bed_rounded))
                        .toList(),
                  ),

                // ── POI : Eau ────────────────────────────────
                if (waters.isNotEmpty)
                  MarkerLayer(
                    markers: waters
                        .map((p) => _poiMarker(p,
                            const Color(0xFF30B0C7), Icons.water_drop_rounded))
                        .toList(),
                  ),

                // ── POI : Églises ────────────────────────────
                if (churches.isNotEmpty)
                  MarkerLayer(
                    markers: churches
                        .map((p) => _poiMarker(
                            p, AppTheme.primary, Icons.church_rounded))
                        .toList(),
                  ),

                // ── Marqueurs départ / arrivée / GPS ─────────
                MarkerLayer(
                  markers: [
                    Marker(
                      point: displayPoints.first,
                      width: 28,
                      height: 28,
                      child: _routePin(
                          const Color(0xFF34C759), Icons.hiking),
                    ),
                    Marker(
                      point: displayPoints.last,
                      width: 28,
                      height: 28,
                      child: _routePin(
                          AppTheme.primary, Icons.place_rounded),
                    ),
                    if (_userPos != null)
                      Marker(
                        point: _userPos!,
                        width: 22,
                        height: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007AFF)
                                    .withValues(alpha: 0.45),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Indicateur de chargement tracé
        if (_osmLoading)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _mapBadge(
                Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  const Text('Chargement du tracé…',
                      style:
                          TextStyle(fontSize: 11, color: Colors.white)),
                ]),
              ),
            ),
          ),

        // Indicateur de chargement POIs
        if (_poisLoading && !_osmLoading)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _mapBadge(
                Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        color: const Color(0xFF5E5CE6), strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  const Text('Chargement des POIs…',
                      style:
                          TextStyle(fontSize: 11, color: Colors.white)),
                ]),
              ),
            ),
          ),

        // Bouton GPS
        if (_userPos != null)
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _centerOnUser,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // ── Filtres POI ────────────────────────────────────────────
  Widget _buildMapDisclaimer() {
    final isOsm = _osmPoints != null && _osmPoints!.isNotEmpty;
    return Row(
      children: [
        Icon(
          isOsm
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
          size: 12,
          color: isOsm
              ? AppTheme.primary.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.28),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            isOsm
                ? 'Tracé officiel OpenStreetMap · ${_osmPoints!.length} points GPS'
                : 'Tracé approximatif. Source : OpenStreetMap.',
            style: TextStyle(
              fontSize: 11,
              color: isOsm
                  ? AppTheme.primary.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.28),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoiFilters() {
    final hasPois = _pois != null && _pois!.isNotEmpty;
    if (!_poisLoading && !hasPois) return const SizedBox.shrink();

    final albergueCount =
        _pois?.where((p) => p.type == 'albergue').length ?? 0;
    final waterCount =
        _pois?.where((p) => p.type == 'water').length ?? 0;
    final churchCount =
        _pois?.where((p) => p.type == 'church').length ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _PoiChip(
            icon: Icons.bed_rounded,
            label: 'Albergues',
            count: albergueCount,
            color: const Color(0xFF5E5CE6),
            active: _showAlbergues,
            loading: _poisLoading,
            onTap: () =>
                setState(() => _showAlbergues = !_showAlbergues),
          ),
          const SizedBox(width: 8),
          _PoiChip(
            icon: Icons.water_drop_rounded,
            label: 'Eau',
            count: waterCount,
            color: const Color(0xFF30B0C7),
            active: _showWater,
            loading: _poisLoading,
            onTap: () => setState(() => _showWater = !_showWater),
          ),
          const SizedBox(width: 8),
          _PoiChip(
            icon: Icons.church_rounded,
            label: 'Églises',
            count: churchCount,
            color: AppTheme.primary,
            active: _showChurches,
            loading: _poisLoading,
            onTap: () =>
                setState(() => _showChurches = !_showChurches),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Progression (Phase 2)
  // ────────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    final p = _progress!;
    final approxKm = (p.fraction * route.distanceKm).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.13),
            AppTheme.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded,
                  size: 13, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text('MON AVANCEMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.2,
                  )),
              const Spacer(),
              Text('${p.completedCount}/${p.totalCount} étapes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: -0.3,
                  )),
              if (p.hasStarted) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _confirmReset,
                  child: Icon(Icons.refresh_rounded,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.28)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p.fraction,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary),
            ),
          ),
          const SizedBox(height: 10),
          if (p.hasStarted)
            Row(children: [
              Text('~$approxKm km parcourus',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.55))),
              if (p.startedAt != null) ...[
                const SizedBox(width: 10),
                Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('Démarré le ${_fmtDate(p.startedAt!)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.35))),
              ],
            ])
          else
            Text('Tapez une étape pour commencer votre suivi',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.38))),
          if (p.isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    width: 0.5),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.emoji_events_rounded,
                    size: 15, color: AppTheme.primary),
                SizedBox(width: 7),
                Text('Pèlerinage accompli !',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Timeline
  // ────────────────────────────────────────────────────────────
  Widget _buildStagesHint() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        'Tapez une étape pour la marquer comme accomplie',
        style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.30),
            fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: route.keyStages.asMap().entries.map((e) {
        final index = e.key;
        final stage = e.value;
        final isLast = index == route.keyStages.length - 1;
        final isCompleted =
            _progress?.stagesCompleted[index] ?? false;
        return _StageRow(
          stage: stage,
          isLast: isLast,
          index: index,
          isCompleted: isCompleted,
          onToggle: () => _toggleStage(index),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  En-tête, Stats, Conseil
  // ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(route.latinName,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary.withValues(alpha: 0.75),
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(route.origin,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.label)),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(
                            alpha: i < 3 ? 0.80 - i * 0.15 : 0.20),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    width: 0.5),
              ),
              child: Text(route.end,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(route.description,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.60),
                height: 1.55)),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
            child: _StatBlock(
                icon: Icons.straighten_rounded,
                value: '${route.distanceKm} km',
                label: 'Distance')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatBlock(
                icon: Icons.nights_stay_rounded,
                value: '${route.stages} étapes',
                label: 'Durée')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatBlock(
                icon: Icons.directions_walk_rounded,
                value: '~${route.stages} j.',
                label: 'À pied')),
      ],
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 16,
              color: AppTheme.primary.withValues(alpha: 0.60)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Le credential (passeport du pèlerin) se tampon à chaque étape. '
              'Il permet d\'obtenir la Compostela à Santiago de Compostela, '
              'attestant l\'accomplissement du pèlerinage.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                  height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.35),
              letterSpacing: 1.2)),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Helpers
  // ────────────────────────────────────────────────────────────
  Marker _poiMarker(PilgrimPoi poi, Color color, IconData icon) {
    return Marker(
      point: LatLng(poi.lat, poi.lng),
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.40),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 10, color: Colors.white),
      ),
    );
  }

  Widget _routePin(Color color, IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }

  Widget _mapBadge(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ── Bloc stat ──────────────────────────────────────────────────
class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBlock(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 18, color: AppTheme.primary.withValues(alpha: 0.80)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.label,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.40))),
        ],
      ),
    );
  }
}

// ── Chip filtre POI ────────────────────────────────────────────
class _PoiChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  const _PoiChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.40)
                : Colors.white.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color: active
                    ? color
                    : Colors.white.withValues(alpha: 0.35)),
            const SizedBox(width: 5),
            if (loading)
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? color
                          : Colors.white.withValues(alpha: 0.38)))
            else
              Text('$count $label',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? color
                          : Colors.white.withValues(alpha: 0.38))),
            if (loading) ...[
              const SizedBox(width: 5),
              SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                      color: color, strokeWidth: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Ligne d'étape ──────────────────────────────────────────────
class _StageRow extends StatelessWidget {
  final PilgrimStage stage;
  final bool isLast;
  final int index;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const _StageRow({
    required this.stage,
    required this.isLast,
    required this.index,
    this.isCompleted = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primary
                          : stage.isSanctuary
                              ? AppTheme.primary.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.primary.withValues(alpha: 0.60)
                            : stage.isSanctuary
                                ? AppTheme.primary.withValues(alpha: 0.40)
                                : Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white)
                          : stage.isSanctuary
                              ? Icon(Icons.star_rounded,
                                  size: 10,
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.80))
                              : null,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        margin:
                            const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isCompleted
                                  ? AppTheme.primary
                                      .withValues(alpha: 0.50)
                                  : AppTheme.primary
                                      .withValues(alpha: 0.20),
                              AppTheme.primary.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stage.city,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? AppTheme.primary
                                  : stage.isSanctuary
                                      ? AppTheme.label
                                      : AppTheme.label
                                          .withValues(alpha: 0.80),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          _badge('Accomplie', AppTheme.primary)
                        else if (stage.isSanctuary)
                          _badge('Sanctuaire',
                              AppTheme.primary.withValues(alpha: 0.80)),
                      ],
                    ),
                    if (stage.detail != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        stage.detail!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted
                              ? Colors.white.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.40),
                          height: 1.40,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
