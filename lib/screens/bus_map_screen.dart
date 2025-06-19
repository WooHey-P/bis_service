import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';
import '../widgets/bus_route_map.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusProvider>(context, listen: false);
      provider.loadBusStops();
      provider.loadBuses();
      provider.startRealTimeUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버스 정보 서비스'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<BusProvider>(context, listen: false);
              provider.loadBuses();
            },
          ),
        ],
      ),
      body: Consumer<BusProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.busStops.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오류: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadBusStops();
                      provider.loadBuses();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 상단 정보 패널
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(
                      '운행 중인 버스',
                      '${provider.buses.length}대',
                      Icons.directions_bus,
                      Colors.blue,
                    ),
                    _buildInfoCard(
                      '정류장',
                      '${provider.busStops.length}개',
                      Icons.location_on,
                      Colors.green,
                    ),
                    _buildInfoCard(
                      '마지막 업데이트',
                      _getLastUpdateTime(provider),
                      Icons.update,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              // 버스 노선도
              Expanded(
                child: BusRouteMap(
                  buses: provider.buses,
                  busStops: provider.busStops,
                  onBusPositionCalculate: provider.getBusPositionOnImage,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastUpdateTime(BusProvider provider) {
    if (provider.buses.isEmpty) return '-';
    final now = DateTime.now();
    final lastUpdate = provider.buses.first.lastUpdated;
    final diff = now.difference(lastUpdate).inSeconds;
    return '${diff}초 전';
  }
}
