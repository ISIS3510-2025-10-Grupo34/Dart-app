import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/review_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
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
    await db.execute('''
    CREATE TABLE reviews (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tutoringSessionId INTEGER UNIQUE,
      tutorId INTEGER NOT NULL,
      studentId INTEGER NOT NULL,
      rating REAL NOT NULL,
      comment TEXT NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');
    await db.execute('''
    CREATE TABLE universities (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
  ''');

    await db.execute('''
    CREATE TABLE majors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      university_id INTEGER NOT NULL,
      FOREIGN KEY (university_id) REFERENCES universities (id) ON DELETE CASCADE
    )
  ''');

    await db
        .execute('CREATE INDEX idx_major_university ON majors (university_id)');

    await db.execute('''
    CREATE TABLE areas_of_expertise (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
  ''');

    await db.execute('''
    CREATE TABLE tutors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone_number TEXT NOT NULL,
      role TEXT NOT NULL,
      profile_picture TEXT,
      id_profile_picture TEXT,
      average_rating REAL,
      university_id INTEGER NOT NULL,
      major_id INTEGER NOT NULL,
      area_of_expertise_id INTEGER NOT NULL,
      FOREIGN KEY (university_id) REFERENCES universities (id) ON DELETE CASCADE,
      FOREIGN KEY (major_id) REFERENCES majors (id) ON DELETE CASCADE,
      FOREIGN KEY (area_of_expertise_id) REFERENCES areas_of_expertise (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE courses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      course_name TEXT NOT NULL,
      university_id INTEGER NOT NULL,
      FOREIGN KEY (university_id) REFERENCES universities (id) ON DELETE CASCADE
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

  Future<int> insertUniversity(String name) async {
    final db = await database;
    try {
      return await db.insert('universities', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      return -1;
    }
  }

  Future<void> bulkInsertUniversities(List<String> universityNames) async {
    final db = await database;
    Batch batch = db.batch();
    for (String name in universityNames) {
      batch.insert('universities', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<String>> getUniversities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('universities', orderBy: 'name');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int?> getUniversityIdByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'universities',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int?;
    }
    return null;
  }

  Future<int> insertMajor(String name, int universityId) async {
    final db = await database;
    try {
      final existing = await db.query('majors',
          where: 'name = ? AND university_id = ?',
          whereArgs: [name, universityId]);
      if (existing.isNotEmpty) return existing.first['id'] as int;

      return await db
          .insert('majors', {'name': name, 'university_id': universityId});
    } catch (e) {
      return -1;
    }
  }

  Future<void> bulkInsertMajorsForUniversity(
      String universityName, List<String> majorNames) async {
    final universityId = await getUniversityIdByName(universityName);
    if (universityId == null) {
      return;
    }
    final db = await database;
    Batch batch = db.batch();
    for (String name in majorNames) {
      batch.insert('majors', {'name': name, 'university_id': universityId});
    }
    await batch.commit(noResult: true);
  }

  Future<List<String>> getMajorsByUniversityName(String universityName) async {
    final universityId = await getUniversityIdByName(universityName);
    if (universityId == null) return [];

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('majors',
        columns: ['name'],
        where: 'university_id = ?',
        whereArgs: [universityId],
        orderBy: 'name');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int> insertAreaOfExpertise(String name) async {
    final db = await database;
    try {
      return await db.insert('areas_of_expertise', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      return -1;
    }
  }

  Future<void> bulkInsertAreasOfExpertise(List<String> areaNames) async {
    final db = await database;
    Batch batch = db.batch();
    for (String name in areaNames) {
      batch.insert('areas_of_expertise', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<String>> getAreasOfExpertise() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('areas_of_expertise', orderBy: 'name');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  // Tutors methods
  Future<int> insertTutor(Map<String, dynamic> tutor) async {
    final db = await database;
    try {
      return await db.insert(
        'tutors',
        tutor,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return -1;
    }
  }

  Future<void> bulkInsertTutors(List<Map<String, dynamic>> tutors) async {
    final db = await database;
    Batch batch = db.batch();
    for (var tutor in tutors) {
      batch.insert(
        'tutors',
        tutor,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getTutors() async {
    final db = await database;
    return await db.query('tutors', orderBy: 'average_rating DESC');
  }

  Future<Map<String, dynamic>?> getTutorById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tutors',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Funciones para manejar cursos
  Future<List<String>> getCoursesByUniversityName(String universityName) async {
    final universityId = await getUniversityIdByName(universityName);
    if (universityId == null) return [];

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      columns: ['name'],
      where: 'university_id = ?',
      whereArgs: [universityId],
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<void> bulkInsertCoursesForUniversity(
      String universityName, List<String> courseNames) async {
    final universityId = await getUniversityIdByName(universityName);
    if (universityId == null) return;

    final db = await database;
    Batch batch = db.batch();
    for (String name in courseNames) {
      batch.insert(
        'courses',
        {'name': name, 'university_id': universityId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertCourse(String name) async {
    final db = await database;
    try {
      return await db.insert('courses', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      return -1;
    }
  }

  Future<void> bulkInsertCourses(List<String> courseNames) async {
    final db = await database;
    Batch batch = db.batch();
    for (String name in courseNames) {
      batch.insert('courses', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<String>> getCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('courses', orderBy: 'name');
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int?> getCourseIdByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int?;
    }
    return null;
  }
}