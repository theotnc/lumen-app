import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/services/local_bible_service.dart';
import '../../core/services/bible_progress_service.dart';
import '../../core/theme.dart';
import 'verse_screen.dart';

class ChapterScreen extends StatefulWidget {
  final BibleBook book;
  const ChapterScreen({super.key, required this.book});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  List<BibleChapter> _chapters = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _chapters = await LocalBibleService().getChapters(widget.book.id); }
    catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _onChapterTap(int index) {
    final chapter = _chapters[index];
    final chNum = int.tryParse(chapter.number) ?? (index + 1);
    final svc = BibleProgressService();
    svc.saveLastRead(widget.book.id, widget.book.name, chNum);
    svc.markChapterRead(widget.book.id, chNum);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => VerseScreen(chapters: _chapters, initialIndex: index),
    ));
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
              title: Text(widget.book.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppTheme.label),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        '${_chapters.length} CHAPITRES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.30),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _chapters.length,
                      itemBuilder: (_, i) {
                        final chapter = _chapters[i];
                        return GestureDetector(
                          onTap: () => _onChapterTap(i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.07),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.10),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    chapter.number,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppTheme.primary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
