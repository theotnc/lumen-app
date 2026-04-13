import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/models/bible_book_meta.dart';
import '../../core/theme.dart';
import 'chapter_screen.dart';

class BookListScreen extends StatelessWidget {
  final List<BibleBook> books;
  final String title;
  final List<BibleBookGroup> groups;

  const BookListScreen({
    super.key,
    required this.books,
    required this.title,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final bookMap = {for (final b in books) b.id: b};

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
              title: Text(title),
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
                  ...groups.expand((group) {
                    final groupBooks = group.abbrevs
                        .map((a) => bookMap[a])
                        .whereType<BibleBook>()
                        .toList();
                    if (groupBooks.isEmpty) return <Widget>[];

                    return [
                      _GroupHeader(group: group),
                      const SizedBox(height: 8),
                      _BookGroup(books: groupBooks, onTap: (book) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChapterScreen(book: book),
                        ));
                      }),
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

// ── En-tête de groupe ─────────────────────────────────────
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
            child: Icon(group.icon, size: 18, color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  if (group.recommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pour commencer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
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

// ── Liste de livres dans un groupe ────────────────────────
class _BookGroup extends StatelessWidget {
  final List<BibleBook> books;
  final void Function(BibleBook) onTap;
  const _BookGroup({required this.books, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final glassDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.09),
        width: 0.5,
      ),
    );

    final bookList = Column(
      children: books.asMap().entries.map((e) {
        final book = e.value;
        final isLast = e.key == books.length - 1;
        final desc = BibleBookMeta.descriptions[book.id];

        return Column(
          children: [
            InkWell(
              onTap: () => onTap(book),
              borderRadius: BorderRadius.vertical(
                top: e.key == 0 ? const Radius.circular(16) : Radius.zero,
                bottom: isLast ? const Radius.circular(16) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.label,
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (desc != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.38),
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
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
