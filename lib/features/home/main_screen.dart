import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import '../bible/bible_screen.dart';
import '../prayers/prayers_screen.dart';
import '../community/community_screen.dart';
import '../assistant/assistant_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    BibleScreen(),
    PrayersScreen(),
    CommunityScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(icon: Icons.home_outlined,             activeIcon: Icons.home_rounded,           label: 'Accueil'),
    _NavItem(icon: Icons.book_outlined,             activeIcon: Icons.book_rounded,           label: 'Bible'),
    _NavItem(icon: Icons.self_improvement_outlined, activeIcon: Icons.self_improvement,       label: 'Prières'),
    _NavItem(icon: Icons.people_outline_rounded,    activeIcon: Icons.people_rounded,         label: 'Ensemble'),
    _NavItem(icon: Icons.auto_awesome_outlined,     activeIcon: Icons.auto_awesome_rounded,   label: 'Guide'),
    _NavItem(icon: Icons.person_outline,            activeIcon: Icons.person_rounded,         label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 12),
        child: _buildNavPill(),
      ),
    );
  }

  // ── Barre de navigation Liquid Glass ─────────────────────
  // Pattern Stack + Positioned.fill : le BackdropFilter est un calque
  // séparé derrière le contenu. Le Row (boutons) est un frère du blur,
  // pas son enfant — il reste toujours visible sur Flutter Web et mobile.
  Widget _buildNavPill() {
    final row = Row(
      children: _items.asMap().entries.map((e) {
        return Expanded(
          child: _NavButton(
            item: e.value,
            selected: e.key == _currentIndex,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = e.key);
            },
          ),
        );
      }).toList(),
    );

    // borderRadius + Border non-uniforme interdit dans BoxDecoration :
    // ClipRRect gère l'arrondi, pas borderRadius.
    const glassDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x24FFFFFF), Color(0x0FFFFFFF)],
      ),
      border: Border(
        top:    BorderSide(color: Color(0x52FFFFFF), width: 0.7),
        left:   BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
        right:  BorderSide(color: Color(0x0FFFFFFF), width: 0.5),
        bottom: BorderSide(color: Color(0x0AFFFFFF), width: 0.5),
      ),
    );

    return SizedBox(
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Calque blur + verre (aucun enfant de contenu ici)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(decoration: glassDecoration),
            ),
            // Boutons de navigation au-dessus du blur, toujours visibles
            row,
          ],
        ),
      ),
    );
  }
}

// ── Bouton de navigation avec bulle Liquid Glass ──────────
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 10 : 4,
              vertical: selected ? 5 : 4,
            ),
            decoration: selected
                ? BoxDecoration(
                    // Bulle de sélection — Border.all obligatoire avec borderRadius
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : const BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey(selected),
                    color: selected ? AppTheme.primary : AppTheme.sublabel,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? AppTheme.primary : AppTheme.sublabel,
                    letterSpacing: -0.1,
                  ),
                  child: Text(item.label, maxLines: 1, overflow: TextOverflow.clip),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}
