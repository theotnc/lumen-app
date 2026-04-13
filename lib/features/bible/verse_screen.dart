import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/bible_models.dart';
import '../../core/services/local_bible_service.dart';
import '../../core/theme.dart';

class VerseScreen extends StatefulWidget {
  final List<BibleChapter> chapters;
  final int initialIndex;
  const VerseScreen({
    super.key,
    required this.chapters,
    required this.initialIndex,
  });

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  late int _index;
  BiblePassage? _passage;
  bool _loading = true;
  double _fontSize = 17;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _load();
  }

  BibleChapter get _chapter => widget.chapters[_index];

  Future<void> _load() async {
    setState(() { _loading = true; _passage = null; });
    try { _passage = await LocalBibleService().getChapter(_chapter.id); }
    catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _goTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.chapters.length) return;
    setState(() => _index = newIndex);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final hasPrev = _index > 0;
    final hasNext = _index < widget.chapters.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.25],
          ),
        ),
        child: Stack(
          children: [
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
                  title: Text(_chapter.reference,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.label)),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppTheme.label),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(color: AppTheme.primary)),
                  )
                else if (_passage == null)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('Chapitre indisponible',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35))),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Carte texte — Stack pattern pour blur web
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
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _chapter.reference,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _passage!.content,
                                      style: TextStyle(
                                        fontSize: _fontSize,
                                        height: 1.9,
                                        color: Colors.white.withValues(alpha: 0.88),
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                    if (_passage!.copyright != null) ...[
                                      const SizedBox(height: 24),
                                      Divider(color: Colors.white.withValues(alpha: 0.08)),
                                      const SizedBox(height: 12),
                                      Text(
                                        _passage!.copyright!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.25),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),

            // Contrôles flottants
            if (!_loading && _passage != null)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _NavBtn(
                      icon: Icons.arrow_back_ios_rounded,
                      label: hasPrev
                          ? 'Ch. ${widget.chapters[_index - 1].number}'
                          : '',
                      enabled: hasPrev,
                      onTap: () => _goTo(_index - 1),
                      align: TextAlign.left,
                    ),
                    const SizedBox(width: 10),
                    // Boutons taille texte — Stack pattern
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FontBtn(
                                icon: Icons.text_decrease_outlined,
                                onTap: () => setState(
                                    () => _fontSize = (_fontSize - 2).clamp(12, 28)),
                              ),
                              Container(
                                  width: 0.5,
                                  height: 28,
                                  color: Colors.white.withValues(alpha: 0.15)),
                              _FontBtn(
                                icon: Icons.text_increase_outlined,
                                onTap: () => setState(
                                    () => _fontSize = (_fontSize + 2).clamp(12, 28)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NavBtn(
                      icon: Icons.arrow_forward_ios_rounded,
                      label: hasNext
                          ? 'Ch. ${widget.chapters[_index + 1].number}'
                          : '',
                      enabled: hasNext,
                      onTap: () => _goTo(_index + 1),
                      align: TextAlign.right,
                      iconRight: true,
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

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final TextAlign align;
  final bool iconRight;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.align,
    this.iconRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: Colors.white.withValues(alpha: enabled ? 0.10 : 0.04),
      border: Border.all(
        color: Colors.white.withValues(alpha: enabled ? 0.15 : 0.06),
        width: 0.5,
      ),
    );

    final content = GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: iconRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: iconRight
                ? [
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(
                              alpha: enabled ? 0.70 : 0.20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon,
                        size: 12,
                        color: Colors.white
                            .withValues(alpha: enabled ? 0.70 : 0.20)),
                  ]
                : [
                    Icon(icon,
                        size: 12,
                        color: Colors.white
                            .withValues(alpha: enabled ? 0.70 : 0.20)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(
                              alpha: enabled ? 0.70 : 0.20),
                        ),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(decoration: decoration),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _FontBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FontBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.80)),
      ),
    );
  }
}
