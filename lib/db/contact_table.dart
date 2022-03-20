import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../model/contact.dart';
import 'db.dart';

final contactsProvider = Provider((ref) => ContactTable());

class ContactTable {
  Future<void> insert(Contact contact) async {
    final db = await database();
    await db.insert(
      'contact',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> all() async {
    final db = await database();
    final List<Map<String, dynamic>> maps =
    await db.query('contact', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        birthday: maps[i]['birthday'],
        email: maps[i]['email'],
        address: maps[i]['address'],
        phoneNumber: maps[i]['phoneNumber'],
        notes: maps[i]['notes'],
      );
    });
  }

  Future<Contact> one(int? id) async {
    final db = await database();
    var contacts = await db.query(
      "contact",
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (contacts.isNotEmpty) {
      return Contact.fromDb(contacts.first);
    }
    throw Error();
  }

  Future<void> update(Contact contact) async {
    final db = await database();

    await db.update(
      'contact',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> delete(int? id) async {
    final db = await database();
    await db.delete(
      'contact',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
