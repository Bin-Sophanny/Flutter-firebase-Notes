import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');
  // create: add a new note
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //read: get a note
  Stream<QuerySnapshot> getNotes() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();
    return noteStream;
  }
  //update: update a note give the id
  Future<void> updateNotes(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }
  //delete: delete a note give the id
  Future<void> deleteNotes(String docID) {
    return notes.doc(docID).delete();
  }
}
