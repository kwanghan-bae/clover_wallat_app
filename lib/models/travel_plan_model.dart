import 'dart:convert';

class TravelPlanModel {
  final int id;
  final int spotId;
  final String title;
  final String description;
  final List<TravelPlace> places;
  final String theme;
  final int estimatedHours;
  final DateTime createdAt;

  TravelPlanModel({
    required this.id,
    required this.spotId,
    required this.title,
    required this.description,
    required this.places,
    required this.theme,
    required this.estimatedHours,
    required this.createdAt,
  });

  factory TravelPlanModel.fromMap(Map<String, dynamic> map) {
    // Parse places JSON string
    final placesJson = json.decode(map['places'] as String) as List;
    final placesList = placesJson
        .map((p) => TravelPlace.fromMap(p as Map<String, dynamic>))
        .toList();

    return TravelPlanModel(
      id: map['id'],
      spotId: map['spotId'],
      title: map['title'],
      description: map['description'],
      places: placesList,
      theme: map['theme'],
      estimatedHours: map['estimatedHours'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class TravelPlace {
  final String name;
  final String type; // lotto_spot, tourism, restaurant
  final double lat;
  final double lng;

  TravelPlace({
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
  });

  factory TravelPlace.fromMap(Map<String, dynamic> map) {
    return TravelPlace(
      name: map['name'],
      type: map['type'],
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }

  String get typeIcon {
    switch (type) {
      case 'lotto_spot':
        return '🍀';
      case 'tourism':
        return '🏛️';
      case 'restaurant':
        return '🍴';
      default:
        return '📍';
    }
  }
}
