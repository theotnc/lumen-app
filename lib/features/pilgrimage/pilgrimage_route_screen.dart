import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import 'pilgrimage_data.dart';

class PilgrimageRouteScreen extends StatelessWidget {
  final PilgrimRoute route;
  const PilgrimageRouteScreen({super.key, required this.route});

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
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── En-tête ────────────────────────────────
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // ── Stats ──────────────────────────────────
                  _buildStats(),
                  const SizedBox(height: 20),

                  // ── Carte du chemin ───────────────────────
                  _sectionLabel('TRACÉ DU CHEMIN'),
                  const SizedBox(height: 10),
                  _buildMap(),
                  const SizedBox(height: 6),
                  _buildMapDisclaimer(),
                  const SizedBox(height: 28),

                  // ── Étapes clés ───────────────────────────
                  _sectionLabel('ÉTAPES CLÉS'),
                  const SizedBox(height: 16),
                  _buildTimeline(),

                  const SizedBox(height: 24),

                  // ── Conseil ───────────────────────────────
                  _buildTip(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── En-tête avec nom latin et trajet ──────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          route.latinName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary.withValues(alpha: 0.75),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                route.origin,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.label,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: i < 3 ? 0.80 - i * 0.15 : 0.20),
                      shape: BoxShape.circle,
                    ),
                  ),
                )),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.30),
                  width: 0.5,
                ),
              ),
              child: Text(
                route.end,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          route.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.60),
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ── Blocs de stats ─────────────────────────────────────
  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatBlock(
            icon: Icons.straighten_rounded,
            value: '${route.distanceKm} km',
            label: 'Distance',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBlock(
            icon: Icons.nights_stay_rounded,
            value: '${route.stages} étapes',
            label: 'En France',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBlock(
            icon: Icons.directions_walk_rounded,
            value: '~${route.stages} j.',
            label: 'À pied',
          ),
        ),
      ],
    );
  }

  // ── Timeline des étapes ────────────────────────────────
  Widget _buildTimeline() {
    return Column(
      children: route.keyStages.asMap().entries.map((e) {
        final index = e.key;
        final stage = e.value;
        final isLast = index == route.keyStages.length - 1;
        return _StageRow(stage: stage, isLast: isLast, index: index);
      }).toList(),
    );
  }

  // ── Carte avec tracé du chemin ─────────────────────────
  Widget _buildMap() {
    final points = route.polyline;
    if (points.isEmpty) return const SizedBox.shrink();

    // Calcul de la boîte englobante
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 230,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(36),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            // Fond de carte OSM
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.lumen.catho_app',
            ),

            // Tracé du chemin en or
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: AppTheme.primary,
                  strokeWidth: 3.5,
                ),
              ],
            ),

            // Marqueur départ (vert)
            MarkerLayer(
              markers: [
                Marker(
                  point: points.first,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
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
                    child: const Icon(Icons.hiking, size: 14, color: Colors.white),
                  ),
                ),
                // Marqueur arrivée (or)
                Marker(
                  point: points.last,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
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
                    child: const Icon(Icons.place_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapDisclaimer() {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded,
            size: 12, color: Colors.white.withValues(alpha: 0.28)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Tracé approximatif (~15 points). Source : OpenStreetMap.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.28),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Conseil pratique ───────────────────────────────────
  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 16, color: AppTheme.primary.withValues(alpha: 0.60)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Le credential (passeport du pèlerin) se tampon à chaque étape. '
              'Il permet d\'obtenir la Compostela à Santiago de Compostela, '
              'attestant l\'accomplissement du pèlerinage.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.45),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Bloc stat ──────────────────────────────────────────────
class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatBlock({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary.withValues(alpha: 0.80)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.label,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ligne de timeline ──────────────────────────────────────
class _StageRow extends StatelessWidget {
  final PilgrimStage stage;
  final bool isLast;
  final int index;
  const _StageRow({required this.stage, required this.isLast, required this.index});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: stage.isSanctuary
                        ? AppTheme.primary
                        : Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stage.isSanctuary
                          ? AppTheme.primary.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.30),
                            AppTheme.primary.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
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
                            color: stage.isSanctuary
                                ? AppTheme.label
                                : AppTheme.label.withValues(alpha: 0.80),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (stage.isSanctuary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Sanctuaire',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (stage.detail != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      stage.detail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
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
    );
  }
}
