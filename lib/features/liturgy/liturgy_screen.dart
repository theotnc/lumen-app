import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/liturgical_day.dart';
import '../../core/services/liturgical_service.dart';
import '../../core/theme.dart';

class LiturgyScreen extends StatefulWidget {
  const LiturgyScreen({super.key});

  @override
  State<LiturgyScreen> createState() => _LiturgyScreenState();
}

class _LiturgyScreenState extends State<LiturgyScreen> {
  LiturgicalDay? _day;
  bool _apiLoaded = false;
  bool _apiError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _apiError = false);
    final local = LiturgicalDay.local(DateTime.now());
    setState(() => _day = local);
    try {
      final full = await LiturgicalService().getDay(DateTime.now());
      if (mounted) setState(() { _day = full; _apiLoaded = true; });
    } catch (_) {
      if (mounted) setState(() { _apiLoaded = true; _apiError = true; });
    }
  }

  // ── Description de la saison pour les novices ─────────────
  static String _seasonDescription(String key) {
    switch (key) {
      case 'avent':
        return 'L\'Avent dure 4 semaines avant Noël. C\'est un temps d\'attente et de préparation à la venue du Christ — sa naissance à Noël, mais aussi son retour attendu à la fin des temps.';
      case 'noel':
        return 'Le temps de Noël va du 25 décembre jusqu\'au Baptême du Seigneur (début janvier). On célèbre la naissance de Jésus et les mystères de son enfance.';
      case 'careme':
        return 'Le Carême dure 40 jours avant Pâques, comme les 40 jours de Jésus au désert. C\'est un temps de prière, de jeûne et de partage pour se préparer à la résurrection.';
      case 'paques':
        return 'Le temps de Pâques dure 50 jours, de la résurrection du Christ jusqu\'à la Pentecôte. C\'est le cœur de toute l\'année chrétienne.';
      default: // temps_ordinaire
        return 'Le Temps Ordinaire est la plus longue période de l\'année. Ce n\'est pas une période «sans intérêt» — c\'est un temps de croissance spirituelle au quotidien, où l\'on approfondit l\'enseignement de Jésus.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = _day;
    final accent = day?.accentColor ?? AppTheme.primary;
    final bgTint = day?.bgTintColor ?? const Color(0xFF1A1000);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTint, const Color(0xFF000000)],
            stops: const [0.0, 0.45],
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
              title: const Text(
                'Liturgie du jour',
                style: TextStyle(
                  color: AppTheme.label,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              automaticallyImplyLeading: false,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.label, size: 18),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              actions: [
                if (!_apiLoaded)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 1.5),
                    ),
                  ),
              ],
            ),

            if (day == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Bandeau hors-ligne ─────────────────
                    if (_apiError) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.30),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                size: 15, color: Colors.orange.withValues(alpha: 0.80)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lectures du jour non disponibles — vérifiez votre connexion.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.withValues(alpha: 0.85),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _load,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Réessayer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.withValues(alpha: 0.90),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Bloc intro ─────────────────────────
                    _IntroCard(accent: accent),
                    const SizedBox(height: 12),

                    // ── Guide Liturgie de la Parole ────────
                    _WordLiturgyGuide(accent: accent),
                    const SizedBox(height: 16),

                    // ── En-tête saison ─────────────────────
                    _SeasonHeader(
                      day: day,
                      accent: accent,
                      description: _seasonDescription(day.seasonKey),
                    ),
                    const SizedBox(height: 20),

                    // ── Première lecture (① dans la messe) ─
                    if (day.reading1Ref != null) ...[
                      _LectureCard(
                        order: 1,
                        label: 'PREMIÈRE LECTURE',
                        subtitle: 'Un texte de la Bible (Ancien ou Nouveau Testament) qui éclaire et prépare l\'évangile du jour.',
                        ref: day.reading1Ref!,
                        title: day.reading1Title,
                        text: day.reading1Text,
                        accent: accent,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Psaume (② dans la messe) ───────────
                    if (day.psalmRef != null) ...[
                      _LectureCard(
                        order: 2,
                        label: 'PSAUME RESPONSORIAL',
                        subtitle: 'Chanté ou récité après la première lecture. L\'assemblée répond au chantre par un refrain.',
                        ref: day.psalmRef!,
                        title: null,
                        text: day.psalmText,
                        accent: accent,
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Évangile (③ dans la messe) ─────────
                    if (day.gospelRef != null) ...[
                      _LectureCard(
                        order: 3,
                        label: 'ÉVANGILE DU JOUR',
                        subtitle: 'Moment le plus solennel — l\'assemblée se lève. Lu par le prêtre ou le diacre.',
                        ref: day.gospelRef!,
                        title: day.gospelTitle,
                        text: day.gospelText,
                        accent: accent,
                        isGospel: true,
                      ),
                      const SizedBox(height: 12),
                    ] else if (!_apiLoaded) ...[
                      _PlaceholderCard(accent: accent),
                      const SizedBox(height: 12),
                    ],

                    // ── Saint du jour ──────────────────────
                    if (day.saintName != null) ...[
                      _SaintCard(name: day.saintName!, accent: accent),
                      const SizedBox(height: 12),
                    ],

                    // ── Couleurs liturgiques ───────────────
                    const SizedBox(height: 8),
                    _ColorsGuide(accent: accent),

                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bloc d'introduction ───────────────────────────────────
class _IntroCard extends StatelessWidget {
  final Color accent;
  const _IntroCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: accent.withValues(alpha: 0.60)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Chaque jour, l\'Église catholique propose à tous les fidèles du monde les mêmes textes à lire et méditer. C\'est ce qu\'on appelle la liturgie du jour.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.50),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── En-tête de saison ─────────────────────────────────────
class _SeasonHeader extends StatelessWidget {
  final LiturgicalDay day;
  final Color accent;
  final String description;
  const _SeasonHeader({
    required this.day,
    required this.accent,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.15),
            accent.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                day.seasonName.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
              if (day.liturgicalYear.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accent.withValues(alpha: 0.22), width: 0.5),
                  ),
                  child: Text(
                    'Année ${day.liturgicalYear}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            day.dayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.label,
              letterSpacing: -0.4,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(day.date),
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.40)),
          ),
          const SizedBox(height: 14),
          // ── Description de la saison ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];
  static const _mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];
  String _formatDate(DateTime d) =>
      '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]} ${d.year}';
}

// ── Carte lecture ─────────────────────────────────────────
class _LectureCard extends StatefulWidget {
  final int order; // position dans la messe (1, 2, 3)
  final String label;
  final String subtitle;
  final String ref;
  final String? title;
  final String? text;
  final Color accent;
  final bool isGospel;
  final bool compact;

  const _LectureCard({
    required this.order,
    required this.label,
    required this.subtitle,
    required this.ref,
    required this.title,
    required this.text,
    required this.accent,
    this.isGospel = false,
    this.compact = false,
  });

  @override
  State<_LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends State<_LectureCard> {
  bool _expanded = false;
  static const int _previewChars = 280;

  @override
  Widget build(BuildContext context) {
    final hasText = widget.text != null && widget.text!.isNotEmpty;
    final needsTruncation = hasText && widget.text!.length > _previewChars;
    final displayText = hasText
        ? (_expanded || !needsTruncation
            ? widget.text!
            : '${widget.text!.substring(0, _previewChars).trimRight()}…')
        : null;

    return Container(
      padding: EdgeInsets.all(widget.isGospel ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: widget.isGospel ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(widget.isGospel ? 20 : 16),
        border: Border.all(
          color: widget.isGospel
              ? widget.accent.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge numéro d'ordre
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1, right: 10),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${widget.order}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: widget.accent,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: widget.accent.withValues(alpha: 0.80),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.38),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.ref,
                      style: TextStyle(
                        fontSize: widget.isGospel ? 20 : 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.label,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isGospel) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book_rounded, size: 18, color: widget.accent),
                ),
              ],
            ],
          ),

          if (widget.title != null && widget.title!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.title!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],

          if (displayText != null) ...[
            SizedBox(height: widget.compact ? 8.0 : 12.0),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 14,
                height: 1.65,
                color: Colors.white.withValues(alpha: 0.72),
                letterSpacing: -0.1,
              ),
            ),
            if (needsTruncation) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Réduire ▲' : 'Lire la suite ▼',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.accent,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Placeholder chargement réseau ─────────────────────────
