class Refuel {
  String? id;
  String vehicleId;
  String date; // ISO string
  double liters;
  double price;
  int km;

  Refuel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.price,
    required this.km,
  });

  factory Refuel.fromMap(Map<String, dynamic> map) => Refuel(
        id: map['id']?.toString(),
        vehicleId: map['vehicle_id']?.toString() ?? '',
        date: map['date'] as String? ?? '',
        liters: (map['liters'] as num?)?.toDouble() ?? 0.0,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        km: (map['km'] is int)
            ? map['km'] as int
            : int.tryParse((map['km'] ?? '0').toString()) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'vehicle_id': vehicleId,
        'date': date,
        'liters': liters,
        'price': price,
        'km': km,
      };
}
