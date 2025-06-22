import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../models/bus_route.dart';

class BusRouteMap extends StatelessWidget {
  final List<Bus> buses;
  final List<BusStop> busStops;
  final List<BusRoute> busRoutes;
  final Map<String, double> Function(Bus) onBusPositionCalculate;

  const BusRouteMap({
    super.key,
    required this.buses,
    required this.busStops,
    required this.busRoutes,
    required this.onBusPositionCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // 실제 지도
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(37.5665, 126.9780), // 서울 시청 중심
              initialZoom: 12.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bus_info_service',
              ),
              // 버스 노선 폴리라인들
              PolylineLayer(
                polylines: busRoutes.map((route) => _buildRoutePolyline(route)).toList(),
              ),
              MarkerLayer(
                markers: [
                  // 정류장 마커들
                  ...busStops.map((stop) => _buildBusStopMapMarker(stop)),
                  // 버스 마커들
                  ...buses.map((bus) => _buildBusMapMarker(bus)),
                ],
              ),
            ],
          ),
          
          // 범례
          Positioned(
            top: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Marker _buildBusStopMapMarker(BusStop stop) {
    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 50,
      height: 60,
      child: Tooltip(
        message: '${stop.name}\n노선: ${stop.routes.join(', ')}',
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade700,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                stop.name,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildBusMapMarker(Bus bus) {
    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 60,
      height: 80,
      child: Tooltip(
        message: '${bus.routeNumber}번 버스\n상태: ${bus.status}\n노선: ${_getRouteName(bus.routeNumber)}',
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  Text(
                    bus.routeNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: bus.status == '운행중' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                bus.status,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRouteName(String routeNumber) {
    // This is a helper method to get route name for tooltip
    switch (routeNumber) {
      case '146':
        return '강남역-노원';
      case '273':
        return '홍대입구-강남역';
      case '370':
        return '시청앞-성수';
      case '502':
        return '잠실-금천구청';
      default:
        return '알 수 없음';
    }
  }

  Polyline _buildRoutePolyline(BusRoute route) {
    return Polyline(
      points: route.coordinates.map((coord) => LatLng(coord.latitude, coord.longitude)).toList(),
      strokeWidth: 4.0,
      color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
      pattern: const StrokePattern.solid(),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '범례',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            icon: Icons.location_on_rounded,
            color: Colors.green.shade600,
            label: '정류장',
            isCircle: true,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            icon: Icons.directions_bus_rounded,
            color: Colors.blue.shade600,
            label: '버스',
            isCircle: false,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '버스 노선',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
    required bool isCircle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
