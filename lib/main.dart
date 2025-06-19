import 'package:flutter/material.dart';
import 'package:flutter_web_browser/web_browser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/bus_map_screen.dart';
import 'providers/bus_provider.dart';

void main() {
  debugPrint("애플리케이션 시작");
  debugPrint("ChangeNotifierProvider 생성 및 데이터 로드");
  final provider = BusProvider()..loadBusStops()..loadBuses();
  debugPrint("데이터 로드 후 시작");
  
  runApp(MaterialApp(
    title: '버스 정보 서비스',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: ChangeNotifierProvider(
      create: (context) => provider,
      child: const BusMapScreen(),
    ),
  ));
}
