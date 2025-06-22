import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bus_provider.dart';
import 'widgets/bus_route_map.dart';
import 'screens/route_detail_screen.dart';
import 'widgets/custom_icons.dart';

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_bus, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('버스 정보 서비스 (BIS)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.refresh, size: 20),
              ),
              onPressed: () {
                final provider = Provider.of<BusProvider>(context, listen: false);
                provider.loadBuses();
              },
              tooltip: '데이터 새로고침',
            ),
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
                width: 380,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: _buildLeftPanel(provider),
              ),
              
              // 메인 지도 화면
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: BusRouteMap(
                    buses: provider.visibleBusesData,
                    busStops: provider.visibleStationsData,
                    busRoutes: provider.visibleRoutesData,
                    onBusPositionCalculate: provider.getBusPositionOnImage,
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

  Widget _buildLeftPanel(BusProvider provider) {
    return Column(
      children: [
        // 상단 정보 카드들
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: Column(
            children: [
              // 실시간 상태 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '실시간 업데이트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSmallInfoCard(
                    '버스',
                    '${provider.buses.length}대',
                    Icons.directions_bus_rounded,
                    Colors.white,
                    Colors.blue.shade800,
                  ),
                  _buildSmallInfoCard(
                    '정류장',
                    '${provider.busStops.length}개',
                    Icons.location_on_rounded,
                    Colors.white,
                    Colors.blue.shade800,
                  ),
                  _buildSmallInfoCard(
                    '노선',
                    '${provider.busRoutes.length}개',
                    Icons.route_rounded,
                    Colors.white,
                    Colors.blue.shade800,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 검색 바
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '정류장, 버스 번호 검색...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ],
          ),
        ),
        
        // 탭 컨트롤
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TabBar(
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.blue.shade700,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.route_rounded),
                        text: '노선',
                        iconMargin: const EdgeInsets.only(bottom: 4),
                      ),
                      Tab(
                        icon: Icon(Icons.directions_bus_rounded),
                        text: '버스',
                        iconMargin: const EdgeInsets.only(bottom: 4),
                      ),
                      Tab(
                        icon: Icon(Icons.location_on_rounded),
                        text: '정류장',
                        iconMargin: const EdgeInsets.only(bottom: 4),
                      ),
                    ],
                  ),
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

  Widget _buildSmallInfoCard(String title, String value, IconData icon, Color iconColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesTab(BusProvider provider) {
    return Column(
      children: [
        // 전체 선택/해제 버튼
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.showAllRoutes,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('전체 표시'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.hideAllRoutes,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('전체 숨김'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.busRoutes.length,
            itemBuilder: (context, index) {
              final route = provider.busRoutes[index];
              final isVisible = provider.visibleRoutes.contains(route.routeNumber);
              final routeBuses = provider.getBusesForRoute(route.routeNumber);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isVisible ? Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        Text(
                          route.routeNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    route.routeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '운행 중: ${routeBuses.length}대',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteDetailScreen(route: route),
                            ),
                          );
                        },
                        tooltip: '노선 상세 보기',
                      ),
                      Switch(
                        value: isVisible,
                        onChanged: (_) => provider.toggleRouteVisibility(route.routeNumber),
                        activeColor: Color(int.parse(route.color.substring(1), radix: 16) + 0xFF000000),
                      ),
                    ],
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.showAllBuses,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('전체 표시'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.hideAllBuses,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('전체 숨김'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.buses.length,
            itemBuilder: (context, index) {
              final bus = provider.buses[index];
              final isVisible = provider.visibleBuses.contains(bus.id);
              final route = provider.busRoutes.firstWhere(
                (r) => r.routeNumber == bus.routeNumber,
                orElse: () => provider.busRoutes.first,
              );
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isVisible ? Colors.blue.shade600 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade800,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        Text(
                          bus.routeNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    '${bus.routeNumber}번 버스',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: bus.status == '운행중' ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                bus.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              route.routeName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Switch(
                    value: isVisible,
                    onChanged: (_) => provider.toggleBusVisibility(bus.id),
                    activeColor: Colors.blue.shade600,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.showAllStations,
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('전체 표시'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.hideAllStations,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('전체 숨김'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              final isVisible = provider.visibleStations.contains(station.id);
              final busesAtStation = provider.getBusesForStation(station.id);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isVisible ? Colors.green.shade600 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.route_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '노선: ${station.routes.join(', ')}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.directions_bus_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '운행 중: ${busesAtStation.length}대',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Switch(
                    value: isVisible,
                    onChanged: (_) => provider.toggleStationVisibility(station.id),
                    activeColor: Colors.green.shade600,
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
