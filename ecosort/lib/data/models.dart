class User {
  final int? id;
  final String name;
  final String email;
  final int points;

  User({this.id, required this.name, required this.email, this.points = 0});

  factory User.fromMap(Map<String, dynamic> m) => User(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
        points: m['points'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'email': email, 'points': points};

  int get level => (points ~/ 100) + 1;
  int get levelProgress => points % 100;
}

class SortRecord {
  final int? id;
  final int userId;
  final String wasteType;
  final int points;
  final DateTime createdAt;

  SortRecord({
    this.id,
    required this.userId,
    required this.wasteType,
    this.points = 10,
    required this.createdAt,
  });

  factory SortRecord.fromMap(Map<String, dynamic> m) => SortRecord(
        id: m['id'] as int,
        userId: m['user_id'] as int,
        wasteType: m['waste_type'] as String,
        points: m['points'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'waste_type': wasteType,
        'points': points,
        'created_at': createdAt.millisecondsSinceEpoch,
      };
}

class RecyclingCenter {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final double distanceKm;
  final String hours;
  final List<String> materials;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.hours,
    required this.materials,
  });

  factory RecyclingCenter.fromMap(Map<String, dynamic> m) => RecyclingCenter(
        id: m['id'] as int,
        name: m['name'] as String,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        distanceKm: (m['distance_km'] as num).toDouble(),
        hours: m['hours'] as String,
        materials: (m['materials'] as String).split(','),
      );
}

class Challenge {
  final int id;
  final String title;
  final String? wasteType; // null = any type
  final int goal;
  int progress;
  bool joined;

  Challenge({
    required this.id,
    required this.title,
    this.wasteType,
    required this.goal,
    this.progress = 0,
    this.joined = false,
  });
}

class EcoBadge {
  final String name;
  final String description;
  final bool earned;

  const EcoBadge(
      {required this.name, required this.description, required this.earned});
}
