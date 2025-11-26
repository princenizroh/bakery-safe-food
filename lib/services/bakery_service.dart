import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/bakery_model.dart';
import '../models/product_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

class BakeryService extends ChangeNotifier {
  List<Bakery> _bakeries = [];
  List<Product> _products = [];
  bool _isLoading = false;
  Position? _currentPosition;
  String? _currentAddress;

  List<Bakery> get bakeries => _bakeries;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  Future<void> loadBakeries() async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      final result = await db.query('bakeries');
      _bakeries = result.map((map) => Bakery.fromMap(map)).toList();

      // Calculate distances if position is available
      if (_currentPosition != null) {
        _bakeries = _bakeries.map((bakery) {
          final distance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            bakery.latitude,
            bakery.longitude,
          );
          return bakery.copyWith(distance: distance);
        }).toList();

        // Sort by distance
        _bakeries.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByBakery(int bakeryId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'products',
        where: 'bakery_id = ? AND is_available = 1',
        whereArgs: [bakeryId],
      );
      _products = result.map((map) => Product.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> getAllAvailableProducts() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'products',
        where: 'is_available = 1 AND quantity > 0',
      );
      return result.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateCurrentPosition() async {
    try {
      print('🌍 GPS: Starting location update...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('🌍 GPS: Service enabled = $serviceEnabled');
      
      if (!serviceEnabled) {
        print('❌ GPS: Location services are DISABLED');
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      print('🌍 GPS: Initial permission = $permission');
      
      if (permission == LocationPermission.denied) {
        print('🌍 GPS: Requesting permission...');
        permission = await Geolocator.requestPermission();
        print('🌍 GPS: Permission after request = $permission');
        
        if (permission == LocationPermission.denied) {
          print('❌ GPS: Permission DENIED by user');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ GPS: Permission DENIED FOREVER');
        return;
      }

      // Get actual current position
      print('🌍 GPS: Fetching current position...');
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      print('✅ GPS: SUCCESS! Position retrieved:');
      print('   📍 Latitude: ${_currentPosition!.latitude}');
      print('   📍 Longitude: ${_currentPosition!.longitude}');
      print('   📍 Accuracy: ${_currentPosition!.accuracy}m');
      
      // Reverse geocoding untuk dapetin nama lokasi
      try {
        print('🗺️ GEOCODING: Converting coordinates to address...');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _currentAddress = '${place.subLocality ?? place.locality ?? ""}, ${place.locality ?? place.administrativeArea ?? ""}';
          
          // Fallback kalau kosong
          if (_currentAddress == ', ') {
            _currentAddress = '${place.locality ?? place.administrativeArea ?? "Unknown Location"}';
          }
          
          print('✅ GEOCODING: Address found = $_currentAddress');
        } else {
          _currentAddress = 'Lokasi tidak diketahui';
          print('⚠️ GEOCODING: No placemark found');
        }
      } catch (e) {
        _currentAddress = 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(4)}';
        print('⚠️ GEOCODING ERROR: $e');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ GPS ERROR: $e');
      print('   Stack trace: ${StackTrace.current}');
      notifyListeners();
    }
  }

  List<Bakery> searchBakeries(String query) {
    if (query.isEmpty) return _bakeries;

    return _bakeries.where((bakery) {
      return bakery.name.toLowerCase().contains(query.toLowerCase()) ||
          (bakery.address.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
