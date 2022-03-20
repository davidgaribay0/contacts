import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

Future<Database> database() async {
  return openDatabase(
    join(await getDatabasesPath(), 'contacts.db'),
    onCreate: (db, version) {
      // create all the different tables
      return db.execute(
        'CREATE TABLE contact(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, birthday TEXT, email TEXT, address TEXT, phoneNumber TEXT, notes TEXT)',
      );
    },
    version: 1,
  );
}
