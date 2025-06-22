import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bus_provider.dart';
import 'widgets/bus_route_map.dart';

void main() {
  debugPrint("BIS 애플리케이션 시작");
  runApp(const BusInfoApp());
}

class BusInfoApp extends StatelessWidget {
  const BusInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusProvider()),
      ],
      child: MaterialApp(
        title: '버스 정보 서비스 (BIS)',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const BusInfoHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class BusInfoHomePage extends StatefulWidget {
  const BusInfoHomePage({super.key});

  @override
  State<BusInfoHomePage> createState() => _BusInfoHomePageState();
}

class _BusInfoHomePageState extends State<BusInfoHomePage> {
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
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('데이터를 불러오는 중...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류: ${provider.error}'),
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

          return Stack(
            children: [
              // 메인 지도 화면
              BusRouteMap(
                buses: provider.buses,
                busStops: provider.busStops,
                onBusPositionCalculate: provider.getBusPositionOnImage,
              ),
              
              // 상단 검색 바와 정보 패널
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 검색 바
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '정류장 이름을 검색하세요',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (query) {
                            if (query.isNotEmpty) {
                              provider.searchStations(query);
                            } else {
                              provider.clearSearch();
                            }
                          },
                        ),
                      ),
                      
                      // 정보 카드들
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    ],
                  ),
                ),
              ),
              
              // 검색 결과 패널 (검색 시에만 표시)
              if (provider.searchQuery.isNotEmpty)
                Positioned(
                  top: 160, // 검색바와 정보카드 아래
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '검색 결과',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => provider.clearSearch(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildSearchResults(provider),
                        ),
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
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchResults(BusProvider provider) {
    if (provider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchResults.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final station = provider.searchResults[index];
        final busesAtStation = provider.getBusesForStation(station.id);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.search, color: Colors.blue),
            title: Text(station.name),
            subtitle: Text('노선: ${station.routes.join(', ')} | 운행 중: ${busesAtStation.length}대'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 검색 결과를 닫고 해당 정류장으로 지도 이동
              provider.clearSearch();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${station.name}으로 지도를 이동했습니다'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      },
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