class _PlaceholderCard extends StatelessWidget {
  final Color accent;
  const _PlaceholderCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(color: accent, strokeWidth: 1.5),
          ),
          const SizedBox(width: 14),
          Text(
            'Chargement de l\'évangile…',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }
}

// ── Saint du jour ─────────────────────────────────────────
class _SaintCard extends StatelessWidget {
  final String name;
  final Color accent;
  const _SaintCard({required this.name, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.22), width: 0.5),
            ),
            child: Center(child: Icon(Icons.star_rounded, size: 18, color: accent)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAINT DU JOUR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent.withValues(alpha: 0.75),
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chaque jour, l\'Église fait mémoire d\'un saint. Ces hommes et femmes ont vécu leur foi de façon exemplaire.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.38),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.label,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guide "Quand lire ces textes ?" ──────────────────────
class _WordLiturgyGuide extends StatefulWidget {
  final Color accent;
  const _WordLiturgyGuide({required this.accent});

  @override
  State<_WordLiturgyGuide> createState() => _WordLiturgyGuideState();
}

class _WordLiturgyGuideState extends State<_WordLiturgyGuide> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.help_outline_rounded,
                        size: 14, color: widget.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quand et comment lire ces textes ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            Divider(height: 0.5, color: Colors.white.withValues(alpha: 0.07)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avant la messe ──
                  _GuideSection(
                    icon: Icons.wb_twilight_rounded,
                    color: widget.accent,
                    title: 'Avant la messe',
                    text: 'Lire les textes à l\'avance prépare votre cœur et vous aide à mieux comprendre l\'homélie (le commentaire du prêtre). Beaucoup de catholiques les lisent le matin ou la veille.',
                  ),
                  const SizedBox(height: 16),

                  // ── Pendant la messe ──
                  _GuideSection(
                    icon: Icons.church_rounded,
                    color: widget.accent,
                    title: 'Pendant la messe — dans cet ordre',
                    text: null,
                  ),
                  const SizedBox(height: 10),
                  _MassStep(
                    number: '1',
                    accent: widget.accent,
                    title: 'Première lecture',
                    detail: 'Lu par un fidèle (le lecteur). L\'assemblée est assise.',
                  ),
                  _MassStep(
                    number: '2',
                    accent: widget.accent,
                    title: 'Psaume responsorial',
                    detail: 'Chanté ou récité. Le chantre dit un verset, l\'assemblée répond par un refrain.',
                  ),
                  _MassStep(
                    number: '3',
                    accent: widget.accent,
                    title: 'Évangile',
                    detail: 'Lu par le prêtre ou le diacre. Tout le monde se lève — c\'est le moment le plus solennel de la Liturgie de la Parole.',
                    isLast: false,
                  ),
                  _MassStep(
                    number: '→',
                    accent: widget.accent,
                    title: 'Homélie',
                    detail: 'Le prêtre commente les textes et les relie à la vie d\'aujourd\'hui. L\'assemblée est assise.',
                    isLast: true,
                  ),
                  const SizedBox(height: 16),

                  // ── Après la messe ──
                  _GuideSection(
                    icon: Icons.self_improvement_rounded,
                    color: widget.accent,
                    title: 'Après la messe',
                    text: 'Méditez l\'évangile du jour. Posez-vous la question : que me dit ce texte dans ma vie en ce moment ?',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? text;
  const _GuideSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color.withValues(alpha: 0.70)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.label,
                ),
              ),
              if (text != null) ...[
                const SizedBox(height: 4),
                Text(
                  text!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.50),
                    height: 1.55,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MassStep extends StatelessWidget {
  final String number;
  final Color accent;
  final String title;
  final String detail;
  final bool isLast;
  const _MassStep({
    required this.number,
    required this.accent,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne verticale + badge
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: accent.withValues(alpha: 0.30), width: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: accent.withValues(alpha: 0.18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.label,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guide des couleurs liturgiques ────────────────────────
class _ColorsGuide extends StatefulWidget {
  final Color accent;
  const _ColorsGuide({required this.accent});

  @override
  State<_ColorsGuide> createState() => _ColorsGuideState();
}

class _ColorsGuideState extends State<_ColorsGuide> {
  bool _open = false;

  static const _colors = [
    (Color(0xFF27AE60), 'Vert',   'Temps Ordinaire — croissance spirituelle au quotidien'),
    (Color(0xFF9B59B6), 'Violet', 'Avent et Carême — attente, pénitence, préparation'),
    (Color(0xFFC9A844), 'Blanc',  'Noël, Pâques, solennités — joie et lumière'),
    (Color(0xFFE74C3C), 'Rouge',  'Pentecôte et fêtes des martyrs — feu de l\'Esprit'),
    (Color(0xFFE91E8C), 'Rose',   '3e dim. Avent (Gaudete) · 4e dim. Carême (Laetare) — joie au cœur de l\'attente'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined,
                      size: 16, color: Colors.white.withValues(alpha: 0.35)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'À quoi correspondent les couleurs ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
                  Icon(
                    _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            Divider(height: 0.5, color: Colors.white.withValues(alpha: 0.07)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: _colors.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: c.$1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.$1.withValues(alpha: 0.45),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.50),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: '${c.$2}  ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.label,
                                ),
                              ),
                              TextSpan(text: c.$3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
