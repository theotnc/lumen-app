import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/church.dart';
import '../../core/theme.dart';
import 'church_detail_screen.dart';

class ChurchMapScreen extends StatefulWidget {
  final List<Church> churches;
  final LatLng userLocation;

  const ChurchMapScreen({
    super.key,
    required this.churches,
    required this.userLocation,
  });

  @override
  State<ChurchMapScreen> createState() => _ChurchMapScreenState();
}

class _ChurchMapScreenState extends State<ChurchMapScreen> {
  Church? _selected;
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.userLocation,
            initialZoom: 13,
            onTap: (_, pos) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cathoapp.bible',
            ),

            // Marqueur utilisateur — or
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.userLocation,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Marqueurs des églises
            MarkerLayer(
              markers: widget.churches.map((church) {
                final isSelected = _selected?.id == church.id;
                return Marker(
                  point: church.latLng,
                  width: isSelected ? 48 : 38,
                  height: isSelected ? 48 : 38,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selected = church);
                      _mapController.move(church.latLng, 15);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.primary.withValues(alpha: 0.80),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: isSelected ? 12 : 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.church,
                        color: const Color(0xFF1C1C1E),
                        size: isSelected ? 24 : 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Fiche église sélectionnée
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _ChurchCard(
              church: _selected!,
              onClose: () => setState(() => _selected = null),
            ),
          ),
      ],
    );
  }
}

class _ChurchCard extends StatelessWidget {
  final Church church;
  final VoidCallback onClose;

  const _ChurchCard({required this.church, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Color(0x18000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.church, color: AppTheme.primaryDark, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.label,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      church.ville,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.sublabel),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: AppTheme.sublabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            church.fullAddress,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.sublabel, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChurchDetailScreen(church: church)),
              ),
              child: const Text('Voir les horaires'),
            ),
          ),
        ],
      ),
    );
  }
}
