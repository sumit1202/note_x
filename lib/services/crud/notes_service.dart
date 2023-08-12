import 'package:flutter/foundation.dart';
import 'package:note_x/services/crud/crud_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//constants-------------------------------------------------------------------------//

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user"(
        "id"	INTEGER NOT NULL,
        "email"	INTEGER NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER,
      "text"	TEXT,
      "is_synced_with_cloud"	INTEGER DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user_id") REFERENCES "user"("id")
      );
      ''';

//db_service-------------------------------------------------------------------------//

class NotesService {
  Database? _db;

  //open db
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create 'user' table if does not exist
      await db.execute(createUserTable);
      //create 'note' table if does not exist
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  //get db
  Database _getDatabaseOrThrowException() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  //create user
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrowException();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  //get user
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrowException();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  //create a note
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrowException();
    final dbUser = await getUser(email: owner.email);
    //ensuring owner exists with correct id
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
  }

//get note
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrowException();
    final note =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (note.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNote.fromRow(note.first);
    }
  }

  //get all notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrowException();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

//update a note
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrowException();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
  }

  //delete a note
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrowException();
    final deletedCcount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

    if (deletedCcount == 1) {
      throw CouldNotDeleteNoteException();
    }
  }

  //delete all notes
  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrowException();
    return await db.delete(noteTable);
  }

  //delete user
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrowException();
    final deletedCcount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCcount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  //close db
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

//db_user-------------------------------------------------------------------------//
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'DatabaseUser(id: $id, email: $email)';

  @override
  bool operator ==(covariant DatabaseUser other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

//db_note-------------------------------------------------------------------------//
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'id: $id, userId: $userId, isSyncedwithCloud: $isSyncedWithCloud, text: $text';
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
