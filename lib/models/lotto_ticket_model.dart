class LottoTicket {
  final int id;
  final String url;
  final int ordinal;
  final String status;
  final DateTime createdAt;

  LottoTicket({
    required this.id,
    required this.url,
    required this.ordinal,
    required this.status,
    required this.createdAt,
  });

  factory LottoTicket.fromJson(Map<String, dynamic> json) {
    return LottoTicket(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      ordinal: json['ordinal'] ?? 0,
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
