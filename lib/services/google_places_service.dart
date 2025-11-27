import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

/// 🆓 FREE Alternative - OpenStreetMap Nominatim API
/// Tidak perlu API key, sepenuhnya GRATIS!
class GooglePlacesService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  
  /// Cari bakery dalam radius 50km dari lokasi user menggunakan Overpass API (OSM)
  static Future<List<Map<String, dynamic>>> searchNearbyBakeries({
    required double latitude,
    required double longitude,
    int radius = 50000, // 50km dalam meter
  }) async {
    try {
      // Query Overpass API untuk mencari bakery
      final query = '''
[out:json][timeout:25];
(
  node["shop"="bakery"](around:$radius,$latitude,$longitude);
  way["shop"="bakery"](around:$radius,$latitude,$longitude);
  node["amenity"="cafe"]["cuisine"~"bakery"](around:$radius,$latitude,$longitude);
);
out body;
>;
out skel qt;
''';

      print('🔍 Fetching bakeries from OpenStreetMap (FREE)...');
      print('📍 Location: $latitude, $longitude');
      print('📏 Radius: ${radius}m (${radius / 1000}km)');
      
      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: query,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        
        print('✅ Found ${elements.length} bakeries from OpenStreetMap');
        
        // Parse hasil API
        List<Map<String, dynamic>> bakeries = [];
        for (var element in elements) {
          if (element['type'] == 'node' && element['tags'] != null) {
            final tags = element['tags'];
            final lat = element['lat'];
            final lon = element['lon'];
            
            // Skip jika tidak ada nama
            if (tags['name'] == null) continue;
            
            // Hitung jarak
            final distance = _calculateDistance(latitude, longitude, lat, lon);
            
            final bakery = {
              'place_id': element['id'].toString(),
              'name': tags['name'] ?? 'Bakery',
              'address': _buildAddress(tags),
              'latitude': lat,
              'longitude': lon,
              'rating': 4.0 + (element['id'] % 10) / 10, // Random rating 4.0-4.9
              'photo_url': _getRandomBakeryImage(),
              'phone': tags['phone'] ?? tags['contact:phone'] ?? '',
              'distance': distance,
            };
            bakeries.add(bakery);
          }
        }
        
        // Sort by distance
        bakeries.sort((a, b) => a['distance'].compareTo(b['distance']));
        
        // Limit to 50 results
        if (bakeries.length > 50) {
          bakeries = bakeries.sublist(0, 50);
        }
        
        print('📊 Returning ${bakeries.length} bakeries');
        return bakeries;
        
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }
  
  /// Build address dari OSM tags
  static String _buildAddress(Map<String, dynamic> tags) {
    List<String> parts = [];
    
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:housenumber'] != null) parts.add('No. ${tags['addr:housenumber']}');
    if (tags['addr:suburb'] != null) parts.add(tags['addr:suburb']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    
    if (parts.isEmpty && tags['addr:full'] != null) {
      return tags['addr:full'];
    }
    
    return parts.isEmpty ? 'Alamat tidak tersedia' : parts.join(', ');
  }
  
  /// Calculate distance in meters
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }
  
  /// Get random bakery image dari Unsplash
  static String _getRandomBakeryImage() {
    final images = [
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
      'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800',
      'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=800',
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800',
      'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800',
    ];
    return images[DateTime.now().millisecondsSinceEpoch % images.length];
  }
}
