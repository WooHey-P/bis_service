import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/bus_map_screen.dart';
import 'providers/bus_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Information Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => BusProvider()..loadBusStops()..loadBuses(),
        child: const BusMapScreen(),
      ),
    );
  }
}
