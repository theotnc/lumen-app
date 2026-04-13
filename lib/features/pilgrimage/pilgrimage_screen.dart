import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'pilgrimage_data.dart';
import 'pilgrimage_route_screen.dart';

class PilgrimageScreen extends StatelessWidget {
  const PilgrimageScreen({super.key});

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
            stops: [0.0, 0.35],
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
              title: const Text('Pèlerinage'),
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

                  // ── Hero ─────────────────────────────────────
                  _buildHero(),

                  const SizedBox(height: 32),

                  // ── Chemins français ──────────────────────────
                  _sectionLabel('CHEMINS FRANÇAIS'),
                  const SizedBox(height: 12),
                  ...kPilgrimRoutes
                      .where((r) => r.region == PilgrimRegion.france)
                      .map((route) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteCard(
                      route: route,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PilgrimageRouteScreen(route: route),
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 12),

                  // ── Caminos espagnols ──────────────────────────
                  _sectionLabel('CAMINOS ESPAGNOLS'),
                  const SizedBox(height: 4),
                  _infoNote('Ces chemins mènent jusqu\'à la cathédrale de Santiago de Compostela, tombeau de saint Jacques apôtre.'),
                  ...kPilgrimRoutes
                      .where((r) => r.region == PilgrimRegion.espagne)
                      .map((route) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteCard(
                      route: route,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PilgrimageRouteScreen(route: route))),
                    ),
                  )),

                  const SizedBox(height: 12),

                  // ── Europe ────────────────────────────────────
                  _sectionLabel('EUROPE'),
                  const SizedBox(height: 4),
                  _infoNote('Via Francigena vers Rome, Fátima, Assise… Les grands pèlerinages du continent.'),
                  ...kPilgrimRoutes
                      .where((r) => r.region == PilgrimRegion.europe)
                      .map((route) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteCard(
                      route: route,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PilgrimageRouteScreen(route: route))),
                    ),
                  )),

                  const SizedBox(height: 12),

                  // ── Monde ─────────────────────────────────────
                  _sectionLabel('MONDE'),
                  const SizedBox(height: 4),
                  _infoNote('Rome, Jérusalem… Les pèlerinages fondateurs de la foi chrétienne.'),
                  ...kPilgrimRoutes
                      .where((r) => r.region == PilgrimRegion.monde)
                      .map((route) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteCard(
                      route: route,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PilgrimageRouteScreen(route: route))),
                    ),
                  )),

                  const SizedBox(height: 24),

                  // ── Prière ────────────────────────────────────
                  _sectionLabel('PRIÈRE DU PÈLERIN'),
                  const SizedBox(height: 12),
                  _buildPrayerCard(),

                  const SizedBox(height: 24),

                  // ── Info Ostabat ──────────────────────────────
                  _buildInfoCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero section ───────────────────────────────────────
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.18),
            AppTheme.primary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.32),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.hiking, color: AppTheme.primary, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chemins de\nSaint-Jacques',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.label,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Compostelle',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Quatre grands chemins français mènent au tombeau de l\'apôtre Jacques en Galice. Ils convergent tous vers les Pyrénées en traversant le Sud-Ouest de la France.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.55,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatChip(label: '9 chemins'),
              const SizedBox(width: 8),
              _StatChip(label: '~6 400 km'),
              const SizedBox(width: 8),
              _StatChip(label: 'Depuis le XI\u1d49 s.'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Prière du pèlerin ──────────────────────────────────
  Widget _buildPrayerCard() {
    const prayer =
        'Seigneur Dieu, tu m\'as appelé à partir.\n\n'
        'Ouvre tes chemins devant moi. Donne-moi la force de marcher jusqu\'à Saint-Jacques.\n\n'
        'Que ce pèlerinage soit pour moi un temps de conversion, de prière et de fraternité.\n\n'
        'Protège-moi de tous dangers. Donne-moi ce dont j\'ai besoin.\n\n'
        'Permets-moi de revenir transformé, pour repartir à ma mission.\n\n'
        'Amen.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PRIÈRE TRADITIONNELLE DU PÈLERIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '«',
            style: TextStyle(
              fontSize: 44,
              height: 0.8,
              color: AppTheme.primary.withValues(alpha: 0.35),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            prayer,
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: AppTheme.label,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info pratique ──────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: AppTheme.primary.withValues(alpha: 0.60)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Les chemins Via Podiensis, Turonensis et Lemovicensis convergent à Ostabat-Asme (Pays Basque) avant de rejoindre Saint-Jean-Pied-de-Port. La Via Tolosana passe par le Somport. Tous mènent à Saint-Jacques-de-Compostelle.',
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

  Widget _infoNote(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.50),
          height: 1.45,
        ),
      ),
    );
  }
}

// ── Carte chemin ───────────────────────────────────────────
class _RouteCard extends StatelessWidget {
  final PilgrimRoute route;
  final VoidCallback onTap;
  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final glassDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.10),
        width: 0.5,
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Icon(route.icon, size: 22, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.label,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  route.latinName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary.withValues(alpha: 0.65),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      route.origin,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 11,
                          color: AppTheme.primary.withValues(alpha: 0.60)),
                    ),
                    Expanded(
                      child: Text(
                        route.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  route.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Chip(label: '${route.distanceKm} km'),
                    const SizedBox(width: 6),
                    _Chip(label: '${route.stages} étapes'),
                    const SizedBox(width: 6),
                    _Chip(label: '~${route.stages} jours'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right,
                size: 20, color: Colors.white.withValues(alpha: 0.22)),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(decoration: glassDecoration),
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}

// ── Chip stat ──────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.22),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Petit chip ─────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.60),
        ),
      ),
    );
  }
}
