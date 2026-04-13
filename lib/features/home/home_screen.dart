import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/rss_service.dart';
import '../../core/theme.dart';
import '../pilgrimage/pilgrimage_screen.dart';
import '../churches/churches_screen.dart';
import '../liturgy/liturgy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NewsArticle> _articles = [];
  bool _loadingNews = true;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    if (mounted) {
      setState(() { _loadingNews = true; _newsError = null; });
    }
    final result = await RssService().fetchNews();
    if (mounted) {
      setState(() {
        _articles = result.articles;
        _newsError = result.error;
        _loadingNews = false;
      });
    }
  }

  // ── Salutation ────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bon matin';
    if (h < 18) return 'Bon après-midi';
    if (h < 22) return 'Bonne soirée';
    return 'Bonne nuit';
  }

  String get _firstName {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? '';
    return name.split(' ').first;
  }

  // ── Date en français ──────────────────────────────────────
  static const _jours = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
  ];
  static const _mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  String get _dateLabel {
    final d = DateTime.now();
    final j = _jours[d.weekday - 1];
    final m = _mois[d.month - 1];
    return '${j[0].toUpperCase()}${j.substring(1)} ${d.day} $m ${d.year}';
  }

  // ── Verset du jour ────────────────────────────────────────
  static const _versets = [
    ('Jean 3:16',
        'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse pas mais ait la vie éternelle.'),
    ('Psaume 23:1',
        'L\'Éternel est mon berger, je ne manquerai de rien. Il me fait reposer dans de verts pâturages.'),
    ('Matthieu 11:28',
        'Venez à moi, vous tous qui êtes fatigués et chargés, et je vous donnerai le repos.'),
    ('Philippiens 4:13',
        'Je puis tout par celui qui me fortifie.'),
    ('Romains 8:28',
        'Toutes choses concourent au bien de ceux qui aiment Dieu, de ceux qui sont appelés selon son dessein.'),
    ('Luc 1:37',
        'Rien n\'est impossible à Dieu.'),
    ('Jean 14:6',
        'Je suis le chemin, la vérité et la vie. Nul ne vient au Père que par moi.'),
    ('1 Jean 4:8',
        'Celui qui n\'aime pas n\'a pas connu Dieu, car Dieu est amour.'),
    ('Psaume 46:2',
        'Dieu est pour nous un refuge et un appui, un secours dans la détresse, toujours présent.'),
    ('Jérémie 29:11',
        'Je connais les projets que j\'ai formés sur vous, des projets de bonheur et non de malheur, afin de vous donner un avenir et de l\'espérance.'),
    ('Galates 5:22',
        'Le fruit de l\'Esprit est amour, joie, paix, patience, bonté, bienveillance, fidélité, douceur, maîtrise de soi.'),
    ('Matthieu 5:3',
        'Heureux les pauvres en esprit, car le royaume des cieux est à eux.'),
    ('Psaume 118:24',
        'C\'est ici la journée que l\'Éternel a faite : qu\'elle soit pour nous un sujet d\'allégresse et de joie.'),
    ('Jean 8:12',
        'Je suis la lumière du monde. Celui qui me suit ne marchera pas dans les ténèbres, mais il aura la lumière de la vie.'),
  ];

  (String, String) get _versetDuJour {
    final index = DateTime.now().dayOfYear % _versets.length;
    return _versets[index];
  }

  // ── Saints du jour ────────────────────────────────────────
  static const Map<String, String> _saints = {
    '01-01': 'Sainte Marie, Mère de Dieu',
    '01-06': 'Épiphanie du Seigneur',
    '01-17': 'Saint Antoine le Grand',
    '01-21': 'Sainte Agnès',
    '01-24': 'Saint François de Sales',
    '01-25': 'Conversion de saint Paul',
    '02-02': 'Présentation du Seigneur',
    '02-03': 'Saint Blaise',
    '02-11': 'Notre-Dame de Lourdes',
    '02-22': 'Chaire de saint Pierre',
    '03-17': 'Saint Patrick',
    '03-19': 'Saint Joseph, époux de Marie',
    '03-25': 'Annonciation du Seigneur',
    '04-23': 'Saint Georges',
    '04-29': 'Sainte Catherine de Sienne',
    '05-01': 'Saint Joseph Travailleur',
    '05-03': 'Saints Philippe et Jacques',
    '05-14': 'Saint Matthias',
    '05-31': 'Visitation de la Vierge Marie',
    '06-13': 'Saint Antoine de Padoue',
    '06-21': 'Saint Louis de Gonzague',
    '06-24': 'Nativité de saint Jean-Baptiste',
    '06-29': 'Saints Pierre et Paul',
    '07-03': 'Saint Thomas',
    '07-11': 'Saint Benoît',
    '07-22': 'Sainte Marie-Madeleine',
    '07-25': 'Saint Jacques',
    '07-26': 'Saints Joachim et Anne',
    '07-29': 'Sainte Marthe',
    '08-06': 'Transfiguration du Seigneur',
    '08-10': 'Saint Laurent',
    '08-15': 'Assomption de la Vierge Marie',
    '08-22': 'Marie Reine',
    '08-24': 'Saint Barthélemy',
    '08-27': 'Sainte Monique',
    '08-28': 'Saint Augustin',
    '08-29': 'Martyre de saint Jean-Baptiste',
    '09-08': 'Nativité de la Vierge Marie',
    '09-14': 'Exaltation de la Sainte Croix',
    '09-15': 'Notre-Dame des Douleurs',
    '09-21': 'Saint Matthieu',
    '09-29': 'Saints Michel, Gabriel et Raphaël',
    '09-30': 'Saint Jérôme',
    '10-01': 'Sainte Thérèse de l\'Enfant-Jésus',
    '10-02': 'Saints Anges gardiens',
    '10-04': 'Saint François d\'Assise',
    '10-07': 'Notre-Dame du Rosaire',
    '10-15': 'Sainte Thérèse d\'Avila',
    '10-18': 'Saint Luc',
    '10-28': 'Saints Simon et Jude',
    '11-01': 'Toussaint',
    '11-02': 'Commémoration des fidèles défunts',
    '11-11': 'Saint Martin de Tours',
    '11-22': 'Sainte Cécile',
    '11-30': 'Saint André',
    '12-03': 'Saint François-Xavier',
    '12-06': 'Saint Nicolas',
    '12-08': 'Immaculée Conception',
    '12-12': 'Notre-Dame de Guadalupe',
    '12-13': 'Sainte Lucie',
    '12-25': 'Nativité du Seigneur — Noël',
    '12-26': 'Saint Étienne',
    '12-27': 'Saint Jean Apôtre et Évangéliste',
    '12-28': 'Saints Innocents',
  };

  String? get _saintDuJour {
    final d = DateTime.now();
    final key =
        '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _saints[key];
  }

  @override
  Widget build(BuildContext context) {
    final (versetRef, versetText) = _versetDuJour;
    final firstName = _firstName;
    final saint = _saintDuJour;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.40],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── AppBar transparent glass ────────────────────
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
              title: Row(
                children: [
                  Icon(Icons.church_rounded,
                      size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Lumen',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppTheme.sublabel, size: 20),
                  onPressed: _loadNews,
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Salutation ────────────────────────────
                  Text(
                    firstName.isEmpty ? _greeting : '$_greeting, $firstName',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.label,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.40),
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Saint du jour ─────────────────────────
                  if (saint != null) ...[
                    _SaintCard(name: saint),
                    const SizedBox(height: 14),
                  ],

                  // ── Verset du jour ────────────────────────
                  _VersetCard(reference: versetRef, text: versetText),

                  const SizedBox(height: 28),

                  // ── Pèlerinage + Églises + Liturgie ──────
                  _PilgrimBanner(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PilgrimageScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickCard(
                          icon: Icons.location_on_rounded,
                          label: 'Églises',
                          subtitle: 'Trouver une messe',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ChurchesScreen())),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickCard(
                          icon: Icons.today_rounded,
                          label: 'Liturgie',
                          subtitle: 'Textes du jour',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LiturgyScreen())),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Actualités ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'ACTUALITÉS CATHOLIQUES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.35),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_loadingNews)
                    const _NewsLoader()
                  else if (_articles.isEmpty)
                    _EmptyNews(onRetry: _loadNews, error: _newsError)
                  else ...[
                    ...List.generate(
                      _articles.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ArticleCard(article: _articles[i]),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Extension dayOfYear ───────────────────────────────────
extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}

// ── Saint du jour ─────────────────────────────────────────
class _SaintCard extends StatelessWidget {
  final String name;
  const _SaintCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.star_rounded, size: 16, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAINT DU JOUR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary.withValues(alpha: 0.70),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.label,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: kIsWeb
          ? inner
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: inner,
            ),
    );
  }
}

