import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../models/bus_route.dart';

class BusService {
  static const String baseUrl = 'http://localhost:3000/api'; // Node.js 서버 URL
  
  // 시뮬레이션을 위한 정적 데이터
  static final List<BusStop> _mockBusStops = [
    BusStop(id: 'station_001', name: '시청앞', latitude: 37.5665, longitude: 126.9780, x: 0.2, y: 0.3, routes: ['146', '273', '370']),
    BusStop(id: 'station_002', name: '강남역', latitude: 37.4979, longitude: 127.0276, x: 0.7, y: 0.6, routes: ['146', '273']),
    BusStop(id: 'station_003', name: '홍대입구', latitude: 37.5563, longitude: 126.9236, x: 0.4, y: 0.2, routes: ['370', '273']),
    BusStop(id: 'station_004', name: '종로3가', latitude: 37.5703, longitude: 126.9925, x: 0.3, y: 0.25, routes: ['146', '370']),
    BusStop(id: 'station_005', name: '명동', latitude: 37.5636, longitude: 126.9834, x: 0.25, y: 0.35, routes: ['146', '273']),
    BusStop(id: 'station_006', name: '동대문', latitude: 37.5714, longitude: 127.0098, x: 0.45, y: 0.28, routes: ['146', '273', '502']),
    BusStop(id: 'station_007', name: '신촌', latitude: 37.5596, longitude: 126.9425, x: 0.35, y: 0.22, routes: ['370', '502']),
    BusStop(id: 'station_008', name: '이태원', latitude: 37.5345, longitude: 126.9947, x: 0.28, y: 0.42, routes: ['146', '502']),
    BusStop(id: 'station_009', name: '압구정', latitude: 37.5274, longitude: 127.0280, x: 0.65, y: 0.45, routes: ['273', '370']),
    BusStop(id: 'station_010', name: '잠실', latitude: 37.5133, longitude: 127.1000, x: 0.8, y: 0.55, routes: ['146', '502']),
    BusStop(id: 'station_011', name: '여의도', latitude: 37.5219, longitude: 126.9245, x: 0.15, y: 0.48, routes: ['273', '370']),
    BusStop(id: 'station_012', name: '건대입구', latitude: 37.5401, longitude: 127.0695, x: 0.75, y: 0.38, routes: ['146', '273']),
    BusStop(id: 'station_013', name: '성수', latitude: 37.5445, longitude: 127.0557, x: 0.72, y: 0.35, routes: ['370', '502']),
    BusStop(id: 'station_014', name: '왕십리', latitude: 37.5615, longitude: 127.0374, x: 0.55, y: 0.32, routes: ['146', '273']),
    BusStop(id: 'station_015', name: '용산', latitude: 37.5299, longitude: 126.9649, x: 0.22, y: 0.45, routes: ['370', '502']),
    BusStop(id: 'station_016', name: '노원', latitude: 37.6542, longitude: 127.0568, x: 0.68, y: 0.15, routes: ['146', '273']),
    BusStop(id: 'station_017', name: '수유', latitude: 37.6369, longitude: 127.0252, x: 0.52, y: 0.18, routes: ['370', '502']),
    BusStop(id: 'station_018', name: '미아', latitude: 37.6133, longitude: 127.0288, x: 0.53, y: 0.22, routes: ['146', '273']),
    BusStop(id: 'station_019', name: '성북', latitude: 37.5894, longitude: 127.0167, x: 0.48, y: 0.25, routes: ['370', '502']),
    BusStop(id: 'station_020', name: '혜화', latitude: 37.5823, longitude: 127.0015, x: 0.42, y: 0.26, routes: ['146', '273']),
    BusStop(id: 'station_021', name: '대학로', latitude: 37.5817, longitude: 127.0028, x: 0.43, y: 0.265, routes: ['370', '502']),
    BusStop(id: 'station_022', name: '안국', latitude: 37.5759, longitude: 126.9852, x: 0.38, y: 0.27, routes: ['146', '273']),
    BusStop(id: 'station_023', name: '경복궁', latitude: 37.5758, longitude: 126.9769, x: 0.32, y: 0.275, routes: ['370', '502']),
    BusStop(id: 'station_024', name: '광화문', latitude: 37.5720, longitude: 126.9769, x: 0.31, y: 0.28, routes: ['146', '273']),
    BusStop(id: 'station_025', name: '을지로', latitude: 37.5664, longitude: 126.9910, x: 0.39, y: 0.31, routes: ['370', '502']),
    BusStop(id: 'station_026', name: '충무로', latitude: 37.5614, longitude: 126.9936, x: 0.40, y: 0.33, routes: ['146', '273']),
    BusStop(id: 'station_027', name: '동국대', latitude: 37.5581, longitude: 126.9989, x: 0.41, y: 0.34, routes: ['370', '502']),
    BusStop(id: 'station_028', name: '약수', latitude: 37.5544, longitude: 127.0099, x: 0.44, y: 0.36, routes: ['146', '273']),
    BusStop(id: 'station_029', name: '금천구청', latitude: 37.4568, longitude: 126.8956, x: 0.08, y: 0.68, routes: ['370', '502']),
    BusStop(id: 'station_030', name: '구로디지털단지', latitude: 37.4851, longitude: 126.9015, x: 0.12, y: 0.62, routes: ['146', '273']),
  ];

