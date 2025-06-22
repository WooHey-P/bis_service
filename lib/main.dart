import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bus_provider.dart';

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

          return Column(
            children: [
              // 검색 바
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
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
              
              // 정류장 목록 또는 검색 결과
              Expanded(
                child: provider.searchQuery.isNotEmpty
                    ? _buildSearchResults(provider)
                    : _buildStationList(provider),
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

  Widget _buildStationList(BusProvider provider) {
    return ListView.builder(
      itemCount: provider.busStops.length,
      itemBuilder: (context, index) {
        final station = provider.busStops[index];
        final busesAtStation = provider.getBusesForStation(station.id);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: Text(station.name),
            subtitle: Text('노선: ${station.routes.join(', ')} | 운행 중: ${busesAtStation.length}대'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 정류장 상세 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${station.name} 상세 정보 (구현 예정)')),
              );
            },
          ),
        );
      },
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
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final station = provider.searchResults[index];
        final busesAtStation = provider.getBusesForStation(station.id);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.search, color: Colors.blue),
            title: Text(station.name),
            subtitle: Text('노선: ${station.routes.join(', ')} | 운행 중: ${busesAtStation.length}대'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 정류장 상세 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${station.name} 상세 정보 (구현 예정)')),
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
