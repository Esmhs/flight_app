class Flight {
  final int id;
  final String from;
  final String to;
  final String time;
  final double? price;
  final String carrier;
  final String carrierCode;
  final String carrierLogo;
  final String date;

  Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.price,
    required this.date,
    required this.time,
    required this.carrier,
    required this.carrierCode,
    required this.carrierLogo,
    // this.price,
    // required this.logoCode,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      time: json['time'] ?? '',
      carrier: json['carrier'] ?? '',
      carrierCode: json['carrierCode'] ?? '',
      carrierLogo: json['carrierLogo'] ?? '',
    );
  }
}