  static final List<BusRoute> _mockBusRoutes = [
    BusRoute(
      id: 'route_146',
      routeNumber: '146',
      routeName: '강남역-노원',
      stationIds: ['station_002', 'station_005', 'station_001', 'station_004', 'station_006', 'station_014', 'station_020', 'station_022', 'station_024', 'station_018', 'station_016'],
      coordinates: [
        RouteCoordinate(latitude: 37.4979, longitude: 127.0276),
        RouteCoordinate(latitude: 37.5636, longitude: 126.9834),
        RouteCoordinate(latitude: 37.5665, longitude: 126.9780),
        RouteCoordinate(latitude: 37.5703, longitude: 126.9925),
        RouteCoordinate(latitude: 37.5714, longitude: 127.0098),
        RouteCoordinate(latitude: 37.5615, longitude: 127.0374),
        RouteCoordinate(latitude: 37.5823, longitude: 127.0015),
        RouteCoordinate(latitude: 37.5759, longitude: 126.9852),
        RouteCoordinate(latitude: 37.5720, longitude: 126.9769),
        RouteCoordinate(latitude: 37.6133, longitude: 127.0288),
        RouteCoordinate(latitude: 37.6542, longitude: 127.0568),
      ],
      color: '#2196F3',
    ),
    BusRoute(
      id: 'route_273',
      routeNumber: '273',
      routeName: '홍대입구-강남역',
      stationIds: ['station_003', 'station_007', 'station_011', 'station_001', 'station_005', 'station_006', 'station_012', 'station_009', 'station_002'],
      coordinates: [
        RouteCoordinate(latitude: 37.5563, longitude: 126.9236),
        RouteCoordinate(latitude: 37.5596, longitude: 126.9425),
        RouteCoordinate(latitude: 37.5219, longitude: 126.9245),
        RouteCoordinate(latitude: 37.5665, longitude: 126.9780),
        RouteCoordinate(latitude: 37.5636, longitude: 126.9834),
        RouteCoordinate(latitude: 37.5714, longitude: 127.0098),
        RouteCoordinate(latitude: 37.5401, longitude: 127.0695),
        RouteCoordinate(latitude: 37.5274, longitude: 127.0280),
        RouteCoordinate(latitude: 37.4979, longitude: 127.0276),
      ],
      color: '#4CAF50',
    ),
    BusRoute(
      id: 'route_370',
      routeNumber: '370',
      routeName: '시청앞-성수',
      stationIds: ['station_001', 'station_004', 'station_023', 'station_007', 'station_003', 'station_011', 'station_019', 'station_021', 'station_013'],
      coordinates: [
        RouteCoordinate(latitude: 37.5665, longitude: 126.9780),
        RouteCoordinate(latitude: 37.5703, longitude: 126.9925),
        RouteCoordinate(latitude: 37.5758, longitude: 126.9769),
        RouteCoordinate(latitude: 37.5596, longitude: 126.9425),
        RouteCoordinate(latitude: 37.5563, longitude: 126.9236),
        RouteCoordinate(latitude: 37.5219, longitude: 126.9245),
        RouteCoordinate(latitude: 37.5894, longitude: 127.0167),
        RouteCoordinate(latitude: 37.5817, longitude: 127.0028),
        RouteCoordinate(latitude: 37.5445, longitude: 127.0557),
      ],
      color: '#FF9800',
    ),
    BusRoute(
      id: 'route_502',
      routeNumber: '502',
      routeName: '잠실-금천구청',
      stationIds: ['station_010', 'station_008', 'station_015', 'station_007', 'station_017', 'station_019', 'station_021', 'station_027', 'station_029'],
      coordinates: [
        RouteCoordinate(latitude: 37.5133, longitude: 127.1000),
        RouteCoordinate(latitude: 37.5345, longitude: 126.9947),
        RouteCoordinate(latitude: 37.5299, longitude: 126.9649),
        RouteCoordinate(latitude: 37.5596, longitude: 126.9425),
        RouteCoordinate(latitude: 37.6369, longitude: 127.0252),
        RouteCoordinate(latitude: 37.5894, longitude: 127.0167),
        RouteCoordinate(latitude: 37.5817, longitude: 127.0028),
        RouteCoordinate(latitude: 37.5581, longitude: 126.9989),
        RouteCoordinate(latitude: 37.4568, longitude: 126.8956),
      ],
      color: '#9C27B0',
    ),
  ];

