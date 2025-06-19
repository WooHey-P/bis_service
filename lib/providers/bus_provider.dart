import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();
  Timer? _updateTimer;
  
  List<Bus> _buses = [];
  List<BusStop> _busStops = [];
  bool _isLoading = false;
  String? _error;

  List<Bus> get buses => _buses;
  List<BusStop> get busStops => _busStops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBusStops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _busStops = await _busService.getBusStops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBuses() async {
    if (_busStops.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _buses = await _busService.getBuses();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (_busStops.isEmpty) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void startRealTimeUpdates() {
    // 기존 타이머가 있다면 취소
    _updateTimer?.cancel();
    
    // 5초마다 버스 위치 업데이트 (백그라운드에서)
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadBusesQuietly();
    });
  }

  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<void> _loadBusesQuietly() async {
    try {
      _buses = await _busService.getBuses();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // 가장 가까운 정류장 찾기 (실제 지도에서는 필요없지만 호환성을 위해 유지)
  Map<String, double> getBusPositionOnImage(Bus bus) {
    // 실제 지도를 사용하므로 이 함수는 더 이상 필요하지 않지만
    // 기존 코드와의 호환성을 위해 유지
    return {'x': 0.5, 'y': 0.5};
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine 공식을 사용한 정확한 거리 계산
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        (sin(dLon / 2) * sin(dLon / 2));
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
