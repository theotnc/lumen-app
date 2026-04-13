import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/church.dart';
import '../../core/services/church_service.dart';
import '../../core/theme.dart';
import 'church_detail_screen.dart';

class ChurchListScreen extends StatefulWidget {
  final List<Church> churches;
  final LatLng? userLocation;

  const ChurchListScreen({
    super.key,
    required this.churches,
    required this.userLocation,
  });

  @override
  State<ChurchListScreen> createState() => _ChurchListScreenState();
}

class _ChurchListScreenState extends State<ChurchListScreen> {
  String _search = '';

  List<Church> get _filtered => widget.churches.where((c) {
        if (_search.isEmpty) return true;
        return c.nom.toLowerCase().contains(_search.toLowerCase()) ||
            c.ville.toLowerCase().contains(_search.toLowerCase());
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.cardShadow,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une église, une ville...',
                prefixIcon: Icon(Icons.search, color: AppTheme.sublabel, size: 20),
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),

        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Text('Aucune église trouvée',
                      style: TextStyle(color: AppTheme.sublabel)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: _filtered.asMap().entries.map((e) {
                          final isLast = e.key == _filtered.length - 1;
                          final c = e.value;
                          final dist = widget.userLocation != null
                              ? ChurchService()
                                  .formatDistance(widget.userLocation!, c)
                              : null;
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.church,
                                      color: AppTheme.primaryDark, size: 20),
                                ),
                                title: Text(
                                  c.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppTheme.label,
                                  ),
                                ),
                                subtitle: Text(
                                  '${c.ville} · ${c.diocese}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.sublabel),
                                ),
                                trailing: dist != null
                                    ? Text(
                                        dist,
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )
                                    : const Icon(Icons.chevron_right,
                                        color: AppTheme.sublabel, size: 18),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ChurchDetailScreen(church: c)),
                                ),
                              ),
                              if (!isLast)
                                const Divider(
                                    height: 1,
                                    indent: 72,
                                    color: AppTheme.separator),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
