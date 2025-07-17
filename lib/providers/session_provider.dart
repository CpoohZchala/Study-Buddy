import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/session.dart';


class SessionProvider with ChangeNotifier {
  Database? _db;
  List<Session> _sessions = [];

  List<Session> get sessions => _sessions;

  Future openDb() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'studybuddy.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT, date TEXT, durationMinutes INTEGER, notes TEXT)',
        );
      },
      version: 1,
    );
    await fetchSessions();
  }

  Future<void> fetchSessions() async {
    final List<Map<String, dynamic>> maps = await _db!.query('sessions');
    _sessions = List.generate(maps.length, (i) {
      return Session.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> insertSession(Session session) async {
    await _db!.insert('sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await fetchSessions();
  }

  Future<void> deleteSession(int id) async {
    await _db!.delete('sessions', where: 'id = ?', whereArgs: [id]);
    await fetchSessions();
  }
}
