import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bakery_service.dart';
import '../database/database_helper.dart';
import '../routes/app_routes.dart';
import '../utils/utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _isLoadingAPI = false;
  int _selectedRadius = 50000; // Default 50km dalam meter

  @override
  void initState() {
    super.initState();
    _loadSavedRadius();
    _loadBakeries();
  }

  Future<void> _loadSavedRadius() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRadius = prefs.getInt('map_radius') ?? 50000;
    });
  }

  Future<void> _saveRadius(int radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('map_radius', radius);
  }

  Future<void> _loadBakeries() async {
    final bakeryService = context.read<BakeryService>();
    
    // Load bakeries dari database
    await bakeryService.loadBakeries();
    
    // Jika belum ada bakeries, fetch dari OpenStreetMap
    if (bakeryService.bakeries.isEmpty && bakeryService.currentPosition != null) {
      await _fetchFromOpenStreetMap();
    }
  }

  Future<void> _fetchFromOpenStreetMap() async {
    final bakeryService = context.read<BakeryService>();
    final position = bakeryService.currentPosition;
    
    if (position == null) {
      _showError('GPS belum terdeteksi. Mohon aktifkan lokasi.');
      return;
    }

    setState(() => _isLoadingAPI = true);

    try {
      // Clear old bakeries dari radius sebelumnya
      await DatabaseHelper.instance.clearBakeries();
      
      // Fetch bakeries dari OpenStreetMap (GRATIS!)
      await DatabaseHelper.instance.syncBakeriesFromPlacesAPI(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: _selectedRadius, // Gunakan radius yang dipilih user
      );

      // Reload bakeries setelah fetch
      await bakeryService.loadBakeries();
      
      if (mounted) {
        _showSuccess('✅ Berhasil memuat ${bakeryService.bakeries.length} bakery dari OpenStreetMap!');
      }
      
    } catch (e) {
      if (mounted) {
        _showError('Gagal memuat data dari OpenStreetMap');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAPI = false);
      }
    }
  }

  void _moveCameraToUserPosition() {
    final bakeryService = context.read<BakeryService>();
    if (bakeryService.currentPosition != null) {
      _mapController.move(
        LatLng(
          bakeryService.currentPosition!.latitude,
          bakeryService.currentPosition!.longitude,
        ),
        14.0,
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gagal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Berhasil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRadiusSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Radius Pencarian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Atur jarak maksimal pencarian bakery',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...[
              {'label': '10 km', 'value': 10000, 'icon': Icons.location_city},
              {'label': '20 km', 'value': 20000, 'icon': Icons.location_on},
              {'label': '30 km', 'value': 30000, 'icon': Icons.explore},
              {'label': '50 km (Default)', 'value': 50000, 'icon': Icons.public},
              {'label': '100 km', 'value': 100000, 'icon': Icons.travel_explore},
            ].map((option) {
              final isSelected = _selectedRadius == option['value'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () async {
                      setState(() => _selectedRadius = option['value'] as int);
                      await _saveRadius(option['value'] as int);
                      if (mounted) Navigator.pop(context);
                      _showSuccess(
                        'Radius diatur ke ${option['label']}. Klik refresh untuk update!',
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option['label'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Radius lebih besar = lebih banyak bakery',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bakeryService = context.watch<BakeryService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // OpenStreetMap Widget (GRATIS!)
          bakeryService.currentPosition == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mendeteksi lokasi Anda...'),
                    ],
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      bakeryService.currentPosition!.latitude,
                      bakeryService.currentPosition!.longitude,
                    ),
                    initialZoom: 14.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    // OpenStreetMap Tiles (GRATIS!)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bakery',
                      maxZoom: 19,
                    ),
                    
                    // User Position Marker (Blue)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            bakeryService.currentPosition!.latitude,
                            bakeryService.currentPosition!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    
                    // Bakery Markers (Red)
                    MarkerLayer(
                      markers: bakeryService.bakeries.map((bakery) {
                        return Marker(
                          point: LatLng(bakery.latitude, bakery.longitude),
                          width: 80,
                          height: 60,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to bakery detail
                              Navigator.pushNamed(
                                context,
                                AppRoutes.bakeryDetail,
                                arguments: bakery,
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 80),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    bakery.name,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

          // Custom App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 8,
                16,
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Peta Bakery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Button: Refresh dari OpenStreetMap
                  IconButton(
                    icon: _isLoadingAPI
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: _isLoadingAPI ? null : _fetchFromOpenStreetMap,
                    tooltip: 'Refresh dari OpenStreetMap',
                  ),
                  // Button: Radius Settings
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primary),
                    onPressed: _showRadiusSettings,
                    tooltip: 'Atur radius pencarian',
                  ),
                  // Button: Center ke lokasi user
                  IconButton(
                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                    onPressed: () async {
                      await bakeryService.updateCurrentPosition();
                      _moveCameraToUserPosition();
                    },
                    tooltip: 'Ke lokasi saya',
                  ),
                ],
              ),
            ),
          ),

          // Location Info Banner (Bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Saat Ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bakeryService.currentAddress ?? 'Mengambil lokasi...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.store, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${bakeryService.bakeries.length} Bakery',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.explore, size: 12, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedRadius / 1000}km',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.public, size: 12, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'OSM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay when fetching from API
          if (_isLoadingAPI)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(32),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Memuat data bakery dari\nOpenStreetMap...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '100% GRATIS - Radius 50km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
