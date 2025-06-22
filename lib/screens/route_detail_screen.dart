import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bus_route.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../providers/bus_provider.dart';
import '../widgets/custom_icons.dart';

class RouteDetailScreen extends StatelessWidget {
  final BusRoute route;

  const RouteDetailScreen({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${route.routeNumber}번 노선'),
        backgroundColor: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BusProvider>(
        builder: (context, provider, child) {
          final routeBuses = provider.getBusesForRoute(route.routeNumber);
          final routeStations = _getRouteStations(provider.busStops, route.stationIds);
          
          return Column(
            children: [
              // 노선 정보 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                      Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIcons.busIcon(
                            size: 40,
                            color: Colors.white,
                            routeNumber: route.routeNumber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.routeName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '총 ${routeStations.length}개 정류장',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            '운행 중인 버스',
                            '${routeBuses.length}대',
                            Icons.directions_bus_rounded,
                          ),
                          _buildInfoItem(
                            '총 정류장',
                            '${routeStations.length}개',
                            Icons.location_on_rounded,
                          ),
                          _buildInfoItem(
                            '노선 길이',
                            '${_calculateRouteLength(route).toStringAsFixed(1)}km',
                            Icons.straighten_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 노선 상세 정보
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '노선도',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRouteVisualization(routeStations, routeBuses, route),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteVisualization(List<BusStop> stations, List<Bus> buses, BusRoute route) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < stations.length; i++) ...[
            _buildStationItem(
              stations[i],
              i,
              stations.length - 1,
              buses,
              route,
            ),
            if (i < stations.length - 1) _buildConnectionLine(buses, i, route),
          ],
        ],
      ),
    );
  }

  Widget _buildStationItem(BusStop station, int index, int lastIndex, List<Bus> buses, BusRoute route) {
    final busesAtStation = buses.where((bus) => bus.currentStationIndex == index).toList();
    final isTerminal = index == 0 || index == lastIndex;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 정류장 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isTerminal 
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: (isTerminal ? Colors.red : Colors.green).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTerminal ? Icons.flag_rounded : Icons.location_on_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 정류장 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTerminal ? (index == 0 ? '시점' : '종점') : '경유지',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (busesAtStation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: busesAtStation.map((bus) => _buildBusChip(bus, route)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionLine(List<Bus> buses, int stationIndex, BusRoute route) {
    // 이 구간에 있는 버스들 찾기 (정류장 사이를 이동 중인 버스)
    final busesInSegment = buses.where((bus) {
      return bus.currentStationIndex == stationIndex;
    }).toList();
    
    return Container(
      height: 60,
      child: Row(
        children: [
          // 연결선
          Container(
            width: 50,
            child: Center(
              child: Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
                      Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                      Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 이동 중인 버스들
          Expanded(
            child: busesInSegment.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: busesInSegment.map((bus) => 
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: _buildMovingBusIndicator(bus, route),
                        )
                      ).toList(),
                    ),
                  )
                : Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '이동 중인 버스 없음',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusChip(Bus bus, BusRoute route) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcons.busIcon(
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            bus.id.split('_').last,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovingBusIndicator(Bus bus, BusRoute route) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcons.busIcon(
            size: 20,
            color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bus.id.split('_').last,
                style: TextStyle(
                  color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: bus.status == '운행중' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '이동중',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BusStop> _getRouteStations(List<BusStop> allStations, List<String> stationIds) {
    return stationIds.map((id) {
      return allStations.firstWhere(
        (station) => station.id == id,
        orElse: () => BusStop(
          id: id,
          name: '알 수 없는 정류장',
          latitude: 0,
          longitude: 0,
          x: 0,
          y: 0,
          routes: [],
        ),
      );
    }).toList();
  }

  double _calculateRouteLength(BusRoute route) {
    if (route.coordinates.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < route.coordinates.length - 1; i++) {
      final coord1 = route.coordinates[i];
      final coord2 = route.coordinates[i + 1];
      totalDistance += _calculateDistance(
        coord1.latitude,
        coord1.longitude,
        coord2.latitude,
        coord2.longitude,
      );
    }
    return totalDistance;
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
