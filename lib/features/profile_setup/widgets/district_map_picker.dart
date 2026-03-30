import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// {name: [lat, lng]}
const _locations = {
  'Gaborone': [-24.6282, 25.9231],
  'Francistown': [-21.1636, 27.5100],
  'Maun': [-19.9897, 23.4245],
  'Serowe': [-22.3833, 26.7167],
  'Molepolole': [-24.4060, 25.4951],
  'Kanye': [-24.9799, 25.3374],
  'Mochudi': [-24.3993, 26.1510],
  'Mahalapye': [-23.1000, 26.8167],
  'Palapye': [-22.5607, 27.1323],
  'Tlokweng': [-24.6060, 26.0167],
  'Ramotswa': [-24.8748, 25.8741],
  'Mogoditshane': [-24.5833, 25.8833],
  'Gabane': [-24.5667, 25.8167],
  'Lobatse': [-25.2242, 25.6775],
  'Thamaga': [-24.6861, 25.5356],
  'Letlhakane': [-21.4167, 25.6000],
  'Tonota': [-21.4500, 27.4667],
  'Moshupa': [-24.7733, 25.4444],
  'Jwaneng': [-24.5989, 24.7272],
  'Ghanzi': [-21.6975, 21.6483],
};

class DistrictMapPicker extends ConsumerStatefulWidget {
  /// The currently selected location name (or empty).
  final String? selectedLocation;

  const DistrictMapPicker({super.key, this.selectedLocation});

  @override
  ConsumerState<DistrictMapPicker> createState() => _DistrictMapPickerState();
}

class _DistrictMapPickerState extends ConsumerState<DistrictMapPicker> {
  String? _hovered;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                t('select_on_map', lang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-22.5, 24.5),
              initialZoom: 5.8,
              minZoom: 4.5,
              maxZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.agricola.app',
              ),
              MarkerLayer(
                markers: _locations.entries.map((entry) {
                  final name = entry.key;
                  final coords = entry.value;
                  final isSelected = name == widget.selectedLocation;
                  final isHovered = name == _hovered;

                  return Marker(
                    point: LatLng(coords[0], coords[1]),
                    width: 120,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(name),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.green
                                  : isHovered
                                      ? AppColors.green.withAlpha(200)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.green,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: isSelected
                                ? AppColors.green
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            t('tap_location_to_select', lang),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
