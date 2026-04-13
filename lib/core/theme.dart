import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────
  static const Color primary     = Color(0xFFC9A844); // or sacré
  static const Color primaryDark = Color(0xFFA07828); // or profond
  static const Color primarySoft = Color(0x22C9A844); // or translucide

  // Surfaces sombres Apple
  static const Color background      = Color(0xFF000000); // noir OLED
  static const Color surface         = Color(0xFF1C1C1E); // surface sombre
  static const Color surfaceElevated = Color(0xFF2C2C2E); // surface surélevée

  static const Color label     = Color(0xFFFFFFFF);  // blanc
  static const Color sublabel  = Color(0xFF8E8E93);  // gris Apple
  static const Color separator = Color(0xFF38383A);  // séparateur sombre

  // ── Glass ───────────────────────────────────────────────
  static BoxDecoration glassCard({double radius = 18}) => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.07),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.11),
      width: 0.5,
    ),
  );

  static BoxDecoration solidCard({double radius = 18}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.06),
      width: 0.5,
    ),
  );

  // Ombres très légères pour éléments flottants
  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get navShadow => const [
    BoxShadow(color: Color(0x60000000), blurRadius: 40, offset: Offset(0, -4)),
  ];

  // ── Thème ────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      brightness: Brightness.dark,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: label,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF1C1C1E),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: sublabel, fontSize: 15),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        textColor: label,
        iconColor: sublabel,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.5)
              : const Color(0xFF3A3A3C),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: separator,
        space: 1,
        thickness: 0.5,
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: label),
        bodyLarge: TextStyle(color: label),
        titleMedium: TextStyle(color: label),
        titleLarge: TextStyle(color: label, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── AppGroup — section style iOS dark ─────────────────────
class AppGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const AppGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8, top: 24),
              child: Text(
                title!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.sublabel,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          Container(
            decoration: AppTheme.solidCard(radius: 18),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                        height: 0.5,
                        indent: 20,
                        color: AppTheme.separator,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
