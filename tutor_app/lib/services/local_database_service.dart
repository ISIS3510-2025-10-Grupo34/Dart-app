import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/review_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE pending_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tutoringSessionId INTEGER,
        tutorId INTEGER,
        studentId INTEGER,
        rating REAL,
        comment TEXT
      )
    ''');
  }

  Future<void> cachePendingReview(Review review) async {
    final db = await database;
    await db.insert('pending_reviews', review.toJson());
  }

  Future<List<Review>> getPendingReviews() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pending_reviews');
    return List.generate(maps.length, (i) => Review.fromJson(maps[i]));
  }

  Future<void> removePendingReview(Review review) async {
    final db = await database;
    await db.delete(
      'pending_reviews',
      where: 'tutoringSessionId = ?',
      whereArgs: [review.tutoringSessionId],
    );
  }

  Future<bool> hasReviewForSession(int sessionId) async {
    final db = await database;
    final result = await db.query(
      'pending_reviews',
      where: 'tutoringSessionId = ?',
      whereArgs: [sessionId],
    );
    return result.isNotEmpty;
  }
}