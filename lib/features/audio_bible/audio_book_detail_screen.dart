import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/bible_models.dart';
import '../../core/services/audio_bible_service.dart';
import '../../core/services/local_bible_service.dart';
import '../../core/theme.dart';

class AudioBookDetailScreen extends StatefulWidget {
  final BibleBook book;
  const AudioBookDetailScreen({super.key, required this.book});

  @override
  State<AudioBookDetailScreen> createState() => _AudioBookDetailScreenState();
}

class _AudioBookDetailScreenState extends State<AudioBookDetailScreen> {
  final _audio = AudioBibleService();
  List<BibleChapter> _chapters = [];
  bool _loading = true;
  bool _audioLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters = await LocalBibleService().getChapters(widget.book.id);
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _loading = false;
    });
  }

  Future<void> _playChapter(int chNum) async {
    if (_audioLoading) return;
    final ref = _chapters[chNum - 1].reference;

    // Même chapitre → toggle play/pause
    if (_audio.currentBookId == widget.book.id &&
        _audio.currentChapter == chNum) {
      if (_audio.player.playing) {
        await _audio.pause();
      } else {
        await _audio.resume();
      }
      setState(() {});
      return;
    }

    setState(() => _audioLoading = true);
    await _audio.playChapter(widget.book.id, chNum, ref);
    if (mounted) setState(() => _audioLoading = false);
  }

  Future<void> _togglePlayer() async {
    if (_audioLoading) return;
    if (_audio.player.playing) {
      await _audio.pause();
    } else {
      final proc = _audio.player.processingState;
      if (proc != ProcessingState.idle && proc != ProcessingState.completed) {
        await _audio.resume();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Fond ────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0800), Color(0xFF000000)],
                stops: [0.0, 0.35],
              ),
            ),
          ),

          // ── Liste des chapitres ──────────────────────────────
          CustomScrollView(
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
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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

              if (_loading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary)),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 140),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ChapterRow(
                        chapter: _chapters[index],
                        chapterNumber: index + 1,
                        isPlaying: _audio.currentBookId == widget.book.id &&
                            _audio.currentChapter == index + 1 &&
                            _audio.player.playing,
                        isLoaded: _audio.currentBookId == widget.book.id &&
                            _audio.currentChapter == index + 1,
                        isLoading: _audioLoading &&
                            _audio.currentBookId == widget.book.id &&
                            (_audio.currentChapter == index + 1 ||
                                _audio.currentChapter == null),
                        onTap: () => _playChapter(index + 1),
                      ),
                      childCount: _chapters.length,
                    ),
                  ),
                ),
            ],
          ),

          // ── Player fixe en bas ───────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPad + 16,
            child: _BottomPlayer(
              audio: _audio,
              loading: _audioLoading,
              bookName: widget.book.name,
              onTap: _togglePlayer,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ligne chapitre ────────────────────────────────────────────
class _ChapterRow extends StatelessWidget {
  final BibleChapter chapter;
  final int chapterNumber;
  final bool isPlaying;
  final bool isLoaded;
  final bool isLoading;
  final VoidCallback onTap;

  const _ChapterRow({
    required this.chapter,
    required this.chapterNumber,
    required this.isPlaying,
    required this.isLoaded,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            // ── Numéro / icône ─────────────────────────────
            SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppTheme.primary, strokeWidth: 2),
                      )
                    : isPlaying
                        ? _SoundBars()
                        : Text(
                            '$chapterNumber',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isLoaded
                                  ? AppTheme.primary
                                  : Colors.white.withValues(alpha: 0.28),
                              letterSpacing: -0.5,
                            ),
                          ),
              ),
            ),

            // ── Texte ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.reference,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isLoaded ? FontWeight.w600 : FontWeight.w400,
                      color: isLoaded
                          ? AppTheme.label
                          : Colors.white.withValues(alpha: 0.75),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bouton play ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 22,
                color: isLoaded
                    ? AppTheme.primary
                    : Colors.white.withValues(alpha: 0.20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barres de son animées ─────────────────────────────────────
class _SoundBars extends StatefulWidget {
  @override
  State<_SoundBars> createState() => _SoundBarsState();
}

class _SoundBarsState extends State<_SoundBars>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    final heights = [0.4, 0.7, 1.0, 0.6];
    final delays = [0, 150, 80, 220];
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + i * 80),
      )..repeat(reverse: true),
    );
    _anims = List.generate(
      4,
      (i) => Tween<double>(begin: 0.25, end: heights[i]).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      ),
    );
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: delays[i]), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(4, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (ctx, _) => Container(
            width: 3,
            height: 20 * _anims[i].value,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Player fixe en bas ────────────────────────────────────────
class _BottomPlayer extends StatelessWidget {
  final AudioBibleService audio;
  final bool loading;
  final String bookName;
  final VoidCallback onTap;

  const _BottomPlayer({
    required this.audio,
    required this.loading,
    required this.bookName,
    required this.onTap,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.13),
              width: 0.6,
            ),
          ),
          child: StreamBuilder<PlayerState>(
            stream: audio.player.playerStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;
              final proc =
                  state?.processingState ?? ProcessingState.idle;
              final hasAudio = proc != ProcessingState.idle &&
                  proc != ProcessingState.completed;
              final isBuffering = proc == ProcessingState.loading ||
                  proc == ProcessingState.buffering;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Icône livre
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.28),
                            width: 0.6,
                          ),
                        ),
                        child: const Icon(Icons.headphones_rounded,
                            color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),

                      // Titre
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audio.currentReference ?? bookName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: audio.currentReference != null
                                    ? AppTheme.label
                                    : Colors.white.withValues(alpha: 0.35),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Crampon 1923 · Livre entier',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary
                                    .withValues(alpha: 0.60),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton play/pause
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppTheme.primary.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: loading || isBuffering
                              ? Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primary,
                                      strokeWidth: 2),
                                )
                              : Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: audio.currentReference != null
                                      ? AppTheme.primary
                                      : AppTheme.primary
                                          .withValues(alpha: 0.35),
                                  size: 28,
                                ),
                        ),
                      ),
                    ],
                  ),

                  // Barre de progression
                  if (hasAudio) ...[
                    const SizedBox(height: 12),
                    StreamBuilder<Duration>(
                      stream: audio.player.positionStream,
                      builder: (context, posSnap) {
                        final position = posSnap.data ?? Duration.zero;
                        final duration =
                            audio.player.duration ?? Duration.zero;
                        final progress = duration.inMilliseconds > 0
                            ? (position.inMilliseconds /
                                    duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0;
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2.5,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5.5),
                                overlayShape:
                                    SliderComponentShape.noOverlay,
                                activeTrackColor: AppTheme.primary,
                                inactiveTrackColor: Colors.white
                                    .withValues(alpha: 0.15),
                                thumbColor: AppTheme.primary,
                              ),
                              child: Slider(
                                value: progress,
                                onChanged: (v) =>
                                    audio.player.seek(Duration(
                                        milliseconds: (v *
                                                duration.inMilliseconds)
                                            .toInt())),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_fmt(position),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white
                                              .withValues(alpha: 0.38))),
                                  Text(_fmt(duration),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white
                                              .withValues(alpha: 0.38))),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
