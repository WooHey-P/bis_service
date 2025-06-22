import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../models/bus_route.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();
  Timer? _updateTimer;
  
  List<Bus> _buses = [];
  List<BusStop> _busStops = [];
  List<BusRoute> _busRoutes = [];
  List<BusStop> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _searchQuery = '';
  
  // Visibility controls
  final Set<String> _visibleRoutes = {};
  final Set<String> _visibleBuses = {};
  final Set<String> _visibleStations = {};

  List<Bus> get buses => _buses;
  List<BusStop> get busStops => _busStops;
  List<BusRoute> get busRoutes => _busRoutes;
  List<BusStop> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get visibleRoutes => _visibleRoutes;
  Set<String> get visibleBuses => _visibleBuses;
  Set<String> get visibleStations => _visibleStations;

  Future<void> loadBusStops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _busStops = await _busService.getBusStops();
      // Initialize all stations as visible
      _visibleStations.addAll(_busStops.map((station) => station.id));
      debugPrint("정류장 로드 성공: ${_busStops.length}개");
    } catch (e) {
      _error = e.toString();
      debugPrint("정류장 로드 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBusRoutes() async {
    try {
      _busRoutes = await _busService.getBusRoutes();
      // Initialize all routes as visible
      _visibleRoutes.addAll(_busRoutes.map((route) => route.routeNumber));
      debugPrint("버스 노선 로드 성공: ${_busRoutes.length}개");
    } catch (e) {
      _error = e.toString();
      debugPrint("버스 노선 로드 실패: $e");
    }
    notifyListeners();
  }

  Future<void> loadBuses() async {
    if (_busStops.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _buses = await _busService.getBuses();
      // Initialize all buses as visible
      _visibleBuses.addAll(_buses.map((bus) => bus.id));
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

  Future<void> searchStations(String query) async {
    _searchQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _busService.searchStations(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyStations(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _busService.getNearbyStations(latitude, longitude);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  void startRealTimeUpdates() {
    // 기존 타이머가 있다면 취소
    _updateTimer?.cancel();
    
    // 0.1초마다 버스 위치 업데이트 (실시간 시뮬레이션)
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
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

  // 특정 정류장을 지나는 버스들 가져오기
  List<Bus> getBusesForStation(String stationId) {
    final station = _busStops.firstWhere(
      (stop) => stop.id == stationId,
      orElse: () => BusStop(
        id: '',
        name: '',
        latitude: 0,
        longitude: 0,
        x: 0,
        y: 0,
        routes: [],
      ),
    );
    
    return _buses.where((bus) => station.routes.contains(bus.routeNumber)).toList();
  }

  // 특정 노선의 버스들 가져오기
  List<Bus> getBusesForRoute(String routeNumber) {
    return _buses.where((bus) => bus.routeNumber == routeNumber).toList();
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

  // Visibility control methods
  void toggleRouteVisibility(String routeNumber) {
    if (_visibleRoutes.contains(routeNumber)) {
      _visibleRoutes.remove(routeNumber);
    } else {
      _visibleRoutes.add(routeNumber);
    }
    notifyListeners();
  }

  void toggleBusVisibility(String busId) {
    if (_visibleBuses.contains(busId)) {
      _visibleBuses.remove(busId);
    } else {
      _visibleBuses.add(busId);
    }
    notifyListeners();
  }

  void toggleStationVisibility(String stationId) {
    if (_visibleStations.contains(stationId)) {
      _visibleStations.remove(stationId);
    } else {
      _visibleStations.add(stationId);
    }
    notifyListeners();
  }

  void showAllRoutes() {
    _visibleRoutes.addAll(_busRoutes.map((route) => route.routeNumber));
    notifyListeners();
  }

  void hideAllRoutes() {
    _visibleRoutes.clear();
    notifyListeners();
  }

  void showAllBuses() {
    _visibleBuses.addAll(_buses.map((bus) => bus.id));
    notifyListeners();
  }

  void hideAllBuses() {
    _visibleBuses.clear();
    notifyListeners();
  }

  void showAllStations() {
    _visibleStations.addAll(_busStops.map((station) => station.id));
    notifyListeners();
  }

  void hideAllStations() {
    _visibleStations.clear();
    notifyListeners();
  }

  // Get filtered data based on visibility
  List<Bus> get visibleBusesData => _buses.where((bus) => _visibleBuses.contains(bus.id)).toList();
  List<BusStop> get visibleStationsData => _busStops.where((station) => _visibleStations.contains(station.id)).toList();
  List<BusRoute> get visibleRoutesData => _busRoutes.where((route) => _visibleRoutes.contains(route.routeNumber)).toList();
}
