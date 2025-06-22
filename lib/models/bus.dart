class Bus {
  final String id;
  final String routeNumber;
  final double latitude;
  final double longitude;
  final String status;
  final int currentStationIndex; // 현재 정류장 인덱스
  final DateTime lastUpdated;

  Bus({
    required this.id,
    required this.routeNumber,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.currentStationIndex,
    required this.lastUpdated,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      routeNumber: json['routeNumber'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: json['status'],
      currentStationIndex: json['currentStationIndex'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeNumber': routeNumber,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'currentStationIndex': currentStationIndex,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
