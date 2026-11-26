import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'ecosort.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('''
      CREATE TABLE sort_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        waste_type TEXT NOT NULL,
        points INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE centers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        distance_km REAL NOT NULL,
        hours TEXT NOT NULL,
        materials TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE challenges(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        waste_type TEXT,
        goal INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE user_challenges(
        user_id INTEGER NOT NULL,
        challenge_id INTEGER NOT NULL,
        joined_at INTEGER NOT NULL,
        PRIMARY KEY(user_id, challenge_id)
      )''');

    final batch = db.batch();
    for (final c in _seedCenters) {
      batch.insert('centers', c);
    }
    for (final ch in _seedChallenges) {
      batch.insert('challenges', ch);
    }
    await batch.commit(noResult: true);
  }

  static const _seedCenters = [
    {
      'name': 'Center 1 · Kamwokya Recycling Hub',
      'lat': 0.3180,
      'lng': 32.5720,
      'distance_km': 1.2,
      'hours': 'Mon–Sat 8:00–17:00',
      'materials': 'Plastic,Paper,Metal'
    },
    {
      'name': 'Center 2 · Ntinda Eco Center',
      'lat': 0.3280,
      'lng': 32.5980,
      'distance_km': 2.3,
      'hours': 'Mon–Sat 8:00–17:00',
      'materials': 'Plastic,Glass,E-waste'
    },
    {
      'name': 'Center 3 · Kiseeva Compost Site',
      'lat': 0.2960,
      'lng': 32.5560,
      'distance_km': 3.4,
      'hours': 'Mon–Sat 8:00–17:00',
      'materials': 'Food,Clothes'
    },
    {
      'name': 'Center 4 · Nakawa Drop-off Point',
      'lat': 0.3090,
      'lng': 32.5870,
      'distance_km': 4.1,
      'hours': 'Daily 9:00–18:00',
      'materials': 'Plastic,Paper,Glass,Metal'
    },
    {
      'name': 'Center 5 · Bwire Recycling Plant',
      'lat': 0.3420,
      'lng': 32.6120,
      'distance_km': 6.8,
      'hours': 'Mon–Fri 8:30–16:30',
      'materials': 'Plastic,Paper,Glass,Metal,Batteries,E-waste'
    },
  ];

  static const _seedChallenges = [
    {'title': 'Recycle 10 plastic bottles', 'waste_type': 'Plastic', 'goal': 10},
    {'title': 'Compost 5 food items', 'waste_type': 'Food', 'goal': 5},
    {'title': 'Sort 15 items of any type', 'waste_type': null, 'goal': 15},
  ];

  // ---------- auth ----------

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<User> signup(String name, String email, String password) async {
    final d = await db;
    final existing = await d.query('users',
        where: 'email = ?', whereArgs: [email.toLowerCase()], limit: 1);
    if (existing.isNotEmpty) {
      throw AuthException('An account with this email already exists.');
    }
    final salt = base64.encode(
        List<int>.generate(16, (_) => Random.secure().nextInt(256)));
    final id = await d.insert('users', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': _hash(password, salt),
      'salt': salt,
      'points': 0,
    });
    return User(id: id, name: name.trim(), email: email.trim().toLowerCase());
  }

  Future<User> login(String email, String password) async {
    final d = await db;
    final rows = await d.query('users',
        where: 'email = ?', whereArgs: [email.trim().toLowerCase()], limit: 1);
    if (rows.isEmpty) {
      throw AuthException('No account found for this email.');
    }
    final row = rows.first;
    if (_hash(password, row['salt'] as String) != row['password_hash']) {
      throw AuthException('Incorrect password. Try again.');
    }
    return User.fromMap(row);
  }

  Future<User?> userById(int id) async {
    final d = await db;
    final rows = await d.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }

  Future<void> updateName(int userId, String name) async {
    final d = await db;
    await d.update('users', {'name': name.trim()},
        where: 'id = ?', whereArgs: [userId]);
  }

  // ---------- sorting / tracking ----------

  Future<void> recordSort(int userId, String wasteType) async {
    final d = await db;
    await d.insert('sort_records', SortRecord(
      userId: userId,
      wasteType: wasteType,
      createdAt: DateTime.now(),
    ).toMap());
    await d.rawUpdate(
        'UPDATE users SET points = points + 10 WHERE id = ?', [userId]);
  }

  Future<User?> refreshUser(int userId) => userById(userId);

  Future<void> resetProgress(int userId) async {
    final d = await db;
    await d.delete('sort_records',
        where: 'user_id = ?', whereArgs: [userId]);
    await d.delete('user_challenges',
        where: 'user_id = ?', whereArgs: [userId]);
    await d.update('users', {'points': 0}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> itemCount(int userId) async {
    final d = await db;
    final r = await d.rawQuery(
        'SELECT COUNT(*) c FROM sort_records WHERE user_id = ?', [userId]);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<Map<String, int>> sortedByType(int userId) async {
    final d = await db;
    final rows = await d.rawQuery(
        'SELECT waste_type, COUNT(*) c FROM sort_records '
        'WHERE user_id = ? GROUP BY waste_type ORDER BY c DESC',
        [userId]);
    return {
      for (final r in rows) r['waste_type'] as String: r['c'] as int,
    };
  }

  Future<List<EcoBadge>> badges(int userId) async {
    final byType = await sortedByType(userId);
    final total = await itemCount(userId);
    final user = await userById(userId);
    final points = user?.points ?? 0;

    int count(String t) => byType[t] ?? 0;

    return [
      EcoBadge(name: 'First sort',
          description: 'Record your first sorted item',
          earned: total >= 1),
      EcoBadge(name: '10 items',
          description: 'Sort 10 items in total',
          earned: total >= 10),
      EcoBadge(name: 'Plastic hero',
          description: 'Recycle 5 plastic items',
          earned: count('Plastic') >= 5),
      EcoBadge(name: 'Compost pro',
          description: 'Compost 5 food items',
          earned: count('Food') >= 5),
      EcoBadge(name: 'E-waste',
          description: 'Dispose of 1 item at an e-waste point',
          earned: count('E-waste') >= 1),
      EcoBadge(name: '50 pts',
          description: 'Collect 50 eco points',
          earned: points >= 50),
    ];
  }

  // ---------- centers ----------

  Future<List<RecyclingCenter>> centers() async {
    final d = await db;
    final rows =
        await d.query('centers', orderBy: 'distance_km ASC');
    return rows.map(RecyclingCenter.fromMap).toList();
  }

  // ---------- challenges ----------

  Future<List<Challenge>> challenges(int userId) async {
    final d = await db;
    final defs = await d.query('challenges', orderBy: 'id ASC');
    final joined = await d.query('user_challenges',
        where: 'user_id = ?', whereArgs: [userId]);
    final joinedIds = {for (final j in joined) j['challenge_id'] as int};
    final joinedAt = {
      for (final j in joined)
        j['challenge_id'] as int: j['joined_at'] as int
    };

    final result = <Challenge>[];
    for (final row in defs) {
      final id = row['id'] as int;
      final type = row['waste_type'] as String?;
      final isJoined = joinedIds.contains(id);
      int progress;
      if (isJoined) {
        final args = <Object?>[userId, joinedAt[id]];
        final where = type == null
            ? 'user_id = ? AND created_at >= ?'
            : 'user_id = ? AND created_at >= ? AND waste_type = ?';
        if (type != null) args.add(type);
        final r = await d.rawQuery(
            'SELECT COUNT(*) c FROM sort_records WHERE $where', args);
        progress = Sqflite.firstIntValue(r) ?? 0;
      } else {
        progress = 0;
      }
      result.add(Challenge(
        id: id,
        title: row['title'] as String,
        wasteType: type,
        goal: row['goal'] as int,
        progress: progress,
        joined: isJoined,
      ));
    }
    return result;
  }

  Future<void> joinChallenge(int userId, int challengeId) async {
    final d = await db;
    await d.insert('user_challenges', {
      'user_id': userId,
      'challenge_id': challengeId,
      'joined_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
