import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/community_models.dart';
import '../../core/services/community_service.dart';
import '../../core/theme.dart';
import 'new_prayer_screen.dart';
import 'new_post_screen.dart';
import 'forum_thread_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _tab = 0; // 0 = Prières, 1 = Forum

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0A00), Color(0xFF000000)],
            stops: [0.0, 0.4],
          ),
        ),
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────
            _buildAppBar(topPad),

            // ── Contenu ───────────────────────────────────
            Expanded(
              child: _tab == 0
                  ? _PrayersFeed(onAdd: _addPrayer)
                  : _ForumFeed(onAdd: _addPost),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.07),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          width: 0.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.people_outline_rounded,
                          size: 18, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ensemble',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.label,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Tab selector
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10), width: 0.5),
                ),
                child: Row(
                  children: [
                    _TabPill(label: 'Prières', selected: _tab == 0,
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _tab = 0); }),
                    _TabPill(label: 'Forum', selected: _tab == 1,
                        onTap: () { HapticFeedback.selectionClick(); setState(() => _tab = 1); }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPrayer() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const NewPrayerScreen()));
  }

  void _addPost() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const NewPostScreen()));
  }
}

// ── Onglet sélecteur ──────────────────────────────────────
class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22), width: 0.5),
                )
              : const BoxDecoration(),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.label : AppTheme.sublabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// FEED PRIÈRES
// ════════════════════════════════════════════════════════════
class _PrayersFeed extends StatefulWidget {
  final VoidCallback onAdd;
  const _PrayersFeed({required this.onAdd});

  @override
  State<_PrayersFeed> createState() => _PrayersFeedState();
}

class _PrayersFeedState extends State<_PrayersFeed> {
  final Map<String, bool> _animating = {};

  Future<void> _pray(CommunityPrayer prayer, List<CommunityPrayer> list) async {
    if (prayer.hasPrayed) return;
    HapticFeedback.mediumImpact();
    setState(() => _animating[prayer.id] = true);
    await CommunityService().togglePrayer(prayer.id);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _animating.remove(prayer.id));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityPrayer>>(
      stream: CommunityService().prayersStream(),
      builder: (context, snap) {
        final prayers = snap.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _AddButton(label: 'Partager une prière', onTap: widget.onAdd),
            if (prayers.isEmpty)
              const _EmptyStatePrayers()
            else
              ...prayers.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PrayerCard(
                      prayer: p,
                      animating: _animating[p.id] == true,
                      onPray: () => _pray(p, prayers),
                    ),
                  )),
          ],
        );
      },
    );
  }
}

// ── Carte prière ──────────────────────────────────────────
class _PrayerCard extends StatelessWidget {
  final CommunityPrayer prayer;
  final bool animating;
  final VoidCallback onPray;
  const _PrayerCard({required this.prayer, required this.animating, required this.onPray});

  @override
  Widget build(BuildContext context) {
    final initial = prayer.authorName.isNotEmpty
        ? prayer.authorName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.09), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auteur
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4400), AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayer.authorName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppTheme.label)),
                    Text(timeAgo(prayer.createdAt),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.35))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Texte
          Text(
            prayer.text,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.82),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 14),

          // Bouton prière
          GestureDetector(
            onTap: onPray,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: prayer.hasPrayed
                    ? AppTheme.primary.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: prayer.hasPrayed
                      ? AppTheme.primary.withValues(alpha: 0.40)
                      : Colors.white.withValues(alpha: 0.10),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: animating ? 1.4 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: Text(
                      '🙏',
                      style: TextStyle(
                          fontSize: prayer.hasPrayed ? 15 : 14),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    prayer.hasPrayed
                        ? 'Vous priez avec eux'
                        : '${prayer.prayerCount} ${prayer.prayerCount <= 1 ? 'personne prie' : 'personnes prient'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: prayer.hasPrayed
                          ? AppTheme.primary
                          : Colors.white.withValues(alpha: 0.55),
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

// ════════════════════════════════════════════════════════════
// FEED FORUM
// ════════════════════════════════════════════════════════════
class _ForumFeed extends StatelessWidget {
  final VoidCallback onAdd;
  const _ForumFeed({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ForumPost>>(
      stream: CommunityService().postsStream(),
      builder: (context, snap) {
        final posts = snap.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _AddButton(label: 'Partager une réflexion', onTap: onAdd),
            if (posts.isEmpty)
              const _EmptyStateForum()
            else
              ...posts.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ForumCard(post: p),
                  )),
          ],
        );
      },
    );
  }
}

