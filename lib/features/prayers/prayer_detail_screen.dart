import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/prayer.dart';
import '../../core/theme.dart';

class PrayerDetailScreen extends StatefulWidget {
  final Prayer prayer;
  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  double _fontSize = 17;

  @override
  Widget build(BuildContext context) {
    final p = widget.prayer;
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
                  title: Text(p.titre,
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Badges
                      Row(
                        children: [
                          _Badge(
                            icon: Prayer.iconForCategory(p.categorie),
                            text: p.categorie,
                            bg: AppTheme.primary.withValues(alpha: 0.15),
                            fg: AppTheme.primary,
                            border: AppTheme.primary.withValues(alpha: 0.25),
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            text: '${p.longueur} min',
                            bg: Colors.white.withValues(alpha: 0.07),
                            fg: AppTheme.sublabel,
                            border: Colors.white.withValues(alpha: 0.10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (p.description.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.18),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 15,
                                  color: AppTheme.primary.withValues(alpha: 0.65)),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  p.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.62),
                                    height: 1.5,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Texte en glass card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              p.contenu,
                              style: TextStyle(
                                fontSize: _fontSize,
                                height: 1.9,
                                color: Colors.white.withValues(alpha: 0.88),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),

            // Contrôles flottants
            Positioned(
              bottom: 32,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FontBtn(
                          icon: Icons.text_decrease_outlined,
                          onTap: () => setState(
                              () => _fontSize = (_fontSize - 2).clamp(12, 28)),
                        ),
                        Container(width: 0.5, height: 28,
                            color: Colors.white.withValues(alpha: 0.15)),
                        _FontBtn(
                          icon: Icons.text_increase_outlined,
                          onTap: () => setState(
                              () => _fontSize = (_fontSize + 2).clamp(12, 28)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg, fg, border;
  final IconData? icon;
  const _Badge({required this.text, required this.bg, required this.fg, required this.border, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(text,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
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
        child: Icon(icon, size: 20,
            color: Colors.white.withValues(alpha: 0.80)),
      ),
    );
  }
}
