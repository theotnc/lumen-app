import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/models/bible_book_meta.dart';
import '../../core/services/audio_bible_service.dart';
import '../../core/theme.dart';
import 'audio_book_detail_screen.dart';

// ── Couleurs de couverture par groupe ─────────────────────────
const _kGroupColors = [
  [Color(0xFFC49A22), Color(0xFF7A5500)], // Pentateuque — or
  [Color(0xFFA0622A), Color(0xFF5C2A0A)], // Historiques — terre de Sienne
  [Color(0xFF2E8B66), Color(0xFF0A4A30)], // Poésie/Sagesse — vert forêt
  [Color(0xFF9B3030), Color(0xFF550A0A)], // Grands Prophètes — cramoisi
  [Color(0xFF7044A0), Color(0xFF3A1A60)], // Petits Prophètes — pourpre
  [Color(0xFF1857B8), Color(0xFF0A2A72)], // Évangiles — bleu royal
  [Color(0xFF0A6EA0), Color(0xFF033855)], // Actes — bleu océan
  [Color(0xFF254F9B), Color(0xFF0A1F55)], // Lettres Paul — marine
  [Color(0xFF3A5C8E), Color(0xFF142440)], // Autres lettres — ardoise
  [Color(0xFF8B1A1A), Color(0xFF380000)], // Apocalypse — rouge profond
];

class AudioBibleScreen extends StatefulWidget {
  final List<BibleBook> books;
  const AudioBibleScreen({super.key, required this.books});

  @override
  State<AudioBibleScreen> createState() => _AudioBibleScreenState();
}

class _AudioBibleScreenState extends State<AudioBibleScreen> {
  final _audio = AudioBibleService();

  void _openBook(BibleBook book) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => AudioBookDetailScreen(book: book)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bookMap = {for (final b in widget.books) b.id: b};
    final allGroups = [
      ...BibleBookMeta.ancienTestament,
      ...BibleBookMeta.nouveauTestament,
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0800), Color(0xFF000000)],
            stops: [0.0, 0.30],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppTheme.label),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Bible Audio'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                        width: 0.5,
                      ),
                    ),
                    child: const Text(
                      'Crampon 1923',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Pour commencer ───────────────────────────────────
            SliverToBoxAdapter(
              child: _PourCommencer(
                bookMap: bookMap,
                currentBookId: _audio.currentBookId,
                onTap: _openBook,
              ),
            ),

            // ── Séparateur ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    const Text(
                      'Tous les livres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.label,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.books.length} livres',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.38),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Groupes ──────────────────────────────────────────
            ...allGroups.asMap().entries.expand((entry) {
              final groupIndex = entry.key;
              final group = entry.value;
              final groupBooks = group.abbrevs
                  .map((a) => bookMap[a])
                  .whereType<BibleBook>()
                  .toList();
              if (groupBooks.isEmpty) return <Widget>[];

              final colors = _kGroupColors[groupIndex % _kGroupColors.length];

              return [
                // En-tête de groupe
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors[0], colors[1]],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(group.icon, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.label,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${groupBooks.length} livre${groupBooks.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.38),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (group.recommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.30),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Recommandé',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Grille de couvertures
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = groupBooks[index];
                        return _BookCoverCard(
                          book: book,
                          topColor: colors[0],
                          bottomColor: colors[1],
                          groupIcon: group.icon,
                          isActive: book.id == _audio.currentBookId,
                          isRecommended: group.recommended,
                          onTap: () => _openBook(book),
                        );
                      },
                      childCount: groupBooks.length,
                    ),
                  ),
                ),
              ];
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

// ── Section "Pour commencer" ──────────────────────────────────
class _PourCommencer extends StatelessWidget {
  final Map<String, BibleBook> bookMap;
  final String? currentBookId;
  final void Function(BibleBook) onTap;

  const _PourCommencer({
    required this.bookMap,
    required this.currentBookId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const starterColors = [
      [Color(0xFF1857B8), Color(0xFF0A2A72)], // Marc — bleu
      [Color(0xFF7044A0), Color(0xFF3A1A60)], // Psaumes — pourpre
      [Color(0xFFC49A22), Color(0xFF7A5500)], // Genèse — or
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Pour commencer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.label,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Idéal si vous découvrez la Bible',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: BibleBookMeta.starters.length,
            itemBuilder: (context, i) {
              final starter = BibleBookMeta.starters[i];
              final book = bookMap[starter.abbrev];
              if (book == null) return const SizedBox();
              final colors = starterColors[i % starterColors.length];
              final isActive = book.id == currentBookId;

              return GestureDetector(
                onTap: () => onTap(book),
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors[0], colors[1]],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Décoration en fond
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          starter.icon,
                          size: 90,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(starter.icon,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                const Text(
                                  'LECTURE CONSEILLÉE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white54,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                if (isActive) ...[
                                  const Spacer(),
                                  const Icon(Icons.volume_up_rounded,
                                      size: 14, color: Colors.white70),
                                ],
                              ],
                            ),
                            const Spacer(),
                            Text(
                              starter.label,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              starter.pitch,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.60),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Divider(
            color: Colors.white.withValues(alpha: 0.07),
            height: 24,
          ),
        ),
      ],
    );
  }
}

// ── Couverture de livre ───────────────────────────────────────
class _BookCoverCard extends StatelessWidget {
  final BibleBook book;
  final Color topColor;
  final Color bottomColor;
  final IconData groupIcon;
  final bool isActive;
  final bool isRecommended;
  final VoidCallback onTap;

  const _BookCoverCard({
    required this.book,
    required this.topColor,
    required this.bottomColor,
    required this.groupIcon,
    required this.isActive,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = BibleBookMeta.descriptions[book.id] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topColor, bottomColor],
            ),
          ),
          child: Stack(
            children: [
              // Grande initiale décorative en fond
              Positioned(
                right: -4,
                bottom: 38,
                child: Text(
                  book.id.length <= 3
                      ? book.id.toUpperCase()
                      : book.id.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.09),
                    letterSpacing: -3,
                  ),
                ),
              ),

              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icône du groupe
                    Row(
                      children: [
                        Icon(groupIcon,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.55)),
                        if (isActive) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded,
                                size: 11, color: Colors.white),
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Nom du livre
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Description courte
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.58),
                          height: 1.35,
                        ),
                      ),
                  ],
                ),
              ),

              // Ligne dorée en haut pour les Évangiles (recommended)
              if (isRecommended)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFC9A844), Color(0xFFF0D880)],
                      ),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
