import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/church.dart';
import '../../core/services/church_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme.dart';
import 'church_detail_screen.dart';

class ChurchesScreen extends StatefulWidget {
  const ChurchesScreen({super.key});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen>
    with TickerProviderStateMixin {
  // ── Data ─────────────────────────────────────────────────
  List<Church> _churches = [];
  bool _loading = true;
  double _radius = 5.0;
  LatLng? _userLocation;   // position GPS réelle
  LatLng? _centerLocation; // centre actuel de recherche (ville ou GPS)
  String? _cityLabel;      // nom de la ville recherchée (null = autour de moi)
  Church? _selected;
  String _search = '';

  // Verrou anti-race-condition : on ignore tout résultat d'un _load obsolète
  int _loadVersion = 0;

  // Recherche par ville dans la floating bar
  bool _citySearchActive = false;
  String _cityQuery = '';
  bool _geocoding = false;

  final _radii = [5.0, 10.0, 25.0, 50.0];

  // ── Controllers ──────────────────────────────────────────
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _sheetController = DraggableScrollableController();

  // Animation pulse utilisateur (limitée à 48 fps)
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _load();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    _cityCtrl.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  // ── Load autour d'un centre donné ────────────────────────
  Future<void> _load({LatLng? center, String? cityLabel}) async {
    final version = ++_loadVersion;
    // Capturer le rayon AU MOMENT du lancement — il ne doit plus changer après
    final radius = _radius;
    setState(() { _loading = true; _selected = null; });

    if (cityLabel != null) {
      // Phase 1 : données locales instantanées (carte immédiatement peuplée)
      final local = ChurchService().fetchLocalImmediate(center!, radius);
      if (!mounted || version != _loadVersion) return;
      if (local.isNotEmpty) setState(() { _churches = local; });

      // Phase 2 : OSM + Firestore (cache → instant si déjà chargé)
      final churches = await ChurchService().fetchNearby(
        position: center,
        radiusKm: radius,
      );
      if (!mounted || version != _loadVersion) return;
      setState(() {
        _centerLocation = center;
        _cityLabel = cityLabel;
        _churches = _applyRadiusFilter(churches, center, radius);
        _loading = false;
      });
      try { _mapController.move(center, 13); } catch (_) {}
      return;
    }

    // Mode GPS — demander la position réelle EN PREMIER (en parallèle)
    final gpsRequest = LocationService().getCurrentLocation();

    // Phase 1 : pendant que le GPS répond, montrer les données locales
    // uniquement si on a déjà une position GPS connue (retour sur l'écran)
    final defaultPos = LocationService.defaultLocation;
    if (_userLocation != null) {
      final cached = _centerLocation ?? _userLocation!;
      final local = ChurchService().fetchLocalImmediate(cached, radius);
      if (!mounted || version != _loadVersion) return;
      if (local.isNotEmpty) setState(() { _churches = local; });
    }

    // Phase 2 : attendre la position GPS réelle
    final realPos = await gpsRequest;
    if (!mounted || version != _loadVersion) return;

    final gpsCenter = realPos ?? defaultPos;
    final usingFallback = realPos == null;

    // Phase 3 : charger les églises autour de la vraie position
    final churches = await ChurchService().fetchNearby(
      position: gpsCenter,
      radiusKm: radius,
    );
    if (!mounted || version != _loadVersion) return;
    setState(() {
      _userLocation = gpsCenter;
      _centerLocation = gpsCenter;
      _churches = _applyRadiusFilter(churches, gpsCenter, radius);
      _loading = false;
      if (usingFallback) _cityLabel = 'Position par défaut';
    });
    try { _mapController.move(gpsCenter, 13); } catch (_) {}
  }

  // ── Filtre distance strict — utilise le rayon capturé, jamais this._radius
  List<Church> _applyRadiusFilter(
      List<Church> churches, LatLng center, double radiusKm) {
    final svc = ChurchService();
    return churches
        .where((c) => svc.distanceKm(center, c) <= radiusKm)
        .toList();
  }

  // ── Recherche géocodée d'une ville ───────────────────────
  Future<void> _searchCity() async {
    final query = _cityQuery.trim();
    if (query.isEmpty) return;
    setState(() { _geocoding = true; });
    final result = await ChurchService().geocodeCity(query);
    if (!mounted) return;
    setState(() { _geocoding = false; _citySearchActive = false; _cityCtrl.clear(); _cityQuery = ''; });
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ville introuvable : $query'),
          backgroundColor: const Color(0xFF1C1C1E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final (pos, label) = result;
    await _load(center: pos, cityLabel: label);
  }

  // ── Revenir à ma position ─────────────────────────────────
  void _resetToMyLocation() {
    setState(() { _cityLabel = null; _centerLocation = _userLocation; });
    _load();
  }

  void _select(Church c) {
    setState(() => _selected = c);
    _mapController.move(c.latLng, 15.5);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.38,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
    }
  }

  void _deselect() {
    setState(() => _selected = null);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.28,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic);
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    // Cache _filtered — ne pas recalculer à chaque accès dans le build
    final filtered = _churches.where((c) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return c.nom.toLowerCase().contains(q) ||
          c.ville.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Carte plein écran avec RepaintBoundary ────────
          // RepaintBoundary isole la carte des repaints de l'UI au-dessus
          Positioned.fill(
            child: RepaintBoundary(child: _buildMap()),
          ),

          // ── AppBar flottante ───────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: _buildFloatingBar(),
          ),

          // ── Bouton recentrer ───────────────────────────────
          Positioned(
            right: 16,
            bottom: botPad + 280,
            child: _buildLocationButton(),
          ),

          // ── Bottom sheet ───────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.28,
            minChildSize: 0.11,
            maxChildSize: 0.82,
            snap: true,
            snapSizes: const [0.11, 0.28, 0.55, 0.82],
            builder: (_, scrollController) =>
                _buildSheet(scrollController, botPad, filtered),
          ),
        ],
      ),
    );
  }

  // ── Map ───────────────────────────────────────────────────
  Widget _buildMap() {
    final center = _userLocation ?? LocationService.defaultLocation;
    // Filtre de sécurité : on ne rend que les marqueurs dans le rayon courant
    final displayCenter = _centerLocation ?? _userLocation ?? LocationService.defaultLocation;
    final svc = ChurchService();
    final displayChurches = _churches
        .where((c) => svc.distanceKm(displayCenter, c) <= _radius)
        .toList();
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        onTap: (_, _) => _deselect(),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Tuiles Carto dark — sans retinaMode (divise par 2 la bande passante)
        // Sans _darkerTile ColorFiltered (supprime un calque de composition par tuile)
        TileLayer(
          urlTemplate:
              'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.cathoapp.bible',
        ),

        // Halo de rayon — centré sur le centre actif (ville ou GPS)
        CircleLayer(
            circles: [
              CircleMarker(
                point: displayCenter,
                radius: _radius * 1000,
                useRadiusInMeter: true,
                color: AppTheme.primary.withValues(alpha: 0.04),
                borderColor: AppTheme.primary.withValues(alpha: 0.25),
                borderStrokeWidth: 1.0,
              ),
            ],
          ),

        // Marqueurs églises
        MarkerLayer(
          markers: displayChurches.map((church) {
            final isSel = _selected?.id == church.id;
            return Marker(
              point: church.latLng,
              width: isSel ? 56 : 42,
              height: isSel ? 56 : 42,
              child: GestureDetector(
                onTap: () => _select(church),
                child: _ChurchMarker(selected: isSel),
              ),
            );
          }).toList(),
        ),

        // Marqueur utilisateur pulsant — RepaintBoundary pour isoler l'animation
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                width: 48,
                height: 48,
                child: RepaintBoundary(
                  child: _UserMarker(animation: _pulseAnim),
                ),
              ),
            ],
          ),

        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© CartoDB · OpenStreetMap', onTap: () {}),
          ],
          alignment: AttributionAlignment.bottomLeft,
        ),
      ],
    );
  }

  // ── Floating AppBar — Stack pattern (fix web + perf) ─────
  Widget _buildFloatingBar() {
    final canPop = Navigator.canPop(context);
    final content = _citySearchActive
        ? _buildCitySearchRow()
        : Row(
            children: [
              if (canPop) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.label, size: 15),
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                const SizedBox(width: 16),
              const Icon(Icons.church, color: AppTheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: _cityLabel != null
                    ? Row(children: [
                        Expanded(
                          child: Text(
                            _cityLabel!,
                            style: const TextStyle(
                              color: AppTheme.label,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ])
                    : const Text(
                        'Églises',
                        style: TextStyle(
                          color: AppTheme.label,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
              ),
              if (_loading || _geocoding)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2),
                  ),
                )
              else ...[
                _FloatButton(
                  icon: Icons.search_rounded,
                  onTap: () => setState(() { _citySearchActive = true; }),
                ),
                const SizedBox(width: 4),
                _FloatButton(icon: Icons.refresh_rounded, onTap: _load),
              ],
              const SizedBox(width: 4),
            ],
          );

    return SizedBox(
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: kIsWeb
            ? Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E).withValues(alpha: 0.96),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10), width: 0.5),
                ),
                child: content,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.82),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 0.5),
                    ),
                    child: content,
                  ),
                ],
              ),
      ),
    );
  }

  // ── Champ de recherche ville (mode actif dans la floating bar) ──
  Widget _buildCitySearchRow() {
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _cityCtrl,
            autofocus: true,
            style: const TextStyle(color: AppTheme.label, fontSize: 15),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher une ville…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 15),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => setState(() => _cityQuery = v),
            onSubmitted: (_) => _searchCity(),
          ),
        ),
        if (_geocoding)
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
          )
        else
          _FloatButton(
            icon: Icons.search_rounded,
            onTap: _searchCity,
          ),
        _FloatButton(
          icon: Icons.close_rounded,
          onTap: () => setState(() {
            _citySearchActive = false;
            _cityCtrl.clear();
            _cityQuery = '';
          }),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Bouton recentrer — Stack pattern ─────────────────────
  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: () {
        final loc = _userLocation ?? LocationService.defaultLocation;
        _mapController.move(loc, 13);
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: kIsWeb
              ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E).withValues(alpha: 0.96),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.primary, size: 20),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                          color:
                              const Color(0xFF1C1C1E).withValues(alpha: 0.85)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 0.5),
                      ),
                      child: const Icon(Icons.my_location_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Bottom sheet — fond solide (pas de BackdropFilter) ────
  // BackdropFilter sur un fond de carte animée = très coûteux (re-blur chaque frame).
  // Fond quasi-opaque → résultat visuel identique, perf x3-5.
  Widget _buildSheet(
      ScrollController scrollController, double botPad, List<Church> filtered) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E), // solide — pas de BackdropFilter
          // borderRadius géré par ClipRRect — pas ici (incompatible avec Border non-uniforme)
          border: Border(
            top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
          ),
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // Drag handle
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Church sélectionnée
            if (_selected != null)
              SliverToBoxAdapter(
                child: _SelectedChurchCard(
                  church: _selected!,
                  userLocation: _userLocation,
                  onClose: _deselect,
                  onDetail: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ChurchDetailScreen(church: _selected!))),
                ),
              ),

            // Bandeau "Résultats pour [ville]"
            if (_cityLabel != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_city_rounded, size: 14, color: AppTheme.primary.withValues(alpha: 0.80)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Résultats pour $_cityLabel',
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetToMyLocation,
                          child: Row(
                            children: [
                              Icon(Icons.my_location_rounded, size: 13, color: Colors.white.withValues(alpha: 0.50)),
                              const SizedBox(width: 4),
                              Text('Ma position', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.50))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Chips rayon
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    ..._radii.map((r) {
                      final sel = r == _radius;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _radius = r);
                          // Préserver le contexte ville lors du changement de rayon
                          _load(center: _centerLocation, cityLabel: _cityLabel);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppTheme.primary
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.10),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '${r.toInt()} km',
                            style: TextStyle(
                              color: sel
                                  ? const Color(0xFF1C1C1E)
                                  : AppTheme.sublabel,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    Text(
                      '${filtered.length} église${filtered.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Barre de recherche — fond solide
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.35), size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(
                              color: AppTheme.label, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Église, ville...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.25),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      if (_search.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.close_rounded,
                                color: Colors.white.withValues(alpha: 0.35),
                                size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Divider(
                  height: 0.5, color: Colors.white.withValues(alpha: 0.07)),
            ),

            // Liste / loading / empty
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.church_outlined,
                          size: 40,
                          color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text(
                        _search.isNotEmpty
                            ? 'Aucune église trouvée'
                            : 'Aucune église dans ce rayon',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.30),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final c = filtered[i];
                    final isLast = i == filtered.length - 1;
                    final dist = _userLocation != null
                        ? ChurchService().formatDistance(_userLocation!, c)
                        : null;
                    final isSel = _selected?.id == c.id;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _select(c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: isSel
                                ? AppTheme.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppTheme.primary
                                            .withValues(alpha: 0.20)
                                        : Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? AppTheme.primary
                                              .withValues(alpha: 0.40)
                                          : Colors.white
                                              .withValues(alpha: 0.08),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Icon(Icons.church,
                                      color: isSel
                                          ? AppTheme.primary
                                          : Colors.white
                                              .withValues(alpha: 0.45),
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.nom,
                                          style: const TextStyle(
                                            color: AppTheme.label,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(c.ville,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.40),
                                            fontSize: 12,
                                          )),
                                    ],
                                  ),
                                ),
                                if (dist != null)
                                  Text(dist,
                                      style: TextStyle(
                                        color: isSel
                                            ? AppTheme.primary
                                            : Colors.white
                                                .withValues(alpha: 0.35),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      )),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 0.5,
                            indent: 68,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                      ],
                    );
                  },
                  childCount: filtered.length,
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: botPad + 16)),
          ],
        ),
      ),
    );
  }
}

