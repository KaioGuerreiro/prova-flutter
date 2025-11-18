class Vehicle {
  String? id;
  String name;
  String plate;
  int km;

  Vehicle({this.id, required this.name, required this.plate, required this.km});

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        id: map['id']?.toString(),
        name: map['name'] as String? ?? '',
        plate: map['plate'] as String? ?? '',
        km: (map['km'] is int)
            ? map['km'] as int
            : int.tryParse((map['km'] ?? '0').toString()) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'plate': plate,
        'km': km,
      };
}
