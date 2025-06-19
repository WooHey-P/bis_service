import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';

class BusRouteMap extends StatelessWidget {
  final List<Bus> buses;
  final List<BusStop> busStops;
  final Map<String, double> Function(Bus) onBusPositionCalculate;

  const BusRouteMap({
    super.key,
    required this.buses,
    required this.busStops,
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
      width: 40,
      height: 40,
      child: Tooltip(
        message: stop.name,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Marker _buildBusMapMarker(Bus bus) {
    return Marker(
      point: LatLng(bus.latitude, bus.longitude),
      width: 50,
      height: 50,
      child: Tooltip(
        message: '${bus.routeNumber}번 버스\n상태: ${bus.status}',
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 20,
              ),
              Text(
                bus.routeNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '범례',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              const Text('정류장'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              const Text('버스'),
            ],
          ),
        ],
      ),
    );
  }
}