// ── Marqueur église ───────────────────────────────────────
class _ChurchMarker extends StatelessWidget {
  final bool selected;
  const _ChurchMarker({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: selected ? 56 : 42,
          height: selected ? 56 : 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withValues(alpha: selected ? 0.22 : 0.12),
          ),
        ),
        Container(
          width: selected ? 36 : 26,
          height: selected ? 36 : 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppTheme.primary : const Color(0xFF1C1C1E),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.80)
                  : AppTheme.primary,
              width: selected ? 2 : 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.church,
            size: selected ? 20 : 14,
            color: selected ? const Color(0xFF1C1C1E) : AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

// ── Marqueur utilisateur pulsant ──────────────────────────
class _UserMarker extends StatelessWidget {
  final Animation<double> animation;
  const _UserMarker({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44 * animation.value,
            height: 44 * animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary
                  .withValues(alpha: 0.14 * (1 - animation.value * 0.5)),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.55),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte church sélectionnée ─────────────────────────────
class _SelectedChurchCard extends StatelessWidget {
  final Church church;
  final LatLng? userLocation;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const _SelectedChurchCard({
    required this.church,
    required this.userLocation,
    required this.onClose,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final dist = userLocation != null
        ? ChurchService().formatDistance(userLocation!, church)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.church,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          church.nom,
                          style: const TextStyle(
                            color: AppTheme.label,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(church.ville,
                                style: const TextStyle(
                                    color: AppTheme.sublabel, fontSize: 12)),
                            if (dist != null) ...[
                              Text('  ·  ',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.20),
                                      fontSize: 12)),
                              Text(dist,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  )),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.close_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.30)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: onDetail,
                  icon: const Icon(Icons.schedule_rounded, size: 16),
                  label: const Text('Voir les horaires'),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton flottant icône ─────────────────────────────────
class _FloatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FloatButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, size: 20, color: AppTheme.sublabel),
      ),
    );
  }
}
