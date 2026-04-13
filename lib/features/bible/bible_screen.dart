import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/models/bible_book_meta.dart';
import '../../core/services/local_bible_service.dart';
import '../../core/services/bible_progress_service.dart';
import '../../core/theme.dart';
import 'book_list_screen.dart';
import 'chapter_screen.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  List<BibleBook> _books = [];
  bool _loading = true;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  List<BibleSearchVerse> _results = [];
  bool _searchLoading = false;

  Map<String, dynamic>? _lastRead;
  int _atRead = 0;
  int _ntRead = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final books = await LocalBibleService().getBooks();
    if (!mounted) return;
    setState(() { _books = books; _loading = false; });
    _loadProgress(books);
  }

  Future<void> _loadProgress([List<BibleBook>? books]) async {
    final b = books ?? _books;
    if (b.isEmpty) return;
    final svc = BibleProgressService();
    final lastRead = await svc.getLastRead();
    final atIds = b.where((x) => x.isOldTestament).map((x) => x.id).toList();
    final ntIds = b.where((x) => !x.isOldTestament).map((x) => x.id).toList();
    final atRead = await svc.countRead(atIds);
    final ntRead = await svc.countRead(ntIds);
    if (mounted) setState(() { _lastRead = lastRead; _atRead = atRead; _ntRead = ntRead; });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) { setState(() => _results = []); return; }
    setState(() => _searchLoading = true);
    try {
      final results = await LocalBibleService().search(query);
      if (mounted) setState(() { _results = results; _searchLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  void _openBook(String abbrev) {
    final book = _books.firstWhere((b) => b.id == abbrev, orElse: () => _books.first);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChapterScreen(book: book),
    )).then((_) => _loadProgress());
  }

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
              title: _searching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: AppTheme.label, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un verset...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onChanged: _search,
                    )
                  : const Text('Bible'),
              actions: [
                IconButton(
                  icon: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded,
                    color: AppTheme.sublabel,
                  ),
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) { _searchCtrl.clear(); _results = []; }
                  }),
                ),
              ],
            ),

            if (_searching)
              _buildSearchSliver()
            else
              _buildHomeSliver(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeSliver() {
    if (_loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    final ot = _books.where((b) => b.isOldTestament).toList();
    final nt = _books.where((b) => !b.isOldTestament).toList();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([

          // ── Reprendre la lecture ────────────────────────
          if (_lastRead != null) ...[
            _buildResumeCard(),
          ],

          // ── Par où commencer ────────────────────────────
          _SectionLabel(text: 'PAR OÙ COMMENCER'),
          const SizedBox(height: 10),
          ...BibleBookMeta.starters.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StarterCard(starter: s, onTap: () => _openBook(s.abbrev)),
          )),

          const SizedBox(height: 24),

          // ── Les deux Testaments ─────────────────────────
          _SectionLabel(text: 'LES DEUX TESTAMENTS'),
          const SizedBox(height: 10),

          _TestamentCard(
            title: 'Ancien Testament',
            description: 'L\'histoire de Dieu avec l\'humanité avant Jésus-Christ. '
                'De la Création aux prophètes qui annoncent le Messie.',
            detail: '${ot.length} livres · Genèse → Malachie',
            icon: Icons.menu_book_rounded,
            readCount: _atRead,
            total: 930,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => BookListScreen(books: ot, title: 'Ancien Testament',
                  groups: BibleBookMeta.ancienTestament),
            )).then((_) => _loadProgress()),
          ),
          const SizedBox(height: 12),
          _TestamentCard(
            title: 'Nouveau Testament',
            description: 'La vie de Jésus, sa mort et sa résurrection. '
                'Les premières communautés chrétiennes et leurs lettres.',
            detail: '${nt.length} livres · Matthieu → Apocalypse',
            icon: Icons.church_rounded,
            readCount: _ntRead,
            total: 260,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => BookListScreen(books: nt, title: 'Nouveau Testament',
                  groups: BibleBookMeta.nouveauTestament),
            )).then((_) => _loadProgress()),
          ),
        ]),
      ),
    );
  }

  Widget _buildResumeCard() {
    final bookName = (_lastRead!['bookName'] as String?) ?? '';
    final chapter = (_lastRead!['chapter'] as int?) ?? 1;
    final bookId = (_lastRead!['bookId'] as String?) ?? '';

    return GestureDetector(
      onTap: () {
        final book = _books.firstWhere(
          (b) => b.id == bookId,
          orElse: () => _books.first,
        );
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChapterScreen(book: book),
        )).then((_) => _loadProgress());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.18),
              AppTheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bookmark_rounded, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REPRENDRE LA LECTURE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary.withValues(alpha: 0.75),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$bookName · Chapitre $chapter',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.label,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_rounded, color: AppTheme.primary, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSliver() {
    if (_searchLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (_results.isEmpty && _searchCtrl.text.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text('Aucun résultat',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35))),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final v = _results[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.solidCard(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.reference,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(v.text,
                      style: const TextStyle(
                          color: AppTheme.label, height: 1.55, fontSize: 14)),
                ],
              ),
            );
          },
          childCount: _results.length,
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
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

// ── Carte "Par où commencer" ──────────────────────────────
class _StarterCard extends StatelessWidget {
  final StarterBook starter;
  final VoidCallback onTap;
  const _StarterCard({required this.starter, required this.onTap});

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Icon(starter.icon, size: 22, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      starter.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.label,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Recommandé',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  starter.pitch,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.50),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: Colors.white.withValues(alpha: 0.25)),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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

// ── Carte Testament avec barre de progression ─────────────
class _TestamentCard extends StatelessWidget {
  final String title;
  final String description;
  final String detail;
  final IconData icon;
  final int readCount;
  final int total;
  final VoidCallback onTap;

  const _TestamentCard({
    required this.title,
    required this.description,
    required this.detail,
    required this.icon,
    required this.readCount,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glassDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.07),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.11),
        width: 0.5,
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Center(child: Icon(icon, size: 26, color: AppTheme.primary)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.label,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: total > 0 ? readCount / total : 0,
                          backgroundColor: Colors.white.withValues(alpha: 0.10),
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$readCount / $total ch.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.25), size: 20),
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
