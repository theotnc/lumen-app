import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme.dart';
import '../notifications/notification_settings_screen.dart';
import 'edit_profile_screen.dart';
import '../donations/donation_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email ?? 'Utilisateur';
    final initial = name.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1000), Color(0xFF000000)],
            stops: [0.0, 0.35],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar translucide
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
              title: const Text('Profil'),
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                // ── Avatar ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.11),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar : photo ou initiale
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6B4400), Color(0xFFC9A844)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: user?.photoURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(
                                        user!.photoURL!,
                                        fit: BoxFit.cover,
                                        width: 60, height: 60,
                                        errorBuilder: (context, e, s) => Center(
                                          child: Text(initial,
                                              style: const TextStyle(
                                                  color: Color(0xFF1C1C1E),
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w800)),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(initial,
                                          style: const TextStyle(
                                            color: Color(0xFF1C1C1E),
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                          )),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? 'Utilisateur',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.label,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.email ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.sublabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const EditProfileScreen())),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppTheme.primary.withValues(alpha: 0.25),
                                      width: 0.5),
                                ),
                                child: const Text(
                                  'Modifier',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Paramètres ──────────────────────────
                AppGroup(
                  title: 'Paramètres',
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppTheme.primary,
                      label: 'Rappels de prière',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationSettingsScreen())),
                    ),
                    _SettingsTile(
                      icon: Icons.favorite_outline,
                      iconColor: const Color(0xFFFF6B6B),
                      label: 'Soutenir le projet',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const DonationScreen())),
                    ),
                  ],
                ),

                // ── À propos ────────────────────────────
                AppGroup(
                  title: 'À propos',
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.sublabel,
                      label: 'Version',
                      trailing: const Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.sublabel,
                        ),
                      ),
                      showChevron: false,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      iconColor: AppTheme.sublabel,
                      label: 'Politique de confidentialité',
                      onTap: () => launchUrl(
                        Uri.parse('https://telegra.ph/Derni%C3%A8re-mise-%C3%A0-jour--avril-2026-04-12'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.mail_outline_rounded,
                      iconColor: AppTheme.sublabel,
                      label: 'Nous contacter',
                      onTap: () => launchUrl(
                        Uri.parse('mailto:theotnc@gmail.com?subject=Lumen%20-%20Contact'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),

                // ── Compte ──────────────────────────────
                AppGroup(
                  title: 'Compte',
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFFF6B6B),
                      label: 'Se déconnecter',
                      labelColor: const Color(0xFFFF6B6B),
                      showChevron: false,
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Se déconnecter',
                                style: TextStyle(color: AppTheme.label)),
                            content: const Text(
                                'Voulez-vous vraiment vous déconnecter ?',
                                style: TextStyle(color: AppTheme.sublabel)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Annuler',
                                      style: TextStyle(color: AppTheme.sublabel))),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Déconnecter',
                                      style: TextStyle(color: Color(0xFFFF6B6B)))),
                            ],
                          ),
                        );
                        if (ok == true) await AuthService().signOut();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 120),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final bool showChevron;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.showChevron = true,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppTheme.label,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: trailing ??
          (showChevron
              ? Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.25), size: 20)
              : null),
      onTap: onTap,
    );
  }
}
