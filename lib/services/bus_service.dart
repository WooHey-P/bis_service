import 'dart:convert';
import 'dart:developer'; // debugPrint를 사용하기 위해 추가
import 'package:http/http.dart' as http;
import '../models/bus.dart';
import '../models/bus_stop.dart';

class BusService {
  static const String baseUrl = 'https://api.example.com'; // 실제 API URL로 변경

  Future<List<BusStop>> getBusStops() async {
    debugPrint("BusService: getBusStops 호출됨"); // 로그 추가
    try {
      // 실제 API 호출 대신 더미 데이터 반환
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        BusStop(
          id: '1',
          name: '시청앞',
          latitude: 37.5665,
          longitude: 126.9780,
          x: 0.2,
          y: 0.3,
        ),
        BusStop(
          id: '2',
          name: '강남역',
          latitude: 37.4979,
          longitude: 127.0276,
          x: 0.7,
          y: 0.6,
        ),
        BusStop(
          id: '3',
          name: '홍대입구',
          latitude: 37.5563,
          longitude: 126.9236,
          x: 0.4,
          y: 0.2,
        ),
      ];
    } catch (e) {
      throw Exception('정류장 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<Bus>> getBuses() async {
    debugPrint("BusService: getBuses 호출됨"); // 로그 추가
    try {
      // 실제 API 호출 대신 더미 데이터 반환
      await Future.delayed(const Duration(milliseconds: 300));
      
      return [
        Bus(
          id: 'bus1',
          routeNumber: '146',
          latitude: 37.5600 + (DateTime.now().millisecond % 100) * 0.0001,
          longitude: 126.9700 + (DateTime.now().millisecond % 100) * 0.0001,
          status: '운행중',
          lastUpdated: DateTime.now(),
        ),
        Bus(
          id: 'bus2',
          routeNumber: '146',
          latitude: 37.5200 + (DateTime.now().millisecond % 100) * 0.0001,
          longitude: 127.0100 + (DateTime.now().millisecond % 100) * 0.0001,
          status: '운행중',
          lastUpdated: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('버스 정보를 불러오는데 실패했습니다: $e');
    }
  }
}
