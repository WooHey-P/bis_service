import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import '../models/bus_route.dart';
import 'custom_icons.dart';

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
      width: 60,
      height: 80,
      child: Tooltip(
        message: '${stop.name}\n노선: ${stop.routes.join(', ')}',
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomIcons.busStopIcon(
            size: 50,
            color: Colors.green.shade600,
            stationName: stop.name,
          ),
        ),
      ),
    );
  }

  Marker _buildBusMapMarker(Bus bus) {
    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 70,
      height: 85,
      child: Tooltip(
        message: '${bus.routeNumber}번 버스\n상태: ${bus.status}\n노선: ${_getRouteName(bus.routeNumber)}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 버스 번호를 가로로 한줄로 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getBusColor(bus.routeNumber),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                bus.routeNumber,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomIcons.busIcon(
                size: 50,
                color: _getBusColor(bus.routeNumber),
                routeNumber: null, // 버스 아이콘에서는 번호를 제거
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: bus.status == '운행중' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
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

  Color _getBusColor(String routeNumber) {
    switch (routeNumber) {
      case '146':
        return Colors.blue.shade600;
      case '273':
        return Colors.green.shade600;
      case '370':
        return Colors.orange.shade600;
      case '502':
        return Colors.purple.shade600;
      default:
        return Colors.blue.shade600;
    }
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
          _buildCustomLegendItem(
            widget: CustomIcons.busStopIcon(size: 20, color: Colors.green.shade600),
            label: '정류장',
          ),
          const SizedBox(height: 8),
          _buildCustomLegendItem(
            widget: CustomIcons.busIcon(size: 20, color: Colors.blue.shade600),
            label: '버스',
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

  Widget _buildCustomLegendItem({
    required Widget widget,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          child: widget,
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