// ── Verset du jour ────────────────────────────────────────
class _VersetCard extends StatelessWidget {
  final String reference;
  final String text;
  const _VersetCard({required this.reference, required this.text});

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.20),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VERSET DU JOUR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '«',
            style: TextStyle(
              fontSize: 40,
              height: 0.8,
              color: AppTheme.primary.withValues(alpha: 0.35),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.label,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reference,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: kIsWeb
          ? inner
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: inner,
            ),
    );
  }
}

// ── Carte article ─────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  const _ArticleCard({required this.article});

  Future<void> _open() async {
    if (article.url.isEmpty) return;
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.label,
              height: 1.35,
              letterSpacing: -0.1,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.summary.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              article.summary,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.48),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                article.source,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary.withValues(alpha: 0.80),
                ),
              ),
              if (article.timeAgo.isNotEmpty) ...[
                Text(
                  '  ·  ',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.20)),
                ),
                Text(
                  article.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ],
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 10, color: Colors.white.withValues(alpha: 0.20)),
            ],
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: _open,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: kIsWeb
            ? inner
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: inner,
              ),
      ),
    );
  }
}

// ── Chargement ────────────────────────────────────────────
class _NewsLoader extends StatelessWidget {
  const _NewsLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          3,
          (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                      width: 0.5,
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 1.5),
                    ),
                  ),
                ),
              )),
    );
  }
}

// ── Bannière pèlerinage ───────────────────────────────────
class _PilgrimBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PilgrimBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.15),
              AppTheme.primary.withValues(alpha: 0.06),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.hiking, color: AppTheme.primary, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PÈLERINAGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary.withValues(alpha: 0.70),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Chemins de Saint-Jacques · 22 routes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.label,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.primary.withValues(alpha: 0.50)),
          ],
        ),
      ),
    );
  }
}

// ── Erreur / vide ─────────────────────────────────────────
class _EmptyNews extends StatelessWidget {
  final VoidCallback onRetry;
  final String? error;
  const _EmptyNews({required this.onRetry, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 32, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          const Text(
            'Actualités non disponibles',
            style:
                TextStyle(color: AppTheme.label, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Vérifiez votre connexion internet',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.38)),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.20), width: 0.5),
              ),
              child: Text(
                error!,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 11, color: Colors.redAccent, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte raccourci (Églises / Liturgie) ──────────────────
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.12),
              AppTheme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.22),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.label,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
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
