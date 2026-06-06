import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/models/bible_book_meta.dart';
import '../../core/services/audio_bible_service.dart';
import '../../core/theme.dart';
import 'audio_book_detail_screen.dart';

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
      MaterialPageRoute(builder: (_) => AudioBookDetailScreen(book: book)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bookMap = {for (final b in widget.books) b.id: b};
    final groups = [
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
                      'Louis Segond',
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...groups.expand((group) {
                    final groupBooks = group.abbrevs
                        .map((a) => bookMap[a])
                        .whereType<BibleBook>()
                        .toList();
                    if (groupBooks.isEmpty) return <Widget>[];
                    return [
                      _GroupHeader(group: group),
                      const SizedBox(height: 8),
                      _BookList(
                        books: groupBooks,
                        currentBookId: _audio.currentBookId,
                        onTap: _openBook,
                      ),
                      const SizedBox(height: 24),
                    ];
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── En-tête de groupe ─────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final BibleBookGroup group;
  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.20),
              width: 0.5,
            ),
          ),
          child: Center(
              child: Icon(group.icon, size: 18, color: AppTheme.primary)),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                group.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.40),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Liste de livres ───────────────────────────────────────────
class _BookList extends StatelessWidget {
  final List<BibleBook> books;
  final String? currentBookId;
  final void Function(BibleBook) onTap;

  const _BookList({
    required this.books,
    required this.currentBookId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const glassDecoration = BoxDecoration(
      color: Color(0x0DFFFFFF),
      border: Border(
        top: BorderSide(color: Color(0x17FFFFFF), width: 0.5),
        left: BorderSide(color: Color(0x17FFFFFF), width: 0.5),
        right: BorderSide(color: Color(0x17FFFFFF), width: 0.5),
        bottom: BorderSide(color: Color(0x17FFFFFF), width: 0.5),
      ),
    );

    final bookList = Column(
      children: books.asMap().entries.map((e) {
        final book = e.value;
        final isLast = e.key == books.length - 1;
        final isActive = book.id == currentBookId;

        return Column(
          children: [
            InkWell(
              onTap: () => onTap(book),
              borderRadius: BorderRadius.vertical(
                top: e.key == 0 ? const Radius.circular(16) : Radius.zero,
                bottom: isLast ? const Radius.circular(16) : Radius.zero,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppTheme.primary : AppTheme.label,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    isActive
                        ? const Icon(Icons.volume_up_rounded,
                            size: 16, color: AppTheme.primary)
                        : Icon(Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.22)),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(
                height: 0.5,
                indent: 16,
                color: Colors.white.withValues(alpha: 0.07),
              ),
          ],
        );
      }).toList(),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(decoration: glassDecoration),
            ),
          ),
          bookList,
        ],
      ),
    );
  }
}
