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
      provider.loadBusRoutes();
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

          return Row(
            children: [
              // 왼쪽 패널
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: _buildLeftPanel(provider),
              ),
              
              // 메인 지도 화면
              Expanded(
                child: BusRouteMap(
                  buses: provider.visibleBusesData,
                  busStops: provider.visibleStationsData,
                  busRoutes: provider.visibleRoutesData,
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

  Widget _buildLeftPanel(BusProvider provider) {
    return Column(
      children: [
        // 상단 정보 카드들
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSmallInfoCard(
                    '버스',
                    '${provider.buses.length}대',
                    Icons.directions_bus,
                    Colors.blue,
                  ),
                  _buildSmallInfoCard(
                    '정류장',
                    '${provider.busStops.length}개',
                    Icons.location_on,
                    Colors.green,
                  ),
                  _buildSmallInfoCard(
                    '노선',
                    '${provider.busRoutes.length}개',
                    Icons.route,
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 검색 바
              TextField(
                decoration: const InputDecoration(
                  hintText: '검색...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    provider.searchStations(query);
                  } else {
                    provider.clearSearch();
                  }
                },
              ),
            ],
          ),
        ),
        
        // 탭 컨트롤
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.route), text: '노선'),
                    Tab(icon: Icon(Icons.directions_bus), text: '버스'),
                    Tab(icon: Icon(Icons.location_on), text: '정류장'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildRoutesTab(provider),
                      _buildBusesTab(provider),
                      _buildStationsTab(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutesTab(BusProvider provider) {
    return Column(
      children: [
        // 전체 선택/해제 버튼
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.showAllRoutes,
                  child: const Text('전체 표시'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.hideAllRoutes,
                  child: const Text('전체 숨김'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.busRoutes.length,
            itemBuilder: (context, index) {
              final route = provider.busRoutes[index];
              final isVisible = provider.visibleRoutes.contains(route.routeNumber);
              final routeBuses = provider.getBusesForRoute(route.routeNumber);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        route.routeNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  title: Text(route.routeName),
                  subtitle: Text('운행 중: ${routeBuses.length}대'),
                  trailing: Switch(
                    value: isVisible,
                    onChanged: (_) => provider.toggleRouteVisibility(route.routeNumber),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusesTab(BusProvider provider) {
    return Column(
      children: [
        // 전체 선택/해제 버튼
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.showAllBuses,
                  child: const Text('전체 표시'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.hideAllBuses,
                  child: const Text('전체 숨김'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.buses.length,
            itemBuilder: (context, index) {
              final bus = provider.buses[index];
              final isVisible = provider.visibleBuses.contains(bus.id);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text('${bus.routeNumber}번 버스'),
                  subtitle: Text('상태: ${bus.status}'),
                  trailing: Switch(
                    value: isVisible,
                    onChanged: (_) => provider.toggleBusVisibility(bus.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStationsTab(BusProvider provider) {
    final stations = provider.searchQuery.isNotEmpty 
        ? provider.searchResults 
        : provider.busStops;
    
    return Column(
      children: [
        // 전체 선택/해제 버튼
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.showAllStations,
                  child: const Text('전체 표시'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.hideAllStations,
                  child: const Text('전체 숨김'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              final isVisible = provider.visibleStations.contains(station.id);
              final busesAtStation = provider.getBusesForStation(station.id);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: Text(station.name),
                  subtitle: Text('노선: ${station.routes.join(', ')}\n운행 중: ${busesAtStation.length}대'),
                  trailing: Switch(
                    value: isVisible,
                    onChanged: (_) => provider.toggleStationVisibility(station.id),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
