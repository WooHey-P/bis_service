class BusRoute {
  final String id;
  final String routeNumber;
  final String routeName;
  final List<String> stationIds;
  final List<RouteCoordinate> coordinates;
  final String color;

  BusRoute({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.stationIds,
    required this.coordinates,
    required this.color,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      routeNumber: json['routeNumber'],
      routeName: json['routeName'],
      stationIds: List<String>.from(json['stations']),
      coordinates: (json['coordinates'] as List)
          .map((coord) => RouteCoordinate.fromJson(coord))
          .toList(),
      color: json['color'] ?? '#2196F3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeNumber': routeNumber,
      'routeName': routeName,
      'stations': stationIds,
      'coordinates': coordinates.map((coord) => coord.toJson()).toList(),
      'color': color,
    };
  }
}

class RouteCoordinate {
  final double latitude;
  final double longitude;

  RouteCoordinate({
    required this.latitude,
    required this.longitude,
  });

  factory RouteCoordinate.fromJson(Map<String, dynamic> json) {
    return RouteCoordinate(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
