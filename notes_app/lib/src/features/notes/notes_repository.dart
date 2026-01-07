import 'package:cloud_firestore/cloud_firestore.dart';

import 'note.dart';

class NotesRepository {
  NotesRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const _collection = 'notes';

  Stream<List<Note>> fetchNotesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<Note>> fetchNotes(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Note.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Note> createNote({
    required String title,
    required String content,
    required String userId,
  }) async {
    final now = DateTime.now();
    final noteData = {
      'title': title,
      'content': content,
      'user_id': userId,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };

    final docRef = await _firestore.collection(_collection).add(noteData);
    final doc = await docRef.get();
    return Note.fromMap(doc.data()!, doc.id);
  }

  Future<Note> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    await _firestore.collection(_collection).doc(id).update({
      'title': title,
      'content': content,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });

    final doc = await _firestore.collection(_collection).doc(id).get();
    return Note.fromMap(doc.data()!, doc.id);
  }

  Future<void> deleteNote(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
