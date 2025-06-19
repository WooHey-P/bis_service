import 'package:flutter/material.dart';
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
          // 배경 이미지 (노선도)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/800x600/E8F4FD/2196F3?text=Bus+Route+Map',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // 정류장 표시
          ...busStops.map((stop) => _buildBusStopMarker(stop)),
          
          // 버스 위치 표시
          ...buses.map((bus) => _buildBusMarker(bus)),
          
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

  Widget _buildBusStopMarker(BusStop stop) {
    return Positioned(
      left: stop.x * 800 - 12, // 이미지 크기에 맞춰 조정
      top: stop.y * 600 - 12,
      child: Tooltip(
        message: stop.name,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
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
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBusMarker(Bus bus) {
    final position = onBusPositionCalculate(bus);
    
    return Positioned(
      left: position['x']! * 800 - 16,
      top: position['y']! * 600 - 16,
      child: Tooltip(
        message: '${bus.routeNumber}번 버스\n상태: ${bus.status}',
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
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
                size: 16,
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
