class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double x; // 이미지 상의 x 좌표 (0.0 ~ 1.0)
  final double y; // 이미지 상의 y 좌표 (0.0 ~ 1.0)

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.x,
    required this.y,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}
