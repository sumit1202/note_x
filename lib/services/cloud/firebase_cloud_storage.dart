import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_x/services/cloud/cloud_note.dart';
import 'package:note_x/services/cloud/cloud_storage_constants.dart';
import 'package:note_x/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  //singleton class
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  //grabbing all notes
  final notes = FirebaseFirestore.instance.collection('notes');

  //create new note
  Future<CloudNote> ceateNewNote({required String ownerUserId}) async {
    final documents = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedDocument = await documents.get();
    return CloudNote(
      documentId: fetchedDocument.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  //get notes by userid
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
  }

  //all notes for a specific user
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
  }

  //update existing note
  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      notes.doc(documentId).update({textFieldName: text});
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  //delete note
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
}
