class Bus {
  final String id;
  final String routeNumber;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime lastUpdated;

  Bus({
    required this.id,
    required this.routeNumber,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.lastUpdated,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      routeNumber: json['routeNumber'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: json['status'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
