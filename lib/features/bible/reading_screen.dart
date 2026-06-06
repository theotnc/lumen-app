import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/services/local_bible_service.dart';
import '../../core/services/bible_progress_service.dart';
import '../../core/theme.dart';

class ReadingScreen extends StatefulWidget {
  final BibleBook book;
  final int initialChapter;

  const ReadingScreen({
    super.key,
    required this.book,
    this.initialChapter = 1,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final _scrollController = ScrollController();
  List<BibleChapter> _chapters = [];
  List<BiblePassage> _passages = [];
  final List<GlobalKey> _chapterKeys = [];
  Set<int> _readChapters = {};
  bool _loading = true;
  int _currentChapter = 1;
  double _fontSize = 17;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final chapters = await LocalBibleService().getChapters(widget.book.id);
    final passages = await LocalBibleService().getAllChapters(widget.book.id);
    final readChapters = await BibleProgressService().getReadChapters(widget.book.id);
    if (!mounted) return;

    _chapterKeys
      ..clear()
      ..addAll(List.generate(chapters.length, (_) => GlobalKey()));

    setState(() {
      _chapters = chapters;
      _passages = passages;
      _readChapters = readChapters;
      _loading = false;
    });

    if (widget.initialChapter > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToChapter(widget.initialChapter, animate: false);
      });
    }
  }

  void _onScroll() {
    if (!mounted || _chapters.isEmpty) return;
    for (int i = _chapters.length - 1; i >= 0; i--) {
      final ctx = _chapterKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      final threshold = MediaQuery.of(context).padding.top + kToolbarHeight + 30;
      if (dy <= threshold) {
        final newCh = i + 1;
        if (_currentChapter != newCh) {
          setState(() {
            _currentChapter = newCh;
            _readChapters = {..._readChapters, newCh};
          });
          final svc = BibleProgressService();
          svc.saveLastRead(widget.book.id, widget.book.name, newCh);
          svc.markChapterRead(widget.book.id, newCh);
        }
        break;
      }
    }
  }

  void _scrollToChapter(int chNum, {bool animate = true}) {
    if (chNum < 1 || chNum > _chapterKeys.length) return;
    final ctx = _chapterKeys[chNum - 1].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
  }

  void _openChapterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChapterSheet(
        chapters: _chapters,
        currentChapter: _currentChapter,
        readChapters: _readChapters,
        onSelect: (chNum) {
          Navigator.pop(context);
          _scrollToChapter(chNum);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.25],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
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
              title: Text(widget.book.name),
              actions: [
                if (!_loading) ...[
                  IconButton(
                    icon: Icon(Icons.text_decrease_outlined,
                        size: 20, color: Colors.white.withValues(alpha: 0.60)),
                    onPressed: () =>
                        setState(() => _fontSize = (_fontSize - 2).clamp(12, 28)),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(Icons.text_increase_outlined,
                        size: 20, color: Colors.white.withValues(alpha: 0.60)),
                    onPressed: () =>
                        setState(() => _fontSize = (_fontSize + 2).clamp(12, 28)),
                    padding: EdgeInsets.zero,
                  ),
                  GestureDetector(
                    onTap: _openChapterSheet,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4, right: 16),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ch. $_currentChapter',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.expand_more_rounded,
                              size: 15, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (_loading)
              const SliverFillRemaining(
                child:
                    Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(_chapters.length, _buildChapter),
                  ),
                ),
              ),
          ],
        ),
      ),

        ],
      ),
    );
  }

  Widget _buildChapter(int index) {
    final chapter = _chapters[index];
    final passage = _passages[index];

    return Column(
      key: _chapterKeys[index],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête chapitre
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 16),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.28),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  chapter.reference,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.07),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        // Texte des versets
        Text(
          passage.content,
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.9,
            color: Colors.white.withValues(alpha: 0.88),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Feuille de navigation par chapitre ───────────────────────
class _ChapterSheet extends StatelessWidget {
  final List<BibleChapter> chapters;
  final int currentChapter;
  final Set<int> readChapters;
  final void Function(int chNum) onSelect;

  const _ChapterSheet({
    required this.chapters,
    required this.currentChapter,
    required this.readChapters,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.60),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Titre
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${chapters.length} chapitres',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.label,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          // Grille
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: chapters.length,
              itemBuilder: (_, i) {
                final chNum = i + 1;
                final isCurrent = chNum == currentChapter;
                final isRead = readChapters.contains(chNum);
                return GestureDetector(
                  onTap: () => onSelect(chNum),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary.withValues(alpha: 0.22)
                          : isRead
                              ? AppTheme.primary.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primary.withValues(alpha: 0.55)
                            : isRead
                                ? AppTheme.primary.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.08),
                        width: isCurrent ? 1.0 : 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$chNum',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isCurrent
                              ? AppTheme.primary
                              : isRead
                                  ? AppTheme.primary.withValues(alpha: 0.60)
                                  : Colors.white.withValues(alpha: 0.80),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