// ── Carte forum ───────────────────────────────────────────
class _ForumCard extends StatelessWidget {
  final ForumPost post;
  const _ForumCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ForumThreadScreen(post: post)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.09), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.label,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(post.authorName,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.40))),
                      Text('  ·  ',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.20))),
                      Text(timeAgo(post.createdAt),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.35))),
                      if (post.replyCount > 0) ...[
                        Text('  ·  ',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.20))),
                        Icon(Icons.reply_rounded,
                            size: 12,
                            color: AppTheme.primary.withValues(alpha: 0.70)),
                        const SizedBox(width: 3),
                        Text('${post.replyCount}',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primary.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.white.withValues(alpha: 0.20)),
          ],
        ),
      ),
    );
  }
}

// ── État vide – Prières ───────────────────────────────────
class _EmptyStatePrayers extends StatelessWidget {
  const _EmptyStatePrayers();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Hero card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withValues(alpha: 0.10),
                AppTheme.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.20), width: 0.8),
          ),
          child: Column(
            children: [
              // Glow emoji
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.20), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🙏', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Priez ensemble',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.label,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partagez vos intentions avec la communauté.\nChaque prière partagée unit les cœurs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Feature pills
        Row(
          children: [
            _FeaturePill(icon: Icons.favorite_outline_rounded,  label: 'Intentions'),
            const SizedBox(width: 8),
            _FeaturePill(icon: Icons.people_outline_rounded,    label: 'Communauté'),
            const SizedBox(width: 8),
            _FeaturePill(icon: Icons.auto_awesome_outlined,     label: 'Bénédictions'),
          ],
        ),
        const SizedBox(height: 20),
        // How it works
        _HowItWorksCard(
          steps: const [
            _HowStep(emoji: '✍️', text: 'Écrivez votre intention de prière'),
            _HowStep(emoji: '🙏', text: 'La communauté prie avec vous'),
            _HowStep(emoji: '✨', text: 'Voyez combien de personnes prient'),
          ],
        ),
      ],
    );
  }
}

// ── État vide – Forum ─────────────────────────────────────
class _EmptyStateForum extends StatelessWidget {
  const _EmptyStateForum();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.10), width: 0.8),
          ),
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                ),
                child: const Center(
                  child: Icon(Icons.chat_bubble_outline_rounded,
                      size: 30, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Exprimez-vous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.label,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partagez une réflexion, un témoignage,\nune question ou une pensée du jour.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _FeaturePill(icon: Icons.lightbulb_outline_rounded, label: 'Réflexions'),
            const SizedBox(width: 8),
            _FeaturePill(icon: Icons.volunteer_activism_outlined, label: 'Témoignages'),
            const SizedBox(width: 8),
            _FeaturePill(icon: Icons.chat_bubble_outline_rounded, label: 'Échanges'),
          ],
        ),
        const SizedBox(height: 20),
        _HowItWorksCard(
          steps: const [
            _HowStep(emoji: '✍️', text: 'Partagez un message, une question ou une réflexion'),
            _HowStep(emoji: '🤝', text: 'La communauté réagit et répond'),
            _HowStep(emoji: '✨', text: 'Grandissez ensemble dans la foi'),
          ],
        ),
      ],
    );
  }
}

// ── Sous-widgets état vide ────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.09), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.55),
                )),
          ],
        ),
      ),
    );
  }
}

class _HowStep {
  final String emoji;
  final String text;
  const _HowStep({required this.emoji, required this.text});
}

class _HowItWorksCard extends StatelessWidget {
  final List<_HowStep> steps;
  const _HowItWorksCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMMENT ÇA MARCHE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.30),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: e.key < steps.length - 1 ? 10 : 0),
                child: Row(
                  children: [
                    Text(e.value.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.60),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Bouton ajouter ────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.18),
                AppTheme.primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.35), width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
