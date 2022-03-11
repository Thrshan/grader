import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/subject.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase("gradeDetail.db");
    return _database!;
  }

  Future<Database> _initDatabase(String dbFile) async {
    final databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbFile);
    return await openDatabase(
      path,
      version: 1,
      // onCreate: _createDB,
    );
  }

  Future createTable(String tableName) async {
    // print('Creating $tableName');
    final db = await instance.database;
    const idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const integerType = "INTEGER NOT NULL";
    const textType = "TEXT NOT NULL";
    db.execute('''
    CREATE TABLE IF NOT EXISTS $tableName (
      ${SubjectFields.id} $idType,
      ${SubjectFields.name} $textType,
      ${SubjectFields.code} $textType,
      ${SubjectFields.credit} $integerType,
      ${SubjectFields.elective} $integerType,
      ${SubjectFields.grade} $textType
    )
    ''');
    // print('Created $tableName');
  }

  Future<Subject> create(String tableName, Subject data) async {
    // print('Creating row');
    final db = await instance.database;
    final id = await db.insert(tableName, data.toMap());
    // print('Row created');
    return data.copy(id: id);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<Subject> readOne(String tableName, int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      columns: SubjectFields.values,
      where: "${SubjectFields.id} = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Subject>> readAll(String tableName) async {
    final db = await instance.database;
    List<Map<String, Object?>> data =
        await db.rawQuery("SELECT * FROM $tableName");

    return data
        .map((e) => Subject(
              name: e[SubjectFields.name] as String,
              code: e[SubjectFields.code] as String,
              credit: e[SubjectFields.credit] as int,
              elective: e[SubjectFields.elective] as int,
              grade: e[SubjectFields.grade] as String,
              id: e[SubjectFields.id] as int,
            ))
        .toList();
  }

  Future<List<Subject>> readMany(String tableName, int id) async {
    final db = await instance.database;
    const orderBy = "${SubjectFields.id} ASC";
    final result = await db.query(
      tableName,
      columns: SubjectFields.values,
      where: "${SubjectFields.id} = ?",
      whereArgs: [id],
      orderBy: orderBy,
    );
    if (result.isNotEmpty) {
      return result.map((row) => Subject.fromMap(row)).toList();
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<int> update(String tableName, int id, Subject subject) async {
    final db = await instance.database;

    return await db.update(
      tableName,
      subject.toMap(),
      where: "${SubjectFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(String tableName, int id) async {
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: "${SubjectFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future<void> dropTable(String tableName) async {
    final db = await instance.database;
    // print('Dropping $tableName');
    await db.execute('DROP TABLE IF EXISTS $tableName');
    // print('Dropped $tableName');

    return;
  }
}
