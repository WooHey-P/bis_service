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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final provider = Provider.of<BusProvider>(context, listen: false);
        debugPrint('디버깅을 위한 문자열 출력: "Hello, this is a test to check the console output!"');
        debugPrint('로딩 시 맵 상태를 출력합니다.');
        
        debugPrint('버스 정류장 개수: ${provider.busStops.length}');
        debugPrint('버스 개수: ${provider.buses.length}');
        
        // 데이터 로드
        await provider.loadBusStops();
        debugPrint('정류장 데이터 로드 완료');
        
        await provider.loadBuses();
        debugPrint('버스 데이터 로드 완료');
        
        provider.startRealTimeUpdates();
        debugPrint('실시간 업데이트 시작');
        
      } catch (e) {
        debugPrint('로딩 중 에러: $e');
      }
    });
  }

  Future<void> _initializeData(BusProvider provider) async {
    debugPrint('[INIT] _initializeData started');
    await provider.loadBusStops();
    debugPrint('[INIT] BusStops loaded: ${provider.busStops.length}');
    await provider.loadBuses();
    debugPrint('[INIT] Buses loaded: ${provider.buses.length}');
    provider.startRealTimeUpdates();
    debugPrint('[INIT] Real-time updates started');
  }

  @override
  void dispose() {
    final provider = Provider.of<BusProvider>(context, listen: false);
    provider.stopRealTimeUpdates();
    super.dispose();
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
            onPressed: () async {
              debugPrint('[REFRESH] 버스 데이터 새로고침 시작');
              final provider = Provider.of<BusProvider>(context, listen: false);
              await provider.loadBuses();
              debugPrint('[REFRESH] 버스 데이터 새로고침 완료');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              debugPrint('[DEBUG] 버스 정보 서비스 디버깅 모드 진입');
              debugPrint('[DEBUG] 첫 화면 로딩 중');
            },
          ),
        ],
      ),
      body: Consumer<BusProvider>(
        builder: (context, provider, child) {
          debugPrint('[DEBUG] ${provider.runtimeType} 상태 출력');
          
          if (provider.isLoading && provider.busStops.isEmpty) {
            debugPrint('[DEBUG] 데이터 로딩 중');
            return Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: CircularProgressIndicator(),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '로딩 중... 어며딜로딩 중... 커멘텀 로딩 중...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            );
          }

          if (provider.error != null) {
            debugPrint('[DEBUG] 에러 발생: ${provider.error}');
            return Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '오류: ${provider.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '문제 해결 방법:\n1. 새로고침(F5)\n2. 다시 시작하기 버튼 클릭\n3. 문제가 지속되면 콘솔에 오류 메시지 확인',
                        style: const TextStyle(color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          debugPrint('[ERROR] 다시 시도 버튼 클릭');
                          await provider.loadBusStops();
                          await provider.loadBuses();
                          debugPrint('[ERROR] 데이터 로드 후 다시 시작');
                          provider.startRealTimeUpdates();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.error.toString(),
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            );
          }

          return Column(
            children: [
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
