import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';

class BusService {
  static const String baseUrl = 'http://localhost:3000/api'; // Node.js 서버 URL
  
  // 시뮬레이션을 위한 정적 데이터
  static final List<BusStop> _mockBusStops = [
    BusStop(
      id: 'station_001',
      name: '시청앞',
      latitude: 37.5665,
      longitude: 126.9780,
      x: 0.2,
      y: 0.3,
      routes: ['146', '273', '370'],
    ),
    BusStop(
      id: 'station_002',
      name: '강남역',
      latitude: 37.4979,
      longitude: 127.0276,
      x: 0.7,
      y: 0.6,
      routes: ['146', '273'],
    ),
    BusStop(
      id: 'station_003',
      name: '홍대입구',
      latitude: 37.5563,
      longitude: 126.9236,
      x: 0.4,
      y: 0.2,
      routes: ['370', '273'],
    ),
    BusStop(
      id: 'station_004',
      name: '종로3가',
      latitude: 37.5703,
      longitude: 126.9925,
      x: 0.3,
      y: 0.25,
      routes: ['146', '370'],
    ),
    BusStop(
      id: 'station_005',
      name: '명동',
      latitude: 37.5636,
      longitude: 126.9834,
      x: 0.25,
      y: 0.35,
      routes: ['146', '273'],
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

  Future<List<Bus>> getBuses() async {
    debugPrint("BusService: getBuses 호출됨");
    try {
      // 실제 API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 300));
      
      final random = Random();
      final now = DateTime.now();
      
      return [
        Bus(
          id: 'bus_146_01',
          routeNumber: '146',
          latitude: 37.5665 + (random.nextDouble() - 0.5) * 0.01,
          longitude: 126.9780 + (random.nextDouble() - 0.5) * 0.01,
          status: '운행중',
          currentStationIndex: random.nextInt(5),
          lastUpdated: now,
        ),
        Bus(
          id: 'bus_146_02',
          routeNumber: '146',
          latitude: 37.5200 + (random.nextDouble() - 0.5) * 0.01,
          longitude: 127.0100 + (random.nextDouble() - 0.5) * 0.01,
          status: '운행중',
          currentStationIndex: random.nextInt(5),
          lastUpdated: now,
        ),
        Bus(
          id: 'bus_273_01',
          routeNumber: '273',
          latitude: 37.5563 + (random.nextDouble() - 0.5) * 0.01,
          longitude: 126.9236 + (random.nextDouble() - 0.5) * 0.01,
          status: '운행중',
          currentStationIndex: random.nextInt(5),
          lastUpdated: now,
        ),
        Bus(
          id: 'bus_370_01',
          routeNumber: '370',
          latitude: 37.5703 + (random.nextDouble() - 0.5) * 0.01,
          longitude: 126.9925 + (random.nextDouble() - 0.5) * 0.01,
          status: '운행중',
          currentStationIndex: random.nextInt(5),
          lastUpdated: now,
        ),
      ];
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
}
