import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/prayer.dart';
import '../../core/theme.dart';
import 'prayers_data.dart';
import 'prayer_detail_screen.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();
  bool _searching = false;

  List<Prayer> get _searchResults => _search.isEmpty
      ? []
      : kAllPrayers
          .where((p) =>
              p.titre.toLowerCase().contains(_search.toLowerCase()) ||
              p.categorie.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  Map<String, List<Prayer>> get _byCategory {
    final m = <String, List<Prayer>>{};
    for (final cat in Prayer.categories) {
      m[cat] = kAllPrayers.where((p) => p.categorie == cat).toList();
    }
    return m;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = _byCategory;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.4],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── AppBar glass ────────────────────────────────
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
              title: _searching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: AppTheme.label, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une prière…',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35)),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    )
                  : const Text(
                      'Prières',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.label,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded,
                    color: AppTheme.sublabel,
                  ),
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) {
                      _searchCtrl.clear();
                      _search = '';
                    }
                  }),
                ),
              ],
            ),

            // ── Résultats de recherche ───────────────────────
            if (_searching && _search.isNotEmpty) ...[
              _searchResults.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text('Aucun résultat',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35))),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _SearchResultTile(prayer: _searchResults[i]),
                          childCount: _searchResults.length,
                        ),
                      ),
                    ),
            ] else ...[
              // ── Contenu principal ────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── En-tête ────────────────────────────
                    _buildHeader(kAllPrayers.length),
                    const SizedBox(height: 28),

                    // ── Section label ─────────────────────
                    _sectionLabel('CATÉGORIES'),
                    const SizedBox(height: 12),

                    // ── Liste des catégories ──────────────
                    ...Prayer.categories.map((cat) {
                      final prayers = byCategory[cat] ?? [];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CategoryRow(
                          category: cat,
                          prayers: prayers,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _CategoryPrayersScreen(
                                category: cat,
                                prayers: prayers,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── En-tête avec icon + stats ────────────────────────────
  Widget _buildHeader(int total) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.26),
              width: 0.5,
            ),
          ),
          child: const Center(
            child: Icon(Icons.self_improvement_rounded,
                color: AppTheme.primary, size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prières',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.label,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$total prières',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${Prayer.categories.length} catégories',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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

// ── Ligne catégorie (glass) ───────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String category;
  final List<Prayer> prayers;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.prayers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Prayer.iconForCategory(category);
    final description = Prayer.descriptionForCategory(category);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
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
                      child: Icon(icon, size: 22, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.label,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${prayers.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.48),
                              height: 1.45,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Résultat de recherche ─────────────────────────────────
class _SearchResultTile extends StatelessWidget {
  final Prayer prayer;
  const _SearchResultTile({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PrayerDetailScreen(prayer: prayer)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Icon(Prayer.iconForCategory(prayer.categorie),
                    size: 18, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.titre,
                    style: const TextStyle(
                      color: AppTheme.label,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayer.categorie,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: Colors.white.withValues(alpha: 0.20)),
          ],
        ),
      ),
    );
  }
}

// ── Écran liste d'une catégorie ───────────────────────────
class _CategoryPrayersScreen extends StatelessWidget {
  final String category;
  final List<Prayer> prayers;
  const _CategoryPrayersScreen(
      {required this.category, required this.prayers});

  @override
  Widget build(BuildContext context) {
    final icon = Prayer.iconForCategory(category);

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
            // ── AppBar glass ──────────────────────────────
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
              title: Text(
                category,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.label,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppTheme.label),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Header catégorie ──────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.26),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(icon, size: 26, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.label,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${prayers.length} ${prayers.length > 1 ? 'prières' : 'prière'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Description explicative
                  Builder(builder: (_) {
                    final desc = Prayer.descriptionForCategory(category);
                    if (desc.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.18),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 15,
                                color: AppTheme.primary.withValues(alpha: 0.65)),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                desc,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.60),
                                  height: 1.5,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Liste des prières (glass card groupée) ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: prayers.asMap().entries.map((e) {
                            final isLast = e.key == prayers.length - 1;
                            return _PrayerTile(
                              prayer: e.value,
                              isLast: isLast,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PrayerDetailScreen(prayer: e.value),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuile prière dans la liste ────────────────────────────
class _PrayerTile extends StatelessWidget {
  final Prayer prayer;
  final bool isLast;
  final VoidCallback onTap;
  const _PrayerTile(
      {required this.prayer, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTap(); },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.titre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.label,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (prayer.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          prayer.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.42),
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${prayer.longueur} min',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Colors.white.withValues(alpha: 0.20)),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 0.5,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.07),
          ),
      ],
    );
  }
}
