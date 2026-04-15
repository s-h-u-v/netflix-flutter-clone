import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalAuthUser {
  final int id;
  final String email;
  final String displayName;

  const LocalAuthUser({
    required this.id,
    required this.email,
    required this.displayName,
  });
}

class LocalAuthResult {
  final LocalAuthUser? user;
  final String? error;

  const LocalAuthResult({this.user, this.error});

  bool get isSuccess => user != null;
}

class AuthDbService {
  static const _dbName = 'movie_app_auth.db';
  static const _dbVersion = 1;

  static const _usersTable = 'users';
  static const _sessionTable = 'active_session';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            display_name TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_sessionTable (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id INTEGER NOT NULL,
            FOREIGN KEY(user_id) REFERENCES $_usersTable(id) ON DELETE CASCADE
          )
        ''');
      },
    );

    return _database!;
  }

  Future<LocalAuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final db = await database;
      final normalizedEmail = email.trim().toLowerCase();

      final userId = await db.insert(_usersTable, {
        'email': normalizedEmail,
        'password': password,
        'display_name': displayName.trim().isEmpty
            ? normalizedEmail.split('@').first
            : displayName.trim(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      await _setSession(db, userId);
      final user = await _getUserById(db, userId);
      return LocalAuthResult(user: user);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return const LocalAuthResult(
          error: 'This email is already registered.',
        );
      }
      return const LocalAuthResult(
        error: 'Could not create account. Please try again.',
      );
    } catch (_) {
      return const LocalAuthResult(
        error: 'Could not create account. Please try again.',
      );
    }
  }

  Future<LocalAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final db = await database;
      final normalizedEmail = email.trim().toLowerCase();

      final rows = await db.query(
        _usersTable,
        where: 'email = ? AND password = ?',
        whereArgs: [normalizedEmail, password],
        limit: 1,
      );

      if (rows.isEmpty) {
        return const LocalAuthResult(error: 'Invalid email or password.');
      }

      final user = _mapUser(rows.first);
      await _setSession(db, user.id);
      return LocalAuthResult(user: user);
    } catch (_) {
      return const LocalAuthResult(
        error: 'Something went wrong while signing in.',
      );
    }
  }

  Future<LocalAuthUser?> getSignedInUser() async {
    try {
      final db = await database;
      final sessionRows = await db.query(
        _sessionTable,
        where: 'id = 1',
        limit: 1,
      );

      if (sessionRows.isEmpty) return null;

      final userId = sessionRows.first['user_id'] as int;
      return _getUserById(db, userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final db = await database;
    await db.delete(_sessionTable, where: 'id = 1');
  }

  Future<bool> changePasswordForActiveUser({
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await database;
    final sessionRows = await db.query(
      _sessionTable,
      where: 'id = 1',
      limit: 1,
    );
    if (sessionRows.isEmpty) return false;

    final userId = sessionRows.first['user_id'] as int;
    final rows = await db.query(
      _usersTable,
      where: 'id = ? AND password = ?',
      whereArgs: [userId, currentPassword],
      limit: 1,
    );
    if (rows.isEmpty) return false;

    await db.update(
      _usersTable,
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  Future<void> _setSession(Database db, int userId) async {
    await db.insert(_sessionTable, {
      'id': 1,
      'user_id': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<LocalAuthUser?> _getUserById(Database db, int userId) async {
    final rows = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _mapUser(rows.first);
  }

  LocalAuthUser _mapUser(Map<String, Object?> row) {
    return LocalAuthUser(
      id: row['id'] as int,
      email: row['email'] as String,
      displayName: row['display_name'] as String,
    );
  }
}
