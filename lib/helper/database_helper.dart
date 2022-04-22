import '/model/note.dart';
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton-Executes only once
  static Database? _database; //Singleton

  String noteTable = 'note_table';
  String colID = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  //Creating an instance of databse
  //This is a named constructor responsible for creating databse
  // This is also a singleton method which is going to run once only
  DatabaseHelper._createInstance();
  // factory DatabaseHelper() {
  //   if (_databaseHelper == null) {
  //     _databaseHelper = DatabaseHelper._createInstance();
  //   }
  //   return _databaseHelper!;
  //   //return _databaseHelper = DatabaseHelper._createInstance();
  // }
  //with NullSafety
  factory DatabaseHelper() {
    return _databaseHelper ??= DatabaseHelper._createInstance();
  }

  //Initiliaze database
  //custom getter
  // Future<Database> get database async {
  //   if (_database == null) {
  //     _database = await initalizeDatabase();
  //   }
  //   return _database!;
  // }
  //Initilization with NullSafety
  Future<Database> get database async {
    return _database ??= await initalizeDatabase();
  }

  Future<Database> initalizeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'notes.db');
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    //debugPrint('DB CREATED' + path.toString());
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable ($colID INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    //optional
    // var result = await db.rawQuery('SELECT * from $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colID = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    var result =
        await db.rawDelete('DELETE FROM $noteTable where $colID = $id');
    return result;
  }

// Counting total values inside a database
  Future<int?> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

//Converting everything from a notelist to a maplist
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();

    int count = noteMapList.length;

    List<Note> noteList = <Note>[];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  Future close() async => _database!.close();
}
