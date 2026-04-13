import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _enabled = true;
  final Set<int> _hours = {12, 18};
  bool _loading = false;

  static const _hourLabels = {
    6: ('Laudes', '6h00'),
    9: ('Tierce', '9h00'),
    12: ('Angélus', '12h00'),
    15: ('None', '15h00'),
    18: ('Vêpres', '18h00'),
    21: ('Complies', '21h00'),
  };

  static const _recommended = {12, 18};

  Future<void> _apply() async {
    setState(() => _loading = true);
    if (_enabled) {
      await NotificationService().scheduleAll(_hours.toList());
    } else {
      await NotificationService().cancelAll();
    }
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Paramètres enregistrés'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Rappels de prière',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.label)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Header décoratif
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: AppTheme.primaryDark, size: 26),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liturgie des Heures',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppTheme.label,
                            )),
                        SizedBox(height: 3),
                        Text(
                          'Recevez une invitation à prier\naux heures canoniques',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.sublabel,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Permissions
          _Group(title: 'Système', children: [
            _Tile(
              icon: Icons.notifications_active_outlined,
              iconBg: AppTheme.primarySoft,
              iconColor: AppTheme.primaryDark,
              label: 'Autoriser les notifications',
              subtitle: 'Requis pour recevoir les rappels',
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.sublabel, size: 18),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final granted =
                    await NotificationService().requestPermission();
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(
                    content: Text(granted
                        ? 'Notifications autorisées ✓'
                        : 'Permission refusée'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
              },
            ),
          ]),

          // Toggle principal
          _Group(title: 'Rappels', children: [
            _Tile(
              icon: Icons.alarm_outlined,
              iconBg: AppTheme.primarySoft,
              iconColor: AppTheme.primaryDark,
              label: 'Rappels quotidiens',
              subtitle: 'Notifications aux heures choisies',
              trailing: Switch.adaptive(
                value: _enabled,
                onChanged: (v) {
                  setState(() => _enabled = v);
                  _apply();
                },
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
          ]),

          // Heures
          if (_enabled)
            _Group(
              title: 'Heures de prière',
              children: _hourLabels.entries.map((e) {
                final selected = _hours.contains(e.key);
                final isRecommended = _recommended.contains(e.key);
                return _HourTile(
                  name: e.value.$1,
                  time: e.value.$2,
                  selected: selected,
                  recommended: isRecommended,
                  onTap: () {
                    setState(() {
                      if (selected && _hours.length > 1) {
                        _hours.remove(e.key);
                      } else if (!selected) {
                        _hours.add(e.key);
                      }
                    });
                    _apply();
                  },
                );
              }).toList(),
            ),

          // Note
          if (_enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                'Ces rappels suivent le rythme de la Liturgie des Heures pour vous inviter à vous arrêter quelques instants pour prier.',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.sublabel,
                    height: 1.5),
              ),
            ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
            ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Group({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.sublabel,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      const Divider(
                          height: 1, indent: 60, color: AppTheme.separator),
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15, color: AppTheme.label)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.sublabel))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _HourTile extends StatelessWidget {
  final String name;
  final String time;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  const _HourTile({
    required this.name,
    required this.time,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primarySoft : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppTheme.primaryDark : AppTheme.sublabel,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppTheme.label)),
                  if (recommended)
                    Text('Recommandé',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(time,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.sublabel)),
          ],
        ),
      ),
    );
  }
}
