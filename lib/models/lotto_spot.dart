

class LottoSpot {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int firstPlaceWins;
  final int secondPlaceWins;
  final DateTime lastUpdated;

  LottoSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.firstPlaceWins,
    required this.secondPlaceWins,
    required this.lastUpdated,
  });

  factory LottoSpot.fromJson(Map<String, dynamic> json) {
    return LottoSpot(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      firstPlaceWins: json['firstPlaceWins'] as int,
      secondPlaceWins: json['secondPlaceWins'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'firstPlaceWins': firstPlaceWins,
      'secondPlaceWins': secondPlaceWins,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
