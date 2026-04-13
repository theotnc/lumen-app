import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/church.dart';
import '../../core/services/church_service.dart';
import '../../core/theme.dart';

class ChurchDetailScreen extends StatefulWidget {
  final Church church;
  const ChurchDetailScreen({super.key, required this.church});

  @override
  State<ChurchDetailScreen> createState() => _ChurchDetailScreenState();
}

class _ChurchDetailScreenState extends State<ChurchDetailScreen> {
  List<MassSchedule> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      _schedules = await ChurchService().fetchSchedules(widget.church.id);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.church;
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
            // AppBar transparent glass
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
              title: Text(
                c.nom,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.label,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppTheme.label),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(bottom: 48),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Mini carte ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 190,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: c.latLng,
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.cathoapp.bible',
                              retinaMode: RetinaMode.isHighDensity(context),
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: c.latLng,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.45),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.church_rounded,
                                      color: Color(0xFF1C1C1E), size: 18),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Informations ─────────────────────────────
                  _SectionGroup(title: 'Informations', children: [
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: c.fullAddress),
                    _InfoRow(
                        icon: Icons.account_balance_outlined,
                        label: 'Diocèse de ${c.diocese}'),
                    _InfoRow(
                        icon: Icons.map_outlined,
                        label: '${c.departement} · ${c.region}'),
                    if (c.telephone != null)
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: c.telephone!,
                          isLink: true),
                    if (c.siteWeb != null)
                      _InfoRow(
                          icon: Icons.language,
                          label: c.siteWeb!,
                          isLink: true),
                  ]),

                  // ── Horaires ─────────────────────────────────
                  _SectionGroup(
                    title: 'Horaires des messes',
                    trailing: GestureDetector(
                      onTap: () => _showAddScheduleSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.30),
                              width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 13, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            const Text('Ajouter',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary)),
                          ],
                        ),
                      ),
                    ),
                    children: _loading
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primary)),
                            )
                          ]
                        : _schedules.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.church_outlined,
                                          size: 28,
                                          color: Colors.white.withValues(alpha: 0.20)),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Aidez la communauté !',
                                        style: TextStyle(
                                            color: AppTheme.label,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ajoutez les horaires des messes\npour cette église.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.40),
                                            fontSize: 13,
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            : _buildScheduleTiles(),
                  ),

                  // ── Itinéraire ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'ITINÉRAIRE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.sublabel,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _DirectionBtn(
                              label: 'Apple Maps',
                              icon: Icons.map_outlined,
                              url:
                                  'maps://?daddr=${c.latitude},${c.longitude}',
                            ),
                            const SizedBox(width: 10),
                            _DirectionBtn(
                              label: 'Google Maps',
                              icon: Icons.navigation_outlined,
                              url:
                                  'https://maps.google.com/?daddr=${c.latitude},${c.longitude}',
                            ),
                            const SizedBox(width: 10),
                            _DirectionBtn(
                              label: 'Waze',
                              icon: Icons.directions_car_outlined,
                              url:
                                  'waze://?ll=${c.latitude},${c.longitude}&navigate=yes',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddScheduleSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    String jour  = 'dimanche';
    String heure = '10:30';
    String type  = 'Messe';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20,
              MediaQuery.of(ctx).viewInsets.bottom + 30),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Ajouter un horaire',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppTheme.label)),
              const SizedBox(height: 20),

              // Jour
              _SheetLabel(label: 'Jour'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MassSchedule.jours.map((j) {
                    final sel = j == jour;
                    return GestureDetector(
                      onTap: () => setModal(() => jour = j),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primary
                              : Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel
                                ? AppTheme.primary
                                : Colors.white.withValues(alpha: 0.10),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          j[0].toUpperCase() + j.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? const Color(0xFF1C1C1E)
                                : AppTheme.sublabel,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Heure + Type
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SheetLabel(label: 'Heure'),
                        const SizedBox(height: 8),
                        _SheetInput(
                          value: heure,
                          hint: '10:30',
                          keyboardType: TextInputType.datetime,
                          onChanged: (v) => setModal(() => heure = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SheetLabel(label: 'Type'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                                width: 0.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF2C2C2E),
                              style: const TextStyle(
                                  color: AppTheme.label, fontSize: 14),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              borderRadius: BorderRadius.circular(12),
                              items: MassSchedule.types.map((t) =>
                                  DropdownMenuItem(value: t,
                                      child: Text(t))).toList(),
                              onChanged: (v) =>
                                  setModal(() => type = v ?? type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton soumettre
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  final s = MassSchedule(
                    id:       '',
                    egliseId: widget.church.id,
                    jour:     jour,
                    heure:    heure,
                    type:     type,
                    langue:   'Français',
                  );
                  await ChurchService().saveSchedule(s);
                  if (mounted) {
                    setState(() => _loading = true);
                    await _loadSchedules();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Ajouter cet horaire',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScheduleTiles() {
    final byDay = <String, List<MassSchedule>>{};
    for (final s in _schedules) {
      byDay.putIfAbsent(s.jour, () => []).add(s);
    }

    final result = <Widget>[];
    final days = MassSchedule.jours.where(byDay.containsKey).toList();

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final list = byDay[day]!;
      result.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day[0].toUpperCase() + day.substring(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              ...list.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 3),
                    child: Text(
                      '${s.heure}  ·  ${s.type}'
                      '${s.langue != 'Français' ? ' (${s.langue})' : ''}'
                      '${s.notes != null ? '  ·  ${s.notes}' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.label,
                        height: 1.5,
                      ),
                    ),
                  )),
              if (i < days.length - 1)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(height: 1, color: AppTheme.separator),
                ),
            ],
          ),
        ),
      );
    }
    return result;
  }
}

// ── Section group ─────────────────────────────────────────
class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const _SectionGroup({required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
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
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: trailing!,
                ),
            ],
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
                      Divider(
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

// ── Info row ──────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLink;
  const _InfoRow(
      {required this.icon, required this.label, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isLink ? AppTheme.primary : AppTheme.label,
                fontSize: 14,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
          if (isLink)
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.sublabel),
        ],
      ),
    );
  }
}

// ── Direction button ──────────────────────────────────────
class _DirectionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;
  const _DirectionBtn(
      {required this.label, required this.icon, required this.url});

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: _launch,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: AppTheme.solidCard(radius: 14),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppTheme.primary),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.sublabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers bottom sheet ──────────────────────────────────
class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 1.0,
        ),
      );
}

class _SheetInput extends StatelessWidget {
  final String value;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _SheetInput({
    required this.value,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.10), width: 0.5),
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.label, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
