class LottoSpot {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int firstPrizeCount;
  final int secondPrizeCount;

  LottoSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.firstPrizeCount,
    required this.secondPrizeCount,
  });

  factory LottoSpot.fromJson(Map<String, dynamic> json) {
    return LottoSpot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      firstPrizeCount: json['firstPrizeCount'] ?? 0,
      secondPrizeCount: json['secondPrizeCount'] ?? 0,
    );
  }
}