  Future<List<BusStop>> getBusStops() async {
    debugPrint("BusService: getBusStops 호출됨");
    try {
      // 실제 API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _mockBusStops;
    } catch (e) {
      throw Exception('정류장 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<BusRoute>> getBusRoutes() async {
    debugPrint("BusService: getBusRoutes 호출됨");
    try {
      // 실제 API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockBusRoutes;
    } catch (e) {
      throw Exception('버스 노선 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<Bus>> getBuses() async {
    debugPrint("BusService: getBuses 호출됨");
    try {
      // 실제 API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 300));
      
      final random = Random();
      final now = DateTime.now();
      
      return _generateMovingBuses(now);
    } catch (e) {
      throw Exception('버스 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<BusStop>> searchStations(String query) async {
    debugPrint("BusService: searchStations 호출됨 - query: $query");
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (query.isEmpty) return _mockBusStops;
      
      return _mockBusStops
          .where((station) => 
              station.name.toLowerCase().contains(query.toLowerCase()) ||
              station.id.contains(query))
          .toList();
    } catch (e) {
      throw Exception('정류장 검색에 실패했습니다: $e');
    }
  }

  Future<List<BusStop>> getNearbyStations(double latitude, double longitude, {double radiusKm = 1.0}) async {
    debugPrint("BusService: getNearbyStations 호출됨 - lat: $latitude, lng: $longitude");
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockBusStops.where((station) {
        final distance = _calculateDistance(latitude, longitude, station.latitude, station.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('근처 정류장 검색에 실패했습니다: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  // 버스 위치 시뮬레이션을 위한 정적 변수들
  static final Map<String, double> _busDirections = {};
  static final Map<String, int> _busRouteProgress = {};
  static DateTime? _lastUpdateTime;

  List<Bus> _generateMovingBuses(DateTime now) {
    // 첫 번째 호출이거나 시간이 초기화된 경우
    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      _initializeBusPositions();
    }

    // 시간 차이 계산 (밀리초)
    final timeDiff = now.difference(_lastUpdateTime!).inMilliseconds;
    _lastUpdateTime = now;

    // 각 버스의 위치를 업데이트
    final buses = <Bus>[];
    final busConfigs = [
      {'id': 'bus_146_01', 'route': '146', 'baseStations': [0, 5, 10, 15, 20, 25]},
      {'id': 'bus_146_02', 'route': '146', 'baseStations': [3, 8, 13, 18, 23, 28]},
      {'id': 'bus_146_03', 'route': '146', 'baseStations': [1, 6, 11, 16, 21, 26]},
      {'id': 'bus_273_01', 'route': '273', 'baseStations': [2, 7, 12, 17, 22, 27]},
      {'id': 'bus_273_02', 'route': '273', 'baseStations': [4, 9, 14, 19, 24, 29]},
      {'id': 'bus_273_03', 'route': '273', 'baseStations': [0, 6, 12, 18, 24]},
      {'id': 'bus_370_01', 'route': '370', 'baseStations': [1, 7, 13, 19, 25]},
      {'id': 'bus_370_02', 'route': '370', 'baseStations': [3, 9, 15, 21, 27]},
      {'id': 'bus_502_01', 'route': '502', 'baseStations': [5, 11, 17, 23, 29]},
      {'id': 'bus_502_02', 'route': '502', 'baseStations': [2, 8, 14, 20, 26]},
    ];

    for (final config in busConfigs) {
      final busId = config['id'] as String;
      final routeNumber = config['route'] as String;
      final baseStations = config['baseStations'] as List<int>;
      
      // 버스 진행도 업데이트 (0.1초마다 약간씩 이동)
      _busRouteProgress[busId] = (_busRouteProgress[busId] ?? 0) + (timeDiff ~/ 50);
      
      // 현재 정류장 인덱스 계산 (노선의 정류장 순서에 맞게)
      final totalProgress = _busRouteProgress[busId]!;
      final routeStationCount = _getRouteStationCount(routeNumber);
      final stationIndex = (totalProgress ~/ 1000) % routeStationCount;
      final nextStationIndex = (stationIndex + 1) % routeStationCount;
      
      // 정류장 간 진행률 (0.0 ~ 1.0)
      final progressBetweenStations = ((totalProgress % 1000) / 1000.0);
      
      // 실제 노선의 정류장 ID 가져오기
      final routeStationIds = _getRouteStationIds(routeNumber);
      final currentStationId = routeStationIds[stationIndex % routeStationIds.length];
      final nextStationId = routeStationIds[nextStationIndex % routeStationIds.length];
      
      // 현재 정류장과 다음 정류장의 좌표
      final currentStation = _mockBusStops.firstWhere((s) => s.id == currentStationId);
      final nextStation = _mockBusStops.firstWhere((s) => s.id == nextStationId);
      
      // 선형 보간으로 현재 위치 계산
      final currentLat = currentStation.latitude + 
          (nextStation.latitude - currentStation.latitude) * progressBetweenStations;
      final currentLng = currentStation.longitude + 
          (nextStation.longitude - currentStation.longitude) * progressBetweenStations;
      
      buses.add(Bus(
        id: busId,
        routeNumber: routeNumber,
        latitude: currentLat,
        longitude: currentLng,
        status: '운행중',
        currentStationIndex: stationIndex,
        lastUpdated: now,
      ));
    }

    return buses;
  }

  void _initializeBusPositions() {
    // 각 버스의 초기 진행도를 랜덤하게 설정
    final random = Random();
    _busRouteProgress.clear();
    _busDirections.clear();
    
    final busIds = [
      'bus_146_01', 'bus_146_02', 'bus_146_03',
      'bus_273_01', 'bus_273_02', 'bus_273_03',
      'bus_370_01', 'bus_370_02',
      'bus_502_01', 'bus_502_02'
    ];
    
    for (final busId in busIds) {
      _busRouteProgress[busId] = random.nextInt(10000); // 0~10초 범위의 랜덤 시작점
      _busDirections[busId] = random.nextDouble() * 360; // 랜덤 방향
    }
  }

  int _getRouteStationCount(String routeNumber) {
    final route = _mockBusRoutes.firstWhere(
      (r) => r.routeNumber == routeNumber,
      orElse: () => _mockBusRoutes.first,
    );
    return route.stationIds.length;
  }

  List<String> _getRouteStationIds(String routeNumber) {
    final route = _mockBusRoutes.firstWhere(
      (r) => r.routeNumber == routeNumber,
      orElse: () => _mockBusRoutes.first,
    );
    return route.stationIds;
  }
}
