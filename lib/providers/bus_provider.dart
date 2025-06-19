import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();
  
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _buses = await _busService.getBuses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startRealTimeUpdates() {
    // 5초마다 버스 위치 업데이트
    Stream.periodic(const Duration(seconds: 5)).listen((_) {
      loadBuses();
    });
  }

  // 버스 정류장과 버스 위치를 기반으로 이미지 상의 좌표 계산
  Map<String, double> getBusPositionOnImage(Bus bus) {
    // 실제 GPS 좌표를 이미지 상의 좌표로 변환하는 로직
    // 여기서는 간단한 예시로 구현
    
    if (_busStops.isEmpty) return {'x': 0.5, 'y': 0.5};
    
    // 가장 가까운 정류장 찾기
    BusStop? closestStop;
    double minDistance = double.infinity;
    
    for (var stop in _busStops) {
      double distance = _calculateDistance(
        bus.latitude, bus.longitude,
        stop.latitude, stop.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestStop = stop;
      }
    }
    
    if (closestStop != null) {
      return {'x': closestStop.x, 'y': closestStop.y};
    }
    
    return {'x': 0.5, 'y': 0.5};
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // 간단한 거리 계산 (실제로는 Haversine 공식 사용 권장)
    return ((lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2));
  }
}